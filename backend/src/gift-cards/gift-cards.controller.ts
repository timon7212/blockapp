import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiCreatedResponse } from '@nestjs/swagger';
import {
  GiftCardCatalogQueryDto,
  PaginatedGiftCardsDto,
  RedeemGiftCardDto,
  RedemptionResponseDto,
  RedemptionHistoryQueryDto,
  PaginatedRedemptionHistoryDto,
} from './dto/gift-cards.dto';
import { GiftCardsService } from './gift-cards.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Gift Cards')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('gift-cards')
export class GiftCardsController {
  constructor(private readonly giftCardsService: GiftCardsService) {}

  @Get()
  @ApiOperation({
    summary: 'Get gift card catalog from Tremendous',
    description:
      'Returns paginated merchant gift cards from the Tremendous catalog. ' +
      'Filter by country, currency, or subcategory.',
  })
  @ApiOkResponse({ type: PaginatedGiftCardsDto })
  async getCatalog(
    @Query() query: GiftCardCatalogQueryDto,
  ): Promise<PaginatedGiftCardsDto> {
    return this.giftCardsService.getCatalog(query);
  }

  @Post('redeem')
  @ApiOperation({
    summary: 'Redeem a gift card via Tremendous',
    description:
      'Verifies coin balance, creates a Tremendous order with LINK delivery, ' +
      'debits coins from the user wallet, and returns the redemption link.',
  })
  @ApiCreatedResponse({ type: RedemptionResponseDto })
  async redeem(
    @CurrentUser('id') userId: string,
    @Body() dto: RedeemGiftCardDto,
  ): Promise<RedemptionResponseDto> {
    return this.giftCardsService.redeem(userId, dto);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get paginated gift card redemption history' })
  @ApiOkResponse({ type: PaginatedRedemptionHistoryDto })
  async getHistory(
    @CurrentUser('id') userId: string,
    @Query() query: RedemptionHistoryQueryDto,
  ): Promise<PaginatedRedemptionHistoryDto> {
    return this.giftCardsService.getHistory(userId, query);
  }
}
