import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from '../auth/entities/user.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import { UpdateProfileDto, OnboardingDto, UserProfileDto } from './dto/users.dto';

const WELCOME_BONUS_POINTS = 500;

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
  ) {}

  async getProfile(userId: string): Promise<UserProfileDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const directInvites = await this.userRepo.count({
      where: { referredById: userId },
    });

    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      referralCode: user.referralCode,
      directInvites,
      joinedAt: user.createdAt,
      totalPoints: user.walletBalance,
      uncollectedPoints: user.uncollectedPoints,
      currentStreak: user.currentStreak,
      onboardingComplete: user.onboardingComplete,
      trackedAppIds: user.trackedAppIds,
      spinsAvailable: user.spinsAvailable,
    };
  }

  async updateProfile(
    userId: string,
    dto: UpdateProfileDto,
  ): Promise<UserProfileDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    if (dto.displayName !== undefined) user.displayName = dto.displayName;
    if (dto.avatarUrl !== undefined) user.avatarUrl = dto.avatarUrl;

    await this.userRepo.save(user);
    return this.getProfile(userId);
  }

  async submitOnboarding(
    userId: string,
    dto: OnboardingDto,
  ): Promise<UserProfileDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    user.trackedAppIds = dto.trackedAppIds;
    user.goal = dto.goal;
    user.onboardingComplete = true;

    // ── Credit welcome bonus ──
    // Only credit if this is the first onboarding (walletBalance is 0 and no
    // existing WELCOME_BONUS transaction) to prevent double-crediting.
    const existingBonus = await this.transactionRepo.findOne({
      where: { userId, type: TransactionType.WELCOME_BONUS },
    });

    if (!existingBonus) {
      const tx = this.transactionRepo.create({
        userId,
        type: TransactionType.WELCOME_BONUS,
        points: WELCOME_BONUS_POINTS,
        description: 'Welcome bonus for completing onboarding',
      });
      await this.transactionRepo.save(tx);

      user.walletBalance += WELCOME_BONUS_POINTS;
    }

    await this.userRepo.save(user);
    return this.getProfile(userId);
  }
}
