import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse } from '@nestjs/swagger';
import { DailyStatsDto, WeeklyStatsEntryDto, StreakDto, ReferralStatsOverviewDto } from './dto/stats.dto';
import { StatsService } from './stats.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Stats')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  @Get('stats/daily')
  @ApiOperation({
    summary: "Get today's screen time and points stats",
    description:
      'Returns screen time minutes, points earned, uncollected balance, and per-app breakdown.',
  })
  @ApiOkResponse({ type: DailyStatsDto })
  async getDailyStats(
    @CurrentUser('id') userId: string,
  ): Promise<DailyStatsDto> {
    return this.statsService.getDailyStats(userId);
  }

  @Get('stats/weekly')
  @ApiOperation({
    summary: 'Get weekly screen time and points breakdown (Mon-Sun)',
  })
  @ApiOkResponse({ type: [WeeklyStatsEntryDto] })
  async getWeeklyStats(
    @CurrentUser('id') userId: string,
  ): Promise<WeeklyStatsEntryDto[]> {
    return this.statsService.getWeeklyStats(userId);
  }

  @Get('stats/referrals')
  @ApiOperation({
    summary: 'Get referral invite counts',
    description:
      'Returns how many successful invites the user has made at each level (direct children and grandchildren).',
  })
  @ApiOkResponse({ type: ReferralStatsOverviewDto })
  async getReferralStats(
    @CurrentUser('id') userId: string,
  ): Promise<ReferralStatsOverviewDto> {
    return this.statsService.getReferralStats(userId);
  }

  @Get('streak')
  @ApiOperation({
    summary: 'Get collection streak info',
    description:
      'Streak tracks consecutive days the user has collected their points.',
  })
  @ApiOkResponse({ type: StreakDto })
  async getStreak(@CurrentUser('id') userId: string): Promise<StreakDto> {
    return this.statsService.getStreak(userId);
  }
}
