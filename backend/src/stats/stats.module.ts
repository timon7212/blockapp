import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StatsController } from './stats.controller';
import { StatsService } from './stats.service';
import { UserEntity } from '../auth/entities/user.entity';
import { ScreenTimeRecordEntity } from '../events/entities/screen-time-record.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      ScreenTimeRecordEntity,
      TransactionEntity,
    ]),
  ],
  controllers: [StatsController],
  providers: [StatsService],
  exports: [StatsService],
})
export class StatsModule {}
