import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNumber, IsOptional, Min } from 'class-validator';
import { PaginationQueryDto, PaginationMeta } from '../../common/dto/pagination.dto';

export class GiftCardSkuDto {
  @ApiProperty({ description: 'Minimum denomination in product currency' })
  min: number;

  @ApiProperty({ description: 'Maximum denomination in product currency' })
  max: number;
}

export class GiftCardImageDto {
  @ApiProperty()
  src: string;

  @ApiProperty({ description: 'e.g. "card_image", "logo"' })
  type: string;
}

export class GiftCardDto {
  @ApiProperty({ description: 'Tremendous product ID' })
  id: string;

  @ApiProperty({ description: 'Brand name (e.g. "Amazon.com")' })
  name: string;

  @ApiProperty()
  description: string;

  @ApiProperty({ description: 'Always "merchant_card" for gift cards' })
  category: string;

  @ApiPropertyOptional({ description: 'e.g. "entertainment", "food_and_drink"' })
  subcategory?: string;

  @ApiProperty({ type: [String], description: 'Available currencies' })
  currencyCodes: string[];

  @ApiProperty({ type: [String], description: 'Alpha-2 country codes' })
  countries: string[];

  @ApiProperty({ type: [GiftCardImageDto] })
  images: GiftCardImageDto[];

  @ApiProperty({ type: [GiftCardSkuDto], description: 'Denomination bands' })
  skus: GiftCardSkuDto[];

  @ApiPropertyOptional({ description: 'Coin cost (set by our backend based on face value)' })
  coinCost?: number;
}

export class GiftCardCatalogQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Comma-separated Alpha-2 country codes (e.g. "US,UK")',
  })
  @IsOptional()
  @IsString()
  country?: string;

  @ApiPropertyOptional({
    description: 'Comma-separated currency codes (e.g. "USD,EUR")',
  })
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional({
    description: 'Comma-separated subcategories (e.g. "entertainment,food_and_drink")',
  })
  @IsOptional()
  @IsString()
  subcategory?: string;
}

export class PaginatedGiftCardsDto {
  @ApiProperty({ type: [GiftCardDto] })
  data: GiftCardDto[];

  @ApiProperty()
  meta: PaginationMeta;
}

export class RedeemGiftCardDto {
  @ApiProperty({ description: 'Tremendous product ID to redeem' })
  @IsString()
  productId: string;

  @ApiProperty({ description: 'Gift card face value in dollars', minimum: 1 })
  @IsNumber()
  @Min(1)
  amount: number;

  @ApiPropertyOptional({ description: 'Currency code (defaults to USD)' })
  @IsOptional()
  @IsString()
  currency?: string;
}

export class RedemptionResponseDto {
  @ApiProperty()
  success: boolean;

  @ApiProperty({ description: 'Tremendous order ID' })
  orderId: string;

  @ApiProperty({ description: 'Tremendous reward ID' })
  rewardId: string;

  @ApiPropertyOptional({ description: 'Tremendous redemption link for the recipient' })
  redemptionLink?: string;

  @ApiProperty({ description: 'Coins debited for this redemption' })
  coinsSpent: number;

  @ApiProperty()
  newBalance: number;
}

export class RedemptionHistoryDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ description: 'Tremendous order ID' })
  orderId: string;

  @ApiProperty()
  productName: string;

  @ApiProperty()
  faceValue: number;

  @ApiProperty()
  currency: string;

  @ApiProperty()
  coinCost: number;

  @ApiPropertyOptional({ description: 'Link to claim the reward' })
  redemptionLink?: string;

  @ApiProperty({ description: 'pending | delivered | failed' })
  status: string;

  @ApiProperty()
  redeemedAt: Date;
}

export class RedemptionHistoryQueryDto extends PaginationQueryDto {}

export class PaginatedRedemptionHistoryDto {
  @ApiProperty({ type: [RedemptionHistoryDto] })
  data: RedemptionHistoryDto[];

  @ApiProperty()
  meta: PaginationMeta;
}
