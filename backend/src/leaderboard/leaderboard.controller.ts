import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse } from '@nestjs/swagger';
import {
  LeaderboardQueryDto,
  PaginatedLeaderboardDto,
  UserRankDto,
} from './dto/leaderboard.dto';
import { LeaderboardService } from './leaderboard.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Leaderboard')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('leaderboard')
export class LeaderboardController {
  constructor(private readonly leaderboardService: LeaderboardService) {}

  @Get('weekly')
  @ApiOperation({ summary: 'Get paginated weekly leaderboard' })
  @ApiOkResponse({ type: PaginatedLeaderboardDto })
  async getWeeklyLeaderboard(
    @Query() query: LeaderboardQueryDto,
  ): Promise<PaginatedLeaderboardDto> {
    return this.leaderboardService.getWeeklyLeaderboard(query);
  }

  @Get('weekly/me')
  @ApiOperation({ summary: "Get current user's rank and surrounding users" })
  @ApiOkResponse({ type: UserRankDto })
  async getUserRank(
    @CurrentUser('id') userId: string,
  ): Promise<UserRankDto> {
    return this.leaderboardService.getUserRank(userId);
  }
}
