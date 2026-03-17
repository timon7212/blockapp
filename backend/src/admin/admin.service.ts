import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RaffleEntity } from '../raffles/entities/raffle.entity';
import {
  RafflePrerequisiteEntity,
  PrerequisiteType,
} from '../raffles/entities/raffle-prerequisite.entity';
import { GameEntity } from '../games/entities/game.entity';
import { TaskEntity } from '../tasks/entities/task.entity';
import { SurveyEntity } from '../surveys/entities/survey.entity';
import { SpinPrizeEntity } from '../events/entities/spin-prize.entity';
import {
  CreateRaffleDto,
  UpdateRaffleDto,
  AddPrerequisiteDto,
} from '../raffles/dto/raffles.dto';
import {
  CreateGameDto,
  UpdateGameDto,
  CreateTaskDto,
  UpdateTaskDto,
  CreateSurveyDto,
  UpdateSurveyDto,
  CreateSpinPrizeDto,
  UpdateSpinPrizeDto,
} from './dto/admin.dto';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(RaffleEntity)
    private readonly raffleRepo: Repository<RaffleEntity>,
    @InjectRepository(RafflePrerequisiteEntity)
    private readonly prereqRepo: Repository<RafflePrerequisiteEntity>,
    @InjectRepository(GameEntity)
    private readonly gameRepo: Repository<GameEntity>,
    @InjectRepository(TaskEntity)
    private readonly taskRepo: Repository<TaskEntity>,
    @InjectRepository(SurveyEntity)
    private readonly surveyRepo: Repository<SurveyEntity>,
    @InjectRepository(SpinPrizeEntity)
    private readonly spinPrizeRepo: Repository<SpinPrizeEntity>,
  ) {}

  // ── Raffles ──

  async createRaffle(dto: CreateRaffleDto): Promise<RaffleEntity> {
    const raffle = this.raffleRepo.create({
      title: dto.title,
      type: dto.type,
      prizeAmount: dto.prizeAmount,
      drawDate: new Date(dto.drawDate),
      active: true,
    });
    return this.raffleRepo.save(raffle);
  }

  async updateRaffle(id: string, dto: UpdateRaffleDto): Promise<RaffleEntity> {
    const raffle = await this.raffleRepo.findOne({ where: { id } });
    if (!raffle) throw new NotFoundException('Raffle not found');

    if (dto.title !== undefined) raffle.title = dto.title;
    if (dto.type !== undefined) raffle.type = dto.type;
    if (dto.prizeAmount !== undefined) raffle.prizeAmount = dto.prizeAmount;
    if (dto.drawDate !== undefined) raffle.drawDate = new Date(dto.drawDate);

    return this.raffleRepo.save(raffle);
  }

  async deleteRaffle(id: string): Promise<void> {
    const raffle = await this.raffleRepo.findOne({ where: { id } });
    if (!raffle) throw new NotFoundException('Raffle not found');
    await this.raffleRepo.remove(raffle);
  }

  async addPrerequisite(
    raffleId: string,
    dto: AddPrerequisiteDto,
  ): Promise<RafflePrerequisiteEntity> {
    const raffle = await this.raffleRepo.findOne({ where: { id: raffleId } });
    if (!raffle) throw new NotFoundException('Raffle not found');

    const prereq = this.prereqRepo.create({
      raffleId,
      type: dto.type,
      requiredCount: dto.requiredCount,
    });
    return this.prereqRepo.save(prereq);
  }

  async removePrerequisite(raffleId: string, prereqId: string): Promise<void> {
    const prereq = await this.prereqRepo.findOne({
      where: { id: prereqId, raffleId },
    });
    if (!prereq) throw new NotFoundException('Prerequisite not found');
    await this.prereqRepo.remove(prereq);
  }

  async getRaffleWithPrereqs(id: string): Promise<RaffleEntity> {
    const raffle = await this.raffleRepo.findOne({
      where: { id },
      relations: ['prerequisites'],
    });
    if (!raffle) throw new NotFoundException('Raffle not found');
    return raffle;
  }

  // ── Games ──

  async createGame(dto: CreateGameDto): Promise<GameEntity> {
    const game = this.gameRepo.create(dto);
    return this.gameRepo.save(game);
  }

  async updateGame(id: string, dto: UpdateGameDto): Promise<GameEntity> {
    const game = await this.gameRepo.findOne({ where: { id } });
    if (!game) throw new NotFoundException('Game not found');
    Object.assign(game, dto);
    return this.gameRepo.save(game);
  }

  async deleteGame(id: string): Promise<void> {
    const game = await this.gameRepo.findOne({ where: { id } });
    if (!game) throw new NotFoundException('Game not found');
    game.active = false;
    await this.gameRepo.save(game);
  }

  // ── Tasks ──

  async createTask(dto: CreateTaskDto): Promise<TaskEntity> {
    const task = this.taskRepo.create({
      ...dto,
      expiresAt: dto.expiresAt ? new Date(dto.expiresAt) : null,
    });
    return this.taskRepo.save(task);
  }

  async updateTask(id: string, dto: UpdateTaskDto): Promise<TaskEntity> {
    const task = await this.taskRepo.findOne({ where: { id } });
    if (!task) throw new NotFoundException('Task not found');
    if (dto.expiresAt !== undefined) {
      (task as any).expiresAt = dto.expiresAt ? new Date(dto.expiresAt) : null;
      delete dto.expiresAt;
    }
    Object.assign(task, dto);
    return this.taskRepo.save(task);
  }

  async deleteTask(id: string): Promise<void> {
    const task = await this.taskRepo.findOne({ where: { id } });
    if (!task) throw new NotFoundException('Task not found');
    task.active = false;
    await this.taskRepo.save(task);
  }

  // ── Surveys ──

  async createSurvey(dto: CreateSurveyDto): Promise<SurveyEntity> {
    const survey = this.surveyRepo.create(dto);
    return this.surveyRepo.save(survey);
  }

  async updateSurvey(id: string, dto: UpdateSurveyDto): Promise<SurveyEntity> {
    const survey = await this.surveyRepo.findOne({ where: { id } });
    if (!survey) throw new NotFoundException('Survey not found');
    Object.assign(survey, dto);
    return this.surveyRepo.save(survey);
  }

  async deleteSurvey(id: string): Promise<void> {
    const survey = await this.surveyRepo.findOne({ where: { id } });
    if (!survey) throw new NotFoundException('Survey not found');
    survey.active = false;
    await this.surveyRepo.save(survey);
  }

  // ── Spin Prizes ──

  async getSpinPrizes(): Promise<SpinPrizeEntity[]> {
    return this.spinPrizeRepo.find({ order: { weight: 'DESC' } });
  }

  async createSpinPrize(dto: CreateSpinPrizeDto): Promise<SpinPrizeEntity> {
    const prize = this.spinPrizeRepo.create(dto);
    return this.spinPrizeRepo.save(prize);
  }

  async updateSpinPrize(
    id: string,
    dto: UpdateSpinPrizeDto,
  ): Promise<SpinPrizeEntity> {
    const prize = await this.spinPrizeRepo.findOne({ where: { id } });
    if (!prize) throw new NotFoundException('Spin prize not found');
    Object.assign(prize, dto);
    return this.spinPrizeRepo.save(prize);
  }

  async deleteSpinPrize(id: string): Promise<void> {
    const prize = await this.spinPrizeRepo.findOne({ where: { id } });
    if (!prize) throw new NotFoundException('Spin prize not found');
    await this.spinPrizeRepo.remove(prize);
  }
}
