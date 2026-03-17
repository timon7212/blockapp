import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { UserEntity } from '../auth/entities/user.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import {
  ReferralStatsDto,
  InviteeDto,
  CollectReferralResponseDto,
  InviteLinkDto,
} from './dto/referrals.dto';

@Injectable()
export class ReferralsService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
    private readonly config: ConfigService,
  ) {}

  async getReferralStats(userId: string): Promise<ReferralStatsDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const directInvites = await this.userRepo.count({
      where: { referredById: userId },
    });

    const directInviteeIds = await this.userRepo.find({
      where: { referredById: userId },
      select: ['id'],
    });

    let grandChildInvites = 0;
    for (const invitee of directInviteeIds) {
      const count = await this.userRepo.count({
        where: { referredById: invitee.id },
      });
      grandChildInvites += count;
    }

    const totalResult = await this.transactionRepo
      .createQueryBuilder('t')
      .select('COALESCE(SUM(t.points), 0)', 'total')
      .where('t.userId = :userId', { userId })
      .andWhere('t.type = :type', { type: TransactionType.REFERRAL })
      .getRawOne();

    return {
      directInvites,
      grandChildInvites,
      childCommissionPercent: this.config.get<number>('REFERRAL_CHILD_PERCENT', 10),
      grandChildCommissionPercent: this.config.get<number>('REFERRAL_GRANDCHILD_PERCENT', 5),
      pendingChildPoints: user.pendingChildPoints,
      pendingGrandChildPoints: user.pendingGrandChildPoints,
      totalCollected: Number(totalResult?.total ?? 0),
    };
  }

  async getInvitees(userId: string): Promise<InviteeDto[]> {
    const childRate =
      this.config.get<number>('REFERRAL_CHILD_PERCENT', 10) / 100;
    const grandChildRate =
      this.config.get<number>('REFERRAL_GRANDCHILD_PERCENT', 5) / 100;

    const directInvitees = await this.userRepo.find({
      where: { referredById: userId },
      order: { createdAt: 'DESC' },
    });

    const result: InviteeDto[] = [];

    for (const invitee of directInvitees) {
      // Calculate how many points the inviter earned from this child invitee.
      // Child referral bonus = sum of invitee's collected points * childRate
      const inviteeCollected = await this.transactionRepo
        .createQueryBuilder('t')
        .select('COALESCE(SUM(t.points), 0)', 'total')
        .where('t.userId = :inviteeId', { inviteeId: invitee.id })
        .andWhere('t.type = :type', { type: TransactionType.POINTS_COLLECTED })
        .getRawOne();
      const childPointsEarned = Math.floor(
        Number(inviteeCollected?.total ?? 0) * childRate,
      );

      result.push({
        id: invitee.id,
        displayName: invitee.displayName,
        joinedAt: invitee.createdAt,
        pointsEarned: childPointsEarned,
        level: 'child',
      });

      const grandChildren = await this.userRepo.find({
        where: { referredById: invitee.id },
        order: { createdAt: 'DESC' },
      });

      for (const gc of grandChildren) {
        const gcCollected = await this.transactionRepo
          .createQueryBuilder('t')
          .select('COALESCE(SUM(t.points), 0)', 'total')
          .where('t.userId = :gcId', { gcId: gc.id })
          .andWhere('t.type = :type', {
            type: TransactionType.POINTS_COLLECTED,
          })
          .getRawOne();
        const gcPointsEarned = Math.floor(
          Number(gcCollected?.total ?? 0) * grandChildRate,
        );

        result.push({
          id: gc.id,
          displayName: gc.displayName,
          joinedAt: gc.createdAt,
          pointsEarned: gcPointsEarned,
          level: 'grandchild',
        });
      }
    }

    return result;
  }

  async collectChildPoints(
    userId: string,
  ): Promise<CollectReferralResponseDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    if (user.pendingChildPoints <= 0) {
      throw new BadRequestException('No pending child referral points');
    }

    const points = user.pendingChildPoints;

    const tx = this.transactionRepo.create({
      userId,
      type: TransactionType.REFERRAL,
      points,
      description: 'Referral earnings from direct invitees (child)',
    });
    await this.transactionRepo.save(tx);

    user.pendingChildPoints = 0;
    user.walletBalance += points;
    user.weeklyPoints += points;
    await this.userRepo.save(user);

    return {
      level: 'child',
      pointsCollected: points,
      newBalance: user.walletBalance,
    };
  }

  async collectGrandChildPoints(
    userId: string,
  ): Promise<CollectReferralResponseDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    if (user.pendingGrandChildPoints <= 0) {
      throw new BadRequestException('No pending grandchild referral points');
    }

    const points = user.pendingGrandChildPoints;

    const tx = this.transactionRepo.create({
      userId,
      type: TransactionType.REFERRAL,
      points,
      description: 'Referral earnings from grandchildren',
    });
    await this.transactionRepo.save(tx);

    user.pendingGrandChildPoints = 0;
    user.walletBalance += points;
    user.weeklyPoints += points;
    await this.userRepo.save(user);

    return {
      level: 'grandchild',
      pointsCollected: points,
      newBalance: user.walletBalance,
    };
  }

  async getInviteLink(userId: string): Promise<InviteLinkDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    return {
      inviteLink: `https://manyboost.io/invite/${user.referralCode}`,
      referralCode: user.referralCode,
    };
  }
}
