import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiProperty, ApiOkResponse } from '@nestjs/swagger';

export class SpinWheelPrizeConfigDto {
  @ApiProperty({ description: 'Prize label shown on the wheel segment' })
  label: string;

  @ApiProperty({ description: 'points | bonus_multiplier | extra_cap | nothing' })
  type: string;

  @ApiProperty({ description: 'Prize value (e.g. 50, 1.5, 200, 0)' })
  value: number;

  @ApiProperty({ description: 'Probability weight (higher = more likely)' })
  weight: number;
}

export class SpinWheelConfigDto {
  @ApiProperty({ description: 'Minutes of social media usage between each spin opportunity' })
  intervalMinutes: number;

  @ApiProperty({ description: 'Maximum spins the user can accumulate' })
  maxSpins: number;

  @ApiProperty({ type: [SpinWheelPrizeConfigDto] })
  prizes: SpinWheelPrizeConfigDto[];
}

export class ReferralConfigDto {
  @ApiProperty({ description: 'Max referral tree depth (3 = children + grandchildren)' })
  maxDepth: number;

  @ApiProperty({ description: 'Commission percentage from direct invitees (children)' })
  childCommissionPercent: number;

  @ApiProperty({ description: 'Commission percentage from grandchildren' })
  grandChildCommissionPercent: number;
}

export class AppConfigDto {
  @ApiProperty({ description: 'Points earned per minute of social media screen time' })
  pointsPerMinute: number;

  @ApiProperty({ description: 'Maximum uncollected points (stops accumulating at this cap)' })
  pointCap: number;

  @ApiProperty({ description: 'Whether to send push notification when point cap is reached' })
  notifyOnCap: boolean;

  @ApiProperty({ description: 'Minimum point balance required to cash out' })
  cashOutMinBalance: number;

  @ApiProperty({ description: 'Minimum point balance required for a gift card' })
  giftCardMinBalance: number;

  @ApiProperty({ type: SpinWheelConfigDto })
  spinWheel: SpinWheelConfigDto;

  @ApiProperty({ type: ReferralConfigDto })
  referral: ReferralConfigDto;

  @ApiProperty({ description: 'Minimum app version required' })
  minAppVersion: string;

  @ApiProperty({ description: 'Feature flags as key-value pairs' })
  featureFlags: Record<string, boolean>;
}

@ApiTags('Config')
@Controller('config')
export class ConfigController {
  @Get()
  @ApiOperation({
    summary: 'Get remote app configuration',
    description:
      'Returns economy constants, referral config, feature flags, and minimum app version. ' +
      'No auth required — fetched on app startup.',
  })
  @ApiOkResponse({ type: AppConfigDto })
  async getConfig(): Promise<AppConfigDto> {
    return {
      pointsPerMinute: 1,
      pointCap: 1000,
      notifyOnCap: true,
      cashOutMinBalance: 10000,
      giftCardMinBalance: 5000,
      spinWheel: {
        intervalMinutes: 30,
        maxSpins: 4,
        prizes: [
          { label: '50 Points', type: 'points', value: 50, weight: 30 },
          { label: '100 Points', type: 'points', value: 100, weight: 20 },
          { label: '200 Points', type: 'points', value: 200, weight: 10 },
          { label: '1.5x Bonus', type: 'bonus_multiplier', value: 1.5, weight: 10 },
          { label: '2x Bonus', type: 'bonus_multiplier', value: 2, weight: 5 },
          { label: '+200 Cap', type: 'extra_cap', value: 200, weight: 10 },
          { label: 'Try Again', type: 'nothing', value: 0, weight: 15 },
        ],
      },
      referral: {
        maxDepth: 3,
        childCommissionPercent: 10,
        grandChildCommissionPercent: 5,
      },
      minAppVersion: '1.0.0',
      featureFlags: {},
    };
  }
}
