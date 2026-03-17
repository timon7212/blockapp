import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';
import { ScreenTimeRecordEntity } from './entities/screen-time-record.entity';
import { AdViewEntity } from './entities/ad-view.entity';
import { SpinPrizeEntity } from './entities/spin-prize.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ScreenTimeRecordEntity,
      AdViewEntity,
      SpinPrizeEntity,
      UserEntity,
      TransactionEntity,
    ]),
  ],
  controllers: [EventsController],
  providers: [EventsService],
  exports: [EventsService],
})
export class EventsModule {}
