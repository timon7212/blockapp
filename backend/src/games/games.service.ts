import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GameEntity } from './entities/game.entity';
import { GameCompletionEntity } from './entities/game-completion.entity';
import { UserEntity } from '../auth/entities/user.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import {
  GameDto,
  GameCatalogQueryDto,
  GameCompleteDto,
  GameCompleteResponseDto,
} from './dto/games.dto';
import { PaginatedResponseDto, PaginationMeta } from '../common/dto/pagination.dto';

@Injectable()
export class GamesService {
  constructor(
    @InjectRepository(GameEntity)
    private readonly gameRepo: Repository<GameEntity>,
    @InjectRepository(GameCompletionEntity)
    private readonly completionRepo: Repository<GameCompletionEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
  ) {}

  async getGames(
    userId: string,
    query: GameCatalogQueryDto,
  ): Promise<PaginatedResponseDto<GameDto>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const [games, total] = await this.gameRepo.findAndCount({
      where: { active: true },
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    const today = new Date().toISOString().split('T')[0];

    const data: GameDto[] = await Promise.all(
      games.map(async (game) => {
        const todayCompletion = await this.completionRepo.findOne({
          where: { userId, gameId: game.id, date: today },
        });

        return {
          id: game.id,
          title: game.title,
          description: game.description,
          iconUrl: game.iconUrl,
          bannerUrl: game.bannerUrl,
          pointsReward: game.pointsReward,
          estimatedMinutes: game.estimatedMinutes,
          playedToday: !!todayCompletion,
          url: game.url,
        };
      }),
    );

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

  async completeGame(
    userId: string,
    dto: GameCompleteDto,
  ): Promise<GameCompleteResponseDto> {
    const game = await this.gameRepo.findOne({
      where: { id: dto.gameId, active: true },
    });
    if (!game) {
      throw new NotFoundException('Game not found');
    }

    const today = new Date().toISOString().split('T')[0];
    const existing = await this.completionRepo.findOne({
      where: { userId, gameId: dto.gameId, date: today },
    });
    if (existing) {
      throw new BadRequestException('Already played this game today');
    }

    const completion = this.completionRepo.create({
      userId,
      gameId: dto.gameId,
      score: dto.score,
      pointsEarned: game.pointsReward,
      date: today,
    });
    await this.completionRepo.save(completion);

    const user = await this.userRepo.findOneByOrFail({ id: userId });
    user.walletBalance += game.pointsReward;
    await this.userRepo.save(user);

    const transaction = this.transactionRepo.create({
      userId,
      type: TransactionType.GAME,
      points: game.pointsReward,
      description: `Game completed: ${game.title}`,
    });
    await this.transactionRepo.save(transaction);

    return {
      pointsEarned: game.pointsReward,
      newBalance: user.walletBalance,
    };
  }
}
