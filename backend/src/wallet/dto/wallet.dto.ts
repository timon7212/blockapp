import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsEnum } from 'class-validator';
import { PaginationQueryDto, PaginationMeta } from '../../common/dto/pagination.dto';

export enum TransactionType {
  SCREEN_TIME = 'screen_time',
  POINTS_COLLECTED = 'points_collected',
  SPIN_WHEEL = 'spin_wheel',
  GAME = 'game',
  TASK = 'task',
  SURVEY = 'survey',
  REFERRAL = 'referral',
  GIFT_CARD_PURCHASE = 'gift_card_purchase',
  CASH_OUT = 'cash_out',
  DONATION = 'donation',
  RAFFLE_WIN = 'raffle_win',
}

export class WalletDto {
  @ApiProperty({ description: 'Total points in wallet (available to spend)' })
  totalPoints: number;

  @ApiProperty({ description: 'Points collected today' })
  todayPoints: number;

  @ApiProperty({ description: 'Referral points earned today' })
  todayReferralPoints: number;

  @ApiProperty({ description: 'Uncollected points waiting to be claimed (capped)' })
  uncollectedPoints: number;

  @ApiProperty({ description: 'All-time total points earned (sum of all positive transactions)' })
  allTimePointsEarned: number;
}

export class TransactionDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  description: string;

  @ApiProperty({ description: 'Positive = earned, negative = spent' })
  points: number;

  @ApiProperty()
  timestamp: Date;

  @ApiProperty({ enum: TransactionType })
  type: TransactionType;
}

export class TransactionQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ enum: TransactionType, description: 'Filter by transaction type' })
  @IsOptional()
  @IsEnum(TransactionType)
  type?: TransactionType;
}

export class PaginatedTransactionsDto {
  @ApiProperty({ type: [TransactionDto] })
  data: TransactionDto[];

  @ApiProperty()
  meta: PaginationMeta;
}
