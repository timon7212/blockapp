import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { UserEntity } from '../auth/entities/user.entity';
import { ScreenTimeRecordEntity } from './entities/screen-time-record.entity';
import { AdViewEntity } from './entities/ad-view.entity';
import {
  SpinPrizeEntity,
  SpinPrizeType as SpinPrizeTypeEnum,
} from './entities/spin-prize.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import { SpinPrizeType } from './dto/events.dto';

interface SpinPrize {
  label: string;
  type: SpinPrizeType;
  value: number;
  weight: number;
}

const DEFAULT_PRIZES: SpinPrize[] = [
  { label: '50 Points', type: SpinPrizeType.POINTS, value: 50, weight: 30 },
  { label: '100 Points', type: SpinPrizeType.POINTS, value: 100, weight: 20 },
  { label: '200 Points', type: SpinPrizeType.POINTS, value: 200, weight: 10 },
  { label: '1.5x Bonus', type: SpinPrizeType.BONUS_MULTIPLIER, value: 1.5, weight: 10 },
  { label: '2x Bonus', type: SpinPrizeType.BONUS_MULTIPLIER, value: 2, weight: 5 },
  { label: '+200 Cap', type: SpinPrizeType.EXTRA_CAP, value: 200, weight: 10 },
  { label: 'Try Again', type: SpinPrizeType.NOTHING, value: 0, weight: 15 },
];

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(ScreenTimeRecordEntity)
    private readonly screenTimeRepo: Repository<ScreenTimeRecordEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
    @InjectRepository(AdViewEntity)
    private readonly adViewRepo: Repository<AdViewEntity>,
    @InjectRepository(SpinPrizeEntity)
    private readonly spinPrizeRepo: Repository<SpinPrizeEntity>,
    private readonly config: ConfigService,
  ) {}

  async syncScreenTime(
    userId: string,
    usage: { appId: string; minutes: number }[],
  ) {
    const today = new Date().toISOString().split('T')[0];

    const records = usage.map((entry) =>
      this.screenTimeRepo.create({
        userId,
        appId: entry.appId,
        minutes: entry.minutes,
        date: today,
      }),
    );
    await this.screenTimeRepo.save(records);

    const totalMinutes = usage.reduce((sum, e) => sum + e.minutes, 0);
    const pointsPerMinute = this.config.get<number>('POINTS_PER_MINUTE', 1);
    const points = totalMinutes * pointsPerMinute;

    const user = await this.userRepo.findOneByOrFail({ id: userId });
    user.totalScreenTimeMinutes += totalMinutes;

    const pointCap = this.config.get<number>('POINT_CAP', 1000);
    const effectiveCap = pointCap + user.extraCap;
    const newUncollected = Math.min(
      user.uncollectedPoints + points,
      effectiveCap,
    );
    const pointsActuallyEarned = newUncollected - user.uncollectedPoints;
    user.uncollectedPoints = newUncollected;

    const spinInterval = this.config.get<number>('SPIN_INTERVAL_MINUTES', 30);
    const maxSpins = this.config.get<number>('MAX_SPINS', 4);
    user.spinsAvailable = Math.min(
      Math.floor(user.totalScreenTimeMinutes / spinInterval),
      maxSpins,
    );

    await this.userRepo.save(user);

    return {
      totalMinutes,
      pointsEarned: pointsActuallyEarned,
      uncollectedPoints: newUncollected,
      capReached: newUncollected >= effectiveCap,
      spinsAvailable: user.spinsAvailable,
    };
  }

  async collectPoints(userId: string) {
    const user = await this.userRepo.findOneByOrFail({ id: userId });

    if (user.uncollectedPoints <= 0) {
      throw new BadRequestException('No points to collect');
    }

    const pointsToCollect = Math.floor(
      user.uncollectedPoints * user.bonusMultiplier,
    );

    const transaction = this.transactionRepo.create({
      userId,
      type: TransactionType.POINTS_COLLECTED,
      points: pointsToCollect,
      description: 'Points collected',
    });
    await this.transactionRepo.save(transaction);

    user.walletBalance += pointsToCollect;
    user.weeklyPoints += pointsToCollect;

    const today = new Date().toISOString().split('T')[0];
    if (user.lastCollectionDate) {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];

      if (user.lastCollectionDate === yesterdayStr) {
        user.currentStreak += 1;
      } else if (user.lastCollectionDate !== today) {
        user.currentStreak = 1;
      }
    } else {
      user.currentStreak = 1;
    }

    if (user.currentStreak > user.longestStreak) {
      user.longestStreak = user.currentStreak;
    }

    user.lastCollectionDate = today;
    user.uncollectedPoints = 0;
    user.bonusMultiplier = 1;
    user.extraCap = 0;

    await this.userRepo.save(user);

    await this.creditReferralPoints(user, pointsToCollect);

    return {
      pointsCollected: pointsToCollect,
      newBalance: user.walletBalance,
      uncollectedPoints: 0,
    };
  }

  private async getSpinPrizes(): Promise<SpinPrize[]> {
    const dbPrizes = await this.spinPrizeRepo.find({
      where: { active: true },
    });

    if (dbPrizes.length === 0) return DEFAULT_PRIZES;

    return dbPrizes.map((p) => ({
      label: p.label,
      type: p.type as unknown as SpinPrizeType,
      value: p.value,
      weight: p.weight,
    }));
  }

  private async creditReferralPoints(
    user: UserEntity,
    pointsCollected: number,
  ): Promise<void> {
    const childRate = this.config.get<number>('REFERRAL_CHILD_PERCENT', 10) / 100;
    const grandChildRate =
      this.config.get<number>('REFERRAL_GRANDCHILD_PERCENT', 5) / 100;

    if (user.referredById) {
      const parent = await this.userRepo.findOne({
        where: { id: user.referredById },
      });
      if (parent) {
        const childBonus = Math.floor(pointsCollected * childRate);
        if (childBonus > 0) {
          parent.pendingChildPoints += childBonus;
          await this.userRepo.save(parent);
        }

        if (parent.referredById) {
          const grandParent = await this.userRepo.findOne({
            where: { id: parent.referredById },
          });
          if (grandParent) {
            const grandChildBonus = Math.floor(pointsCollected * grandChildRate);
            if (grandChildBonus > 0) {
              grandParent.pendingGrandChildPoints += grandChildBonus;
              await this.userRepo.save(grandParent);
            }
          }
        }
      }
    }
  }

  async spinWheel(userId: string) {
    const user = await this.userRepo.findOneByOrFail({ id: userId });

    if (user.spinsAvailable <= 0) {
      throw new BadRequestException('No spins available');
    }

    const prizes = await this.getSpinPrizes();
    const prize = this.weightedRandom(prizes);

    switch (prize.type) {
      case SpinPrizeType.POINTS: {
        const tx = this.transactionRepo.create({
          userId,
          type: TransactionType.SPIN_WHEEL,
          points: prize.value,
          description: `Spin wheel: ${prize.label}`,
        });
        await this.transactionRepo.save(tx);
        user.walletBalance += prize.value;
        user.weeklyPoints += prize.value;
        break;
      }
      case SpinPrizeType.BONUS_MULTIPLIER:
        user.bonusMultiplier = prize.value;
        break;
      case SpinPrizeType.EXTRA_CAP:
        user.extraCap += prize.value;
        break;
      case SpinPrizeType.NOTHING:
        break;
    }

    user.spinsAvailable -= 1;
    await this.userRepo.save(user);

    return {
      prizeType: prize.type,
      prizeValue: prize.value,
      prizeLabel: prize.label,
      newBalance: user.walletBalance,
      spinsRemaining: user.spinsAvailable,
    };
  }

  async getSpinPrizesForUser() {
    const dbPrizes = await this.spinPrizeRepo.find({
      where: { active: true },
      order: { weight: 'DESC' },
    });

    if (dbPrizes.length > 0) {
      return dbPrizes.map((p) => ({
        id: p.id,
        label: p.label,
        type: p.type as unknown as SpinPrizeType,
        value: p.value,
        weight: p.weight,
      }));
    }

    return DEFAULT_PRIZES.map((p, i) => ({
      id: `default-${i}`,
      label: p.label,
      type: p.type,
      value: p.value,
      weight: p.weight,
    }));
  }

  async recordAdView(userId: string, adType: string, context?: string) {
    const adView = this.adViewRepo.create({ userId, adType, context });
    await this.adViewRepo.save(adView);

    const totalAdViews = await this.adViewRepo.count({ where: { userId } });

    return { recorded: true, totalAdViews };
  }

  private weightedRandom(prizes: SpinPrize[]): SpinPrize {
    const totalWeight = prizes.reduce((sum, p) => sum + p.weight, 0);
    let roll = Math.random() * totalWeight;
    for (const prize of prizes) {
      roll -= prize.weight;
      if (roll <= 0) return prize;
    }
    return prizes[prizes.length - 1];
  }
}
