import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CharityController } from './charity.controller';
import { CharityService } from './charity.service';
import { CharityEntity } from './entities/charity.entity';
import { CharityDonationEntity } from './entities/charity-donation.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([CharityEntity, CharityDonationEntity, UserEntity, TransactionEntity]),
  ],
  controllers: [CharityController],
  providers: [CharityService],
  exports: [CharityService],
})
export class CharityModule {}
