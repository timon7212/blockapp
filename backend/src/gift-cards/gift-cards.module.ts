import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GiftCardsController } from './gift-cards.controller';
import { GiftCardsService } from './gift-cards.service';
import { TremendousService } from './tremendous.service';
import { GiftCardRedemptionEntity } from './entities/gift-card-redemption.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [
    HttpModule,
    TypeOrmModule.forFeature([GiftCardRedemptionEntity, UserEntity, TransactionEntity]),
  ],
  controllers: [GiftCardsController],
  providers: [TremendousService, GiftCardsService],
  exports: [TremendousService, GiftCardsService],
})
export class GiftCardsModule {}
