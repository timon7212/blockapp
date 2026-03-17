import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsInt, IsArray, IsOptional, Min, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

// ── Screen-time sync ──

export class AppUsageEntryDto {
  @ApiProperty({ description: 'App bundle ID or package name (e.g. com.instagram.android)' })
  @IsString()
  appId: string;

  @ApiProperty({ description: 'Minutes spent on this app since last sync' })
  @IsInt()
  @Min(0)
  minutes: number;
}

export class ScreenTimeSyncDto {
  @ApiProperty({
    type: [AppUsageEntryDto],
    description: 'Per-app screen time since last sync',
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AppUsageEntryDto)
  usage: AppUsageEntryDto[];
}

export class ScreenTimeSyncResponseDto {
  @ApiProperty({ description: 'Total minutes recorded in this sync' })
  totalMinutes: number;

  @ApiProperty({ description: 'Points earned from this sync' })
  pointsEarned: number;

  @ApiProperty({ description: 'Current uncollected points (capped at pointCap)' })
  uncollectedPoints: number;

  @ApiProperty({ description: 'Whether the point cap has been reached' })
  capReached: boolean;

  @ApiProperty({ description: 'Number of spin opportunities available right now' })
  spinsAvailable: number;
}

// ── Record ad view ──

export class RecordAdViewDto {
  @ApiProperty({ description: 'Ad format watched (e.g. rewarded, interstitial)' })
  @IsString()
  adType: string;

  @ApiPropertyOptional({ description: 'Context where the ad was shown (e.g. collect, spin, raffle, standalone)' })
  @IsOptional()
  @IsString()
  context?: string;
}

export class RecordAdViewResponseDto {
  @ApiProperty()
  recorded: boolean;

  @ApiProperty({ description: 'Total ad views for this user' })
  totalAdViews: number;
}

// ── Collect points (requires ad) ──

export class AdVerificationDto {
  @ApiProperty({ description: 'Ad format watched (e.g. rewarded)' })
  @IsString()
  adType: string;

  @ApiPropertyOptional({ description: 'Ad network identifier for server-side verification' })
  @IsOptional()
  @IsString()
  adNetworkId?: string;

  @ApiPropertyOptional({ description: 'Ad unit ID for server-side verification' })
  @IsOptional()
  @IsString()
  adUnitId?: string;
}

export class CollectPointsDto extends AdVerificationDto {}

export class CollectPointsResponseDto {
  @ApiProperty({ description: 'Points collected (moved from uncollected to wallet)' })
  pointsCollected: number;

  @ApiProperty({ description: 'New wallet balance after collection' })
  newBalance: number;

  @ApiProperty({ description: 'Uncollected points after collection (should be 0)' })
  uncollectedPoints: number;
}

// ── Spin wheel (requires ad each spin) ──

export enum SpinPrizeType {
  POINTS = 'points',
  BONUS_MULTIPLIER = 'bonus_multiplier',
  EXTRA_CAP = 'extra_cap',
  NOTHING = 'nothing',
}

export class SpinPrizeDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ description: 'Display label shown on the wheel segment' })
  label: string;

  @ApiProperty({ enum: SpinPrizeType })
  type: SpinPrizeType;

  @ApiProperty({ description: 'Prize value (points amount, multiplier, extra cap, or 0)' })
  value: number;

  @ApiProperty({ description: 'Relative probability weight' })
  weight: number;
}

export class SpinWheelDto extends AdVerificationDto {}

export class SpinWheelResponseDto {
  @ApiProperty({ enum: SpinPrizeType, description: 'Type of prize won' })
  prizeType: SpinPrizeType;

  @ApiProperty({ description: 'Prize value (e.g. 50 points, 1.5x multiplier, 200 extra cap)' })
  prizeValue: number;

  @ApiProperty({ description: 'Human-readable prize label (e.g. "50 Points")' })
  prizeLabel: string;

  @ApiProperty({ description: 'New wallet balance after prize applied' })
  newBalance: number;

  @ApiProperty({ description: 'Remaining spins in this session' })
  spinsRemaining: number;
}
