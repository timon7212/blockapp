import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { WalletService } from './wallet.service';
import {
  WalletDto,
  TransactionQueryDto,
  PaginatedTransactionsDto,
} from './dto/wallet.dto';

@ApiTags('Wallet')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('wallet')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Get()
  @ApiOperation({
    summary: 'Get point balance',
    description:
      'Returns total points in wallet, today points, referral points, and uncollected points.',
  })
  @ApiOkResponse({ type: WalletDto })
  async getBalance(@CurrentUser('id') userId: string): Promise<WalletDto> {
    return this.walletService.getBalance(userId);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Get paginated transaction ledger' })
  @ApiOkResponse({ type: PaginatedTransactionsDto })
  async getTransactions(
    @CurrentUser('id') userId: string,
    @Query() query: TransactionQueryDto,
  ): Promise<PaginatedTransactionsDto> {
    return this.walletService.getTransactions(userId, query);
  }
}
