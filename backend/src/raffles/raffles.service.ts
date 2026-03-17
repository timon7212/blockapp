import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Not, IsNull } from 'typeorm';
import { RaffleEntity } from './entities/raffle.entity';
import { RaffleEntryEntity } from './entities/raffle-entry.entity';
import {
  RafflePrerequisiteEntity,
  PrerequisiteType,
} from './entities/raffle-prerequisite.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { AdViewEntity } from '../events/entities/ad-view.entity';
import { TaskProgressEntity } from '../tasks/entities/task-progress.entity';
import { SurveyCompletionEntity } from '../surveys/entities/survey-completion.entity';
import { GameCompletionEntity } from '../games/entities/game-completion.entity';
import {
  RaffleDto,
  RaffleResultDto,
  RaffleEntryResponseDto,
  RaffleHistoryQueryDto,
  RafflePrerequisiteItemDto,
  RaffleWinnerDto,
  RaffleWinnersQueryDto,
} from './dto/raffles.dto';
import { PaginatedResponseDto, PaginationMeta } from '../common/dto/pagination.dto';

@Injectable()
export class RafflesService {
  constructor(
    @InjectRepository(RaffleEntity)
    private readonly raffleRepo: Repository<RaffleEntity>,
    @InjectRepository(RaffleEntryEntity)
    private readonly entryRepo: Repository<RaffleEntryEntity>,
    @InjectRepository(RafflePrerequisiteEntity)
    private readonly prereqRepo: Repository<RafflePrerequisiteEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(AdViewEntity)
    private readonly adViewRepo: Repository<AdViewEntity>,
    @InjectRepository(TaskProgressEntity)
    private readonly taskProgressRepo: Repository<TaskProgressEntity>,
    @InjectRepository(SurveyCompletionEntity)
    private readonly surveyCompletionRepo: Repository<SurveyCompletionEntity>,
    @InjectRepository(GameCompletionEntity)
    private readonly gameCompletionRepo: Repository<GameCompletionEntity>,
  ) {}

  async getActiveRaffles(userId: string): Promise<RaffleDto[]> {
    const raffles = await this.raffleRepo.find({
      where: { active: true },
      relations: ['prerequisites'],
      order: { drawDate: 'ASC' },
    });

    return Promise.all(raffles.map((r) => this.enrichRaffle(r, userId)));
  }

  async getRaffle(raffleId: string, userId: string): Promise<RaffleDto> {
    const raffle = await this.raffleRepo.findOne({
      where: { id: raffleId },
      relations: ['prerequisites'],
    });
    if (!raffle) {
      throw new NotFoundException('Raffle not found');
    }
    return this.enrichRaffle(raffle, userId);
  }

  async enterRaffle(
    userId: string,
    raffleId: string,
  ): Promise<RaffleEntryResponseDto> {
    const raffle = await this.raffleRepo.findOne({
      where: { id: raffleId },
      relations: ['prerequisites'],
    });
    if (!raffle) {
      throw new NotFoundException('Raffle not found');
    }
    if (!raffle.active) {
      throw new BadRequestException('Raffle is no longer active');
    }

    const existing = await this.entryRepo.findOne({
      where: { userId, raffleId },
    });
    if (existing) {
      throw new ConflictException('Already entered this raffle');
    }

    const prereqItems = await this.evaluatePrerequisites(
      raffle.prerequisites ?? [],
      userId,
    );
    const allMet = prereqItems.length === 0 || prereqItems.every((p) => p.met);
    if (!allMet) {
      const unmet = prereqItems.filter((p) => !p.met);
      const details = unmet
        .map((p) => `${p.type}: ${p.userCurrentCount}/${p.requiredCount}`)
        .join(', ');
      throw new BadRequestException(
        `Prerequisites not met: ${details}`,
      );
    }

    const entry = this.entryRepo.create({ userId, raffleId });
    await this.entryRepo.save(entry);

    const totalParticipants = await this.entryRepo.count({
      where: { raffleId },
    });

    return {
      success: true,
      entryId: entry.id,
      totalParticipants,
    };
  }

  async getRaffleResult(
    raffleId: string,
    userId: string,
  ): Promise<RaffleResultDto> {
    const raffle = await this.raffleRepo.findOne({
      where: { id: raffleId },
      relations: ['winner'],
    });
    if (!raffle) {
      throw new NotFoundException('Raffle not found');
    }
    if (!raffle.winnerId) {
      throw new BadRequestException('Raffle has not been drawn yet');
    }

    return {
      raffleId: raffle.id,
      winnerId: raffle.winnerId,
      winnerUsername: raffle.winner?.displayName ?? 'Unknown',
      prizeAmount: raffle.prizeAmount,
      isCurrentUserWinner: raffle.winnerId === userId,
      drawnAt: raffle.drawDate,
    };
  }

  async getRaffleHistory(
    userId: string,
    query: RaffleHistoryQueryDto,
  ): Promise<PaginatedResponseDto<RaffleResultDto>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const [entries, total] = await this.entryRepo.findAndCount({
      where: { userId },
      relations: ['raffle', 'raffle.winner'],
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    const data: RaffleResultDto[] = entries
      .filter((e) => e.raffle?.winnerId)
      .map((e) => ({
        raffleId: e.raffle.id,
        winnerId: e.raffle.winnerId,
        winnerUsername: e.raffle.winner?.displayName ?? 'Unknown',
        prizeAmount: e.raffle.prizeAmount,
        isCurrentUserWinner: e.raffle.winnerId === userId,
        drawnAt: e.raffle.drawDate,
      }));

    const totalPages = Math.ceil(total / limit) || 1;
    const meta: PaginationMeta = {
      page,
      limit,
      total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    };

    return { data, meta };
  }

  async getWinners(
    query: RaffleWinnersQueryDto,
  ): Promise<PaginatedResponseDto<RaffleWinnerDto>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const where: any = { active: false, winnerId: Not(IsNull()) };
    if (query.type) {
      where.type = query.type;
    }

    const [raffles, total] = await this.raffleRepo.findAndCount({
      where,
      relations: ['winner'],
      order: { drawDate: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    const data: RaffleWinnerDto[] = raffles.map((r) => ({
      winnerId: r.winnerId,
      winnerUsername: r.winner?.displayName ?? 'Unknown',
      winnerAvatar: r.winner?.avatarUrl ?? undefined,
      prizeAmount: r.prizeAmount,
      drawnAt: r.drawDate,
      raffleTitle: r.title,
    }));

    const totalPages = Math.ceil(total / limit) || 1;
    const meta: PaginationMeta = {
      page,
      limit,
      total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    };

    return { data, meta };
  }

  private async enrichRaffle(
    raffle: RaffleEntity,
    userId: string,
  ): Promise<RaffleDto> {
    const [totalParticipants, userEntry] = await Promise.all([
      this.entryRepo.count({ where: { raffleId: raffle.id } }),
      this.entryRepo.findOne({ where: { userId, raffleId: raffle.id } }),
    ]);

    const now = new Date();
    const timeRemainingSeconds = Math.max(
      0,
      Math.floor((raffle.drawDate.getTime() - now.getTime()) / 1000),
    );

    const prereqItems = await this.evaluatePrerequisites(
      raffle.prerequisites ?? [],
      userId,
    );
    const isEligible =
      prereqItems.length === 0 || prereqItems.every((p) => p.met);

    return {
      id: raffle.id,
      title: raffle.title,
      type: raffle.type,
      prizeAmount: raffle.prizeAmount,
      timeRemainingSeconds,
      totalParticipants,
      isEntered: !!userEntry,
      isEligible,
      prerequisites: prereqItems,
    };
  }

  private async evaluatePrerequisites(
    prerequisites: RafflePrerequisiteEntity[],
    userId: string,
  ): Promise<RafflePrerequisiteItemDto[]> {
    const results: RafflePrerequisiteItemDto[] = [];

    for (const prereq of prerequisites) {
      const userCount = await this.getUserCountForType(prereq.type, userId);
      results.push({
        type: prereq.type,
        requiredCount: prereq.requiredCount,
        userCurrentCount: userCount,
        met: userCount >= prereq.requiredCount,
      });
    }

    return results;
  }

  private async getUserCountForType(
    type: PrerequisiteType,
    userId: string,
  ): Promise<number> {
    switch (type) {
      case PrerequisiteType.ADS_WATCHED:
        return this.adViewRepo.count({ where: { userId } });

      case PrerequisiteType.TASKS_COMPLETED:
        return this.taskProgressRepo.count({
          where: { userId, status: 'completed' },
        });

      case PrerequisiteType.SURVEYS_COMPLETED:
        return this.surveyCompletionRepo.count({ where: { userId } });

      case PrerequisiteType.GAMES_COMPLETED:
        return this.gameCompletionRepo.count({ where: { userId } });

      default:
        return 0;
    }
  }
}
