import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReferralsController } from './referrals.controller';
import { ReferralsService } from './referrals.service';
import { UserEntity } from '../auth/entities/user.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity, TransactionEntity])],
  controllers: [ReferralsController],
  providers: [ReferralsService],
})
export class ReferralsModule {}
