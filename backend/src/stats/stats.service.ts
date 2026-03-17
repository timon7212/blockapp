import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { UserEntity } from '../auth/entities/user.entity';
import { ScreenTimeRecordEntity } from '../events/entities/screen-time-record.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import {
  DailyStatsDto,
  WeeklyStatsEntryDto,
  StreakDto,
  ReferralStatsOverviewDto,
} from './dto/stats.dto';

@Injectable()
export class StatsService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(ScreenTimeRecordEntity)
    private readonly screenTimeRepo: Repository<ScreenTimeRecordEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
  ) {}

  async getDailyStats(userId: string): Promise<DailyStatsDto> {
    const today = new Date().toISOString().split('T')[0];

    const records = await this.screenTimeRepo.find({
      where: { userId, date: today },
    });

    const appMap = new Map<string, number>();
    for (const r of records) {
      appMap.set(r.appId, (appMap.get(r.appId) ?? 0) + r.minutes);
    }

    const appBreakdown = Array.from(appMap.entries()).map(
      ([appId, minutes]) => ({
        appId,
        appName: appId,
        minutes,
      }),
    );

    const screenTimeMinutes = records.reduce((s, r) => s + r.minutes, 0);

    const user = await this.userRepo.findOneByOrFail({ id: userId });

    const todayStart = new Date(`${today}T00:00:00`);
    const todayEnd = new Date(`${today}T23:59:59.999`);

    const todayTransactions = await this.transactionRepo.find({
      where: { userId, createdAt: Between(todayStart, todayEnd) },
    });

    const pointsEarned = todayTransactions
      .filter((t) => t.type === TransactionType.SCREEN_TIME)
      .reduce((s, t) => s + t.points, 0);

    const pointsCollected = todayTransactions
      .filter((t) => t.type === TransactionType.POINTS_COLLECTED)
      .reduce((s, t) => s + t.points, 0);

    return {
      screenTimeMinutes,
      pointsEarned,
      pointsCollected,
      uncollectedPoints: user.uncollectedPoints,
      appBreakdown,
      date: new Date(today),
    };
  }

  async getWeeklyStats(userId: string): Promise<WeeklyStatsEntryDto[]> {
    const today = new Date();
    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const results: WeeklyStatsEntryDto[] = [];

    for (let i = 6; i >= 0; i--) {
      const d = new Date(today);
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];

      const records = await this.screenTimeRepo.find({
        where: { userId, date: dateStr },
      });
      const minutes = records.reduce((s, r) => s + r.minutes, 0);

      const dayStart = new Date(`${dateStr}T00:00:00`);
      const dayEnd = new Date(`${dateStr}T23:59:59.999`);
      const transactions = await this.transactionRepo.find({
        where: { userId, createdAt: Between(dayStart, dayEnd) },
      });
      const points = transactions.reduce((s, t) => s + t.points, 0);

      results.push({
        dayLabel: dayLabels[d.getDay()],
        minutes,
        points,
        isToday: i === 0,
      });
    }

    return results;
  }

  async getReferralStats(userId: string): Promise<ReferralStatsOverviewDto> {
    const directInvites = await this.userRepo.count({
      where: { referredById: userId },
    });

    const directInviteeIds = await this.userRepo.find({
      where: { referredById: userId },
      select: ['id'],
    });

    let grandChildInvites = 0;
    for (const invitee of directInviteeIds) {
      grandChildInvites += await this.userRepo.count({
        where: { referredById: invitee.id },
      });
    }

    return {
      directInvites,
      grandChildInvites,
      totalInvites: directInvites + grandChildInvites,
    };
  }

  async getStreak(userId: string): Promise<StreakDto> {
    const user = await this.userRepo.findOneByOrFail({ id: userId });
    const today = new Date().toISOString().split('T')[0];

    const milestones = [3, 7, 14, 30, 60, 100];
    const next = milestones.find((m) => m > user.currentStreak);
    const nextMilestoneLabel = next
      ? `${next}-day streak`
      : `${user.currentStreak}-day streak (max milestone reached)`;

    return {
      currentStreak: user.currentStreak,
      longestStreak: user.longestStreak,
      multiplier: user.bonusMultiplier,
      collectedToday: user.lastCollectionDate === today,
      nextMilestoneLabel,
    };
  }
}
