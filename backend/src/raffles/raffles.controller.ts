import { Controller, Get, Post, Param, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiCreatedResponse } from '@nestjs/swagger';
import {
  RaffleDto,
  RaffleEntryDto,
  RaffleResultDto,
  RaffleEntryResponseDto,
  RaffleHistoryQueryDto,
  PaginatedRaffleHistoryDto,
  RaffleDrawResultDto,
  RaffleWinnersQueryDto,
  PaginatedRaffleWinnersDto,
} from './dto/raffles.dto';
import { RafflesService } from './raffles.service';
import { RaffleCronService } from './raffle-cron.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Raffles')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('raffles')
export class RafflesController {
  constructor(
    private readonly rafflesService: RafflesService,
    private readonly raffleCronService: RaffleCronService,
  ) {}

  @Get()
  @ApiOperation({
    summary: 'List active raffles with eligibility status',
    description:
      'Returns active raffles with prerequisite details. ' +
      'Each prerequisite shows the type, required count, and user progress.',
  })
  @ApiOkResponse({ type: [RaffleDto] })
  async getActiveRaffles(
    @CurrentUser('id') userId: string,
  ): Promise<RaffleDto[]> {
    return this.rafflesService.getActiveRaffles(userId);
  }

  @Get('history/me')
  @ApiOperation({ summary: "Get user's paginated past raffle results" })
  @ApiOkResponse({ type: PaginatedRaffleHistoryDto })
  async getRaffleHistory(
    @CurrentUser('id') userId: string,
    @Query() query: RaffleHistoryQueryDto,
  ): Promise<PaginatedRaffleHistoryDto> {
    return this.rafflesService.getRaffleHistory(userId, query);
  }

  @Get('winners')
  @ApiOperation({
    summary: 'Get past raffle winners leaderboard',
    description:
      'Returns a paginated list of past raffle winners, optionally filtered by raffle type (daily/weekly/monthly).',
  })
  @ApiOkResponse({ type: PaginatedRaffleWinnersDto })
  async getWinners(
    @Query() query: RaffleWinnersQueryDto,
  ): Promise<PaginatedRaffleWinnersDto> {
    return this.rafflesService.getWinners(query);
  }

  @Post('draw')
  @ApiOperation({
    summary: 'Manually trigger raffle draw for all expired raffles',
    description:
      'Draws winners for any active raffle whose drawDate has passed. ' +
      'Normally handled automatically by the cron job every minute.',
  })
  @ApiCreatedResponse({ type: RaffleDrawResultDto })
  async triggerDraw(): Promise<RaffleDrawResultDto> {
    await this.raffleCronService.handleRaffleDraw();
    return { triggered: true };
  }

  @Get(':raffleId')
  @ApiOperation({ summary: 'Get raffle detail with prerequisite status' })
  @ApiOkResponse({ type: RaffleDto })
  async getRaffle(
    @CurrentUser('id') userId: string,
    @Param('raffleId') raffleId: string,
  ): Promise<RaffleDto> {
    return this.rafflesService.getRaffle(raffleId, userId);
  }

  @Post(':raffleId/enter')
  @ApiOperation({
    summary: 'Enter a raffle (requires ad + prerequisites)',
    description:
      'User must meet all prerequisites (ad views, tasks, surveys, games) ' +
      'and watch a rewarded ad to enter. Each raffle can only be entered once.',
  })
  @ApiCreatedResponse({ type: RaffleEntryResponseDto })
  async enterRaffle(
    @CurrentUser('id') userId: string,
    @Param('raffleId') raffleId: string,
    @Body() dto: RaffleEntryDto,
  ): Promise<RaffleEntryResponseDto> {
    return this.rafflesService.enterRaffle(userId, raffleId);
  }

  @Get(':raffleId/result')
  @ApiOperation({ summary: 'Get raffle draw result' })
  @ApiOkResponse({ type: RaffleResultDto })
  async getRaffleResult(
    @CurrentUser('id') userId: string,
    @Param('raffleId') raffleId: string,
  ): Promise<RaffleResultDto> {
    return this.rafflesService.getRaffleResult(raffleId, userId);
  }
}
