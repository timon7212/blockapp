import { ApiProperty } from '@nestjs/swagger';

export class DailyStatsDto {
  @ApiProperty({ description: 'Total social media minutes tracked today' })
  screenTimeMinutes: number;

  @ApiProperty({ description: 'Points earned from screen time today' })
  pointsEarned: number;

  @ApiProperty({ description: 'Points collected (moved to wallet) today' })
  pointsCollected: number;

  @ApiProperty({ description: 'Current uncollected points (capped)' })
  uncollectedPoints: number;

  @ApiProperty({ description: 'Per-app breakdown of screen time' })
  appBreakdown: AppScreenTimeDto[];

  @ApiProperty()
  date: Date;
}

export class AppScreenTimeDto {
  @ApiProperty()
  appId: string;

  @ApiProperty()
  appName: string;

  @ApiProperty({ description: 'Minutes spent today' })
  minutes: number;
}

export class WeeklyStatsEntryDto {
  @ApiProperty()
  dayLabel: string;

  @ApiProperty({ description: 'Screen time minutes for this day' })
  minutes: number;

  @ApiProperty({ description: 'Points earned this day' })
  points: number;

  @ApiProperty()
  isToday: boolean;
}

export class ReferralStatsOverviewDto {
  @ApiProperty({ description: 'Number of successful direct invites (children)' })
  directInvites: number;

  @ApiProperty({ description: 'Number of grandchild invites (invitees of your invitees)' })
  grandChildInvites: number;

  @ApiProperty({ description: 'Total invites across both levels' })
  totalInvites: number;
}

export class StreakDto {
  @ApiProperty({ description: 'Consecutive days the user has collected points' })
  currentStreak: number;

  @ApiProperty()
  longestStreak: number;

  @ApiProperty({ description: 'Bonus multiplier based on collection streak' })
  multiplier: number;

  @ApiProperty({ description: 'Whether user has collected points today' })
  collectedToday: boolean;

  @ApiProperty()
  nextMilestoneLabel: string;
}
