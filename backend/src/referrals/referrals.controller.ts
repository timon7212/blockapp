import {
  Controller,
  Get,
  Post,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiOkResponse,
} from '@nestjs/swagger';
import {
  ReferralStatsDto,
  CollectReferralResponseDto,
  InviteLinkDto,
  InviteeDto,
} from './dto/referrals.dto';
import { ReferralsService } from './referrals.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Referrals')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('referrals')
export class ReferralsController {
  constructor(private readonly referralsService: ReferralsService) {}

  @Get()
  @ApiOperation({
    summary: 'Get referral stats',
    description:
      'Returns direct invitee count, grandchild count, commission rates, ' +
      'pending points for each level, and lifetime total. ' +
      'Referral depth is 3 — you earn from direct invitees (children) and their invitees (grandchildren).',
  })
  @ApiOkResponse({ type: ReferralStatsDto })
  async getReferralStats(
    @CurrentUser('id') userId: string,
  ): Promise<ReferralStatsDto> {
    return this.referralsService.getReferralStats(userId);
  }

  @Get('invitees')
  @ApiOperation({
    summary: 'List invitees (children and grandchildren)',
  })
  @ApiOkResponse({ type: [InviteeDto] })
  async getInvitees(
    @CurrentUser('id') userId: string,
  ): Promise<InviteeDto[]> {
    return this.referralsService.getInvitees(userId);
  }

  @Post('collect/children')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Collect pending child referral points (requires ad)',
    description:
      'Moves pending referral points earned from direct invitees into the wallet. ' +
      'Client must show a rewarded ad before calling this endpoint.',
  })
  @ApiOkResponse({ type: CollectReferralResponseDto })
  async collectChildPoints(
    @CurrentUser('id') userId: string,
  ): Promise<CollectReferralResponseDto> {
    return this.referralsService.collectChildPoints(userId);
  }

  @Post('collect/grandchildren')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Collect pending grandchild referral points (requires ad)',
    description:
      'Moves pending referral points earned from grandchildren into the wallet. ' +
      'Client must show a rewarded ad before calling this endpoint.',
  })
  @ApiOkResponse({ type: CollectReferralResponseDto })
  async collectGrandChildPoints(
    @CurrentUser('id') userId: string,
  ): Promise<CollectReferralResponseDto> {
    return this.referralsService.collectGrandChildPoints(userId);
  }

  @Get('invite-link')
  @ApiOperation({ summary: 'Get or generate invite deep link' })
  @ApiOkResponse({ type: InviteLinkDto })
  async getInviteLink(
    @CurrentUser('id') userId: string,
  ): Promise<InviteLinkDto> {
    return this.referralsService.getInviteLink(userId);
  }
}
