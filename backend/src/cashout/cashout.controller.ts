import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiCreatedResponse } from '@nestjs/swagger';
import {
  CashOutRequestDto,
  CashOutResponseDto,
  CashOutHistoryQueryDto,
  PaginatedCashOutHistoryDto,
} from './dto/cashout.dto';
import { CashOutService } from './cashout.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Cash Out')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('cashout')
export class CashOutController {
  constructor(private readonly cashOutService: CashOutService) {}

  @Post()
  @ApiOperation({
    summary: 'Request cash out',
    description:
      'Minimum 10,000 coins. Exchange rate: 1,000 coins = $1.00. ' +
      'Processing time: 1-3 business days.',
  })
  @ApiCreatedResponse({ type: CashOutResponseDto })
  async requestCashOut(
    @CurrentUser('id') userId: string,
    @Body() dto: CashOutRequestDto,
  ): Promise<CashOutResponseDto> {
    return this.cashOutService.requestCashOut(userId, dto);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get paginated cash out history' })
  @ApiOkResponse({ type: PaginatedCashOutHistoryDto })
  async getHistory(
    @CurrentUser('id') userId: string,
    @Query() query: CashOutHistoryQueryDto,
  ): Promise<PaginatedCashOutHistoryDto> {
    return this.cashOutService.getHistory(userId, query);
  }
}
