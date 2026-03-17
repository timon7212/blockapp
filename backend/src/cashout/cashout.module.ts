import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CashOutController } from './cashout.controller';
import { CashOutService } from './cashout.service';
import { CashOutRequestEntity } from './entities/cashout-request.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [TypeOrmModule.forFeature([CashOutRequestEntity, UserEntity, TransactionEntity])],
  controllers: [CashOutController],
  providers: [CashOutService],
  exports: [CashOutService],
})
export class CashOutModule {}
