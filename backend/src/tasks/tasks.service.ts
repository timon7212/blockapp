import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TaskEntity } from './entities/task.entity';
import { TaskProgressEntity } from './entities/task-progress.entity';
import { UserEntity } from '../auth/entities/user.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import {
  TaskDto,
  TaskStatus,
  TaskCatalogQueryDto,
  TaskCompleteResponseDto,
} from './dto/tasks.dto';
import { PaginatedResponseDto, PaginationMeta } from '../common/dto/pagination.dto';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(TaskEntity)
    private readonly taskRepo: Repository<TaskEntity>,
    @InjectRepository(TaskProgressEntity)
    private readonly progressRepo: Repository<TaskProgressEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
  ) {}

  async getTasks(
    userId: string,
    query: TaskCatalogQueryDto,
  ): Promise<PaginatedResponseDto<TaskDto>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const [tasks, total] = await this.taskRepo.findAndCount({
      where: { active: true },
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    const data: TaskDto[] = await Promise.all(
      tasks.map(async (task) => {
        const progress = await this.progressRepo.findOne({
          where: { userId, taskId: task.id },
        });

        return {
          id: task.id,
          title: task.title,
          description: task.description,
          iconUrl: task.iconUrl,
          pointsReward: task.pointsReward,
          status: (progress?.status as TaskStatus) ?? TaskStatus.AVAILABLE,
          category: task.category,
          url: task.url,
          expiresAt: task.expiresAt ?? null,
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

  async startTask(userId: string, taskId: string): Promise<TaskDto> {
    const task = await this.taskRepo.findOne({
      where: { id: taskId, active: true },
    });
    if (!task) {
      throw new NotFoundException('Task not found');
    }

    let progress = await this.progressRepo.findOne({
      where: { userId, taskId },
    });

    if (progress) {
      if (progress.status === TaskStatus.COMPLETED) {
        throw new BadRequestException('Task already completed');
      }
      progress.status = TaskStatus.IN_PROGRESS;
      await this.progressRepo.save(progress);
    } else {
      progress = this.progressRepo.create({
        userId,
        taskId,
        status: TaskStatus.IN_PROGRESS,
      });
      await this.progressRepo.save(progress);
    }

    return {
      id: task.id,
      title: task.title,
      description: task.description,
      iconUrl: task.iconUrl,
      pointsReward: task.pointsReward,
      status: TaskStatus.IN_PROGRESS,
      category: task.category,
      url: task.url,
      expiresAt: task.expiresAt ?? null,
    };
  }

  async completeTask(
    userId: string,
    taskId: string,
  ): Promise<TaskCompleteResponseDto> {
    const task = await this.taskRepo.findOne({
      where: { id: taskId, active: true },
    });
    if (!task) {
      throw new NotFoundException('Task not found');
    }

    const progress = await this.progressRepo.findOne({
      where: { userId, taskId },
    });
    if (!progress) {
      throw new BadRequestException('Task not started');
    }
    if (progress.status === TaskStatus.COMPLETED) {
      throw new BadRequestException('Task already completed');
    }

    progress.status = TaskStatus.COMPLETED;
    progress.pointsEarned = task.pointsReward;
    await this.progressRepo.save(progress);

    const user = await this.userRepo.findOneByOrFail({ id: userId });
    user.walletBalance += task.pointsReward;
    await this.userRepo.save(user);

    const transaction = this.transactionRepo.create({
      userId,
      type: TransactionType.TASK,
      points: task.pointsReward,
      description: `Task completed: ${task.title}`,
    });
    await this.transactionRepo.save(transaction);

    return {
      pointsEarned: task.pointsReward,
      newBalance: user.walletBalance,
    };
  }
}
