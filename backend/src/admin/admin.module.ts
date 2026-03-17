import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { RaffleEntity } from '../raffles/entities/raffle.entity';
import { RafflePrerequisiteEntity } from '../raffles/entities/raffle-prerequisite.entity';
import { GameEntity } from '../games/entities/game.entity';
import { TaskEntity } from '../tasks/entities/task.entity';
import { SurveyEntity } from '../surveys/entities/survey.entity';
import { SpinPrizeEntity } from '../events/entities/spin-prize.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      RaffleEntity,
      RafflePrerequisiteEntity,
      GameEntity,
      TaskEntity,
      SurveyEntity,
      SpinPrizeEntity,
    ]),
  ],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
