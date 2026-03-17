import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiCreatedResponse, ApiOkResponse } from '@nestjs/swagger';
import {
  ScreenTimeSyncDto,
  ScreenTimeSyncResponseDto,
  CollectPointsResponseDto,
  SpinPrizeDto,
  SpinWheelResponseDto,
  RecordAdViewDto,
  RecordAdViewResponseDto,
} from './dto/events.dto';
import { EventsService } from './events.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Events')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('events')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Post('screen-time')
  @ApiOperation({
    summary: 'Sync social media screen time',
    description:
      'The mobile app periodically reports how many minutes the user spent on each social media app. ' +
      'Backend awards 1 point per minute (configurable) up to the point cap. ' +
      'When the cap is reached, a push notification is sent to collect points. ' +
      'Every 30 minutes of usage unlocks a spin wheel opportunity (up to 4 spins). ' +
      'The response includes how many spins are currently available.',
  })
  @ApiCreatedResponse({ type: ScreenTimeSyncResponseDto })
  async syncScreenTime(
    @CurrentUser('id') userId: string,
    @Body() dto: ScreenTimeSyncDto,
  ): Promise<ScreenTimeSyncResponseDto> {
    return this.eventsService.syncScreenTime(userId, dto.usage);
  }

  @Post('collect')
  @ApiOperation({
    summary: 'Watch an ad and collect accumulated points',
    description:
      'User must watch a rewarded ad before collecting. The client sends ad verification data, ' +
      'backend validates the ad was watched (via server-side verification), then moves uncollected ' +
      'points into the wallet. Points stop accumulating at the cap until collected.',
  })
  @ApiCreatedResponse({ type: CollectPointsResponseDto })
  async collectPoints(
    @CurrentUser('id') userId: string,
  ): Promise<CollectPointsResponseDto> {
    return this.eventsService.collectPoints(userId);
  }

  @Post('ad-view')
  @ApiOperation({
    summary: 'Record an ad view',
    description:
      'Called each time the user watches an ad, regardless of context. ' +
      'Ad views are counted toward raffle prerequisites.',
  })
  @ApiCreatedResponse({ type: RecordAdViewResponseDto })
  async recordAdView(
    @CurrentUser('id') userId: string,
    @Body() dto: RecordAdViewDto,
  ): Promise<RecordAdViewResponseDto> {
    return this.eventsService.recordAdView(userId, dto.adType, dto.context);
  }

  @Get('spin-prizes')
  @ApiOperation({
    summary: 'Get current spin wheel prizes',
    description:
      'Returns the list of active spin wheel prizes with their labels, types, values, and weights. ' +
      'Use this to render the wheel segments in the app.',
  })
  @ApiOkResponse({ type: [SpinPrizeDto] })
  async getSpinPrizes(): Promise<SpinPrizeDto[]> {
    return this.eventsService.getSpinPrizesForUser();
  }

  @Post('spin')
  @ApiOperation({
    summary: 'Watch an ad and spin the wheel',
    description:
      'Every 30 minutes of social media usage earns one spin opportunity (up to 4). ' +
      'Each spin requires watching a rewarded ad first. Prizes include bonus points, ' +
      'multipliers, extra point cap, or nothing. A push notification is sent when a ' +
      'new spin becomes available.',
  })
  @ApiCreatedResponse({ type: SpinWheelResponseDto })
  async spinWheel(
    @CurrentUser('id') userId: string,
  ): Promise<SpinWheelResponseDto> {
    return this.eventsService.spinWheel(userId);
  }
}
