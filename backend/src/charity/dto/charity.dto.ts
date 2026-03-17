import { ApiProperty } from '@nestjs/swagger';
import { IsInt, Min } from 'class-validator';

export class CharityDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  emoji: string;

  @ApiProperty()
  description: string;

  @ApiProperty()
  color: string;
}

export class DonateDto {
  @ApiProperty({ minimum: 1 })
  @IsInt()
  @Min(1)
  amount: number;
}

export class DonationResponseDto {
  @ApiProperty()
  success: boolean;

  @ApiProperty()
  donationId: string;

  @ApiProperty()
  amount: number;

  @ApiProperty()
  charityName: string;

  @ApiProperty()
  newBalance: number;
}
