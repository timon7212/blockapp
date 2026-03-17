import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RafflesController } from './raffles.controller';
import { RafflesService } from './raffles.service';
import { RaffleCronService } from './raffle-cron.service';
import { RaffleEntity } from './entities/raffle.entity';
import { RaffleEntryEntity } from './entities/raffle-entry.entity';
import { RafflePrerequisiteEntity } from './entities/raffle-prerequisite.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { AdViewEntity } from '../events/entities/ad-view.entity';
import { TaskProgressEntity } from '../tasks/entities/task-progress.entity';
import { SurveyCompletionEntity } from '../surveys/entities/survey-completion.entity';
import { GameCompletionEntity } from '../games/entities/game-completion.entity';
import { WalletModule } from '../wallet/wallet.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      RaffleEntity,
      RaffleEntryEntity,
      RafflePrerequisiteEntity,
      UserEntity,
      AdViewEntity,
      TaskProgressEntity,
      SurveyCompletionEntity,
      GameCompletionEntity,
    ]),
    WalletModule,
  ],
  controllers: [RafflesController],
  providers: [RafflesService, RaffleCronService],
  exports: [RafflesService],
})
export class RafflesModule {}
