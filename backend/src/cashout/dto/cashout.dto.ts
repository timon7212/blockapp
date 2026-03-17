import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsInt, Min } from 'class-validator';
import { PaginationQueryDto, PaginationMeta } from '../../common/dto/pagination.dto';

export class CashOutRequestDto {
  @ApiProperty({ minimum: 10000 })
  @IsInt()
  @Min(10000)
  coinAmount: number;

  @ApiProperty({ description: 'paypal | bank_transfer | crypto' })
  @IsString()
  paymentMethod: string;

  @ApiProperty({ description: 'Email, IBAN, or wallet address depending on method' })
  @IsString()
  paymentDetails: string;
}

export class CashOutResponseDto {
  @ApiProperty()
  success: boolean;

  @ApiProperty()
  cashOutId: string;

  @ApiProperty()
  coinAmount: number;

  @ApiProperty()
  cashValue: number;

  @ApiProperty()
  newBalance: number;

  @ApiProperty({ description: 'pending | processing | completed | failed' })
  status: string;
}

export class CashOutHistoryDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  coinAmount: number;

  @ApiProperty()
  cashValue: number;

  @ApiProperty()
  paymentMethod: string;

  @ApiProperty({ description: 'pending | processing | completed | failed' })
  status: string;

  @ApiProperty()
  requestedAt: Date;

  @ApiProperty({ nullable: true })
  completedAt: Date | null;
}

export class CashOutHistoryQueryDto extends PaginationQueryDto {}

export class PaginatedCashOutHistoryDto {
  @ApiProperty({ type: [CashOutHistoryDto] })
  data: CashOutHistoryDto[];

  @ApiProperty()
  meta: PaginationMeta;
}
