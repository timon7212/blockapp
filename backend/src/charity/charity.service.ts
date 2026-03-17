import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CharityEntity } from './entities/charity.entity';
import { CharityDonationEntity } from './entities/charity-donation.entity';
import { UserEntity } from '../auth/entities/user.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import { CharityDto, DonationResponseDto } from './dto/charity.dto';

@Injectable()
export class CharityService {
  constructor(
    @InjectRepository(CharityEntity)
    private readonly charityRepo: Repository<CharityEntity>,
    @InjectRepository(CharityDonationEntity)
    private readonly donationRepo: Repository<CharityDonationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
  ) {}

  async getCharities(): Promise<CharityDto[]> {
    const charities = await this.charityRepo.find({
      where: { active: true },
    });

    return charities.map((c) => ({
      id: c.id,
      name: c.name,
      emoji: c.emoji,
      description: c.description,
      color: c.color,
    }));
  }

  async donate(
    userId: string,
    charityId: string,
    amount: number,
  ): Promise<DonationResponseDto> {
    const charity = await this.charityRepo.findOne({
      where: { id: charityId },
    });
    if (!charity) {
      throw new NotFoundException('Charity not found');
    }

    const user = await this.userRepo.findOneByOrFail({ id: userId });
    if (user.walletBalance < amount) {
      throw new BadRequestException(
        `Insufficient balance. Need ${amount}, have ${user.walletBalance}.`,
      );
    }

    const donation = this.donationRepo.create({
      userId,
      charityId,
      points: amount,
    });
    await this.donationRepo.save(donation);

    user.walletBalance -= amount;
    await this.userRepo.save(user);

    const transaction = this.transactionRepo.create({
      userId,
      type: TransactionType.DONATION,
      points: -amount,
      description: `Donation to ${charity.name}`,
    });
    await this.transactionRepo.save(transaction);

    return {
      success: true,
      donationId: donation.id,
      amount,
      charityName: charity.name,
      newBalance: user.walletBalance,
    };
  }
}
