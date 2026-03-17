import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TasksController } from './tasks.controller';
import { TasksService } from './tasks.service';
import { TaskEntity } from './entities/task.entity';
import { TaskProgressEntity } from './entities/task-progress.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([TaskEntity, TaskProgressEntity, UserEntity, TransactionEntity]),
  ],
  controllers: [TasksController],
  providers: [TasksService],
  exports: [TasksService],
})
export class TasksModule {}
