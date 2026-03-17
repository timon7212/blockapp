import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsOptional,
  IsString,
  IsEnum,
  IsInt,
  IsDateString,
  Min,
} from 'class-validator';
import { PaginationQueryDto, PaginationMeta } from '../../common/dto/pagination.dto';
import { PrerequisiteType } from '../entities/raffle-prerequisite.entity';

export enum RaffleType {
  DAILY = 'daily',
  WEEKLY = 'weekly',
  MONTHLY = 'monthly',
}

export class RafflePrerequisiteItemDto {
  @ApiProperty({ enum: PrerequisiteType })
  type: PrerequisiteType;

  @ApiProperty({ description: 'How many the user needs' })
  requiredCount: number;

  @ApiProperty({ description: "User's current count for this type" })
  userCurrentCount: number;

  @ApiProperty({ description: 'Whether this single prerequisite is met' })
  met: boolean;
}

export class RaffleDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty({ enum: RaffleType })
  type: RaffleType;

  @ApiProperty()
  prizeAmount: number;

  @ApiProperty({ description: 'Seconds until draw' })
  timeRemainingSeconds: number;

  @ApiProperty()
  totalParticipants: number;

  @ApiProperty()
  isEntered: boolean;

  @ApiProperty({ description: 'Whether the user meets all prerequisites' })
  isEligible: boolean;

  @ApiProperty({
    type: [RafflePrerequisiteItemDto],
    description: 'Prerequisite details',
  })
  prerequisites: RafflePrerequisiteItemDto[];
}

export class RaffleEntryDto {
  @ApiProperty({ description: 'Ad type watched before entering (e.g. "rewarded")' })
  @IsString()
  adType: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  adNetworkId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  adUnitId?: string;
}

export class RaffleResultDto {
  @ApiProperty()
  raffleId: string;

  @ApiProperty()
  winnerId: string;

  @ApiProperty()
  winnerUsername: string;

  @ApiProperty()
  prizeAmount: number;

  @ApiProperty()
  isCurrentUserWinner: boolean;

  @ApiProperty()
  drawnAt: Date;
}

export class RaffleEntryResponseDto {
  @ApiProperty()
  success: boolean;

  @ApiProperty()
  entryId: string;

  @ApiProperty()
  totalParticipants: number;
}

export class RaffleDrawResultDto {
  @ApiProperty({ description: 'Whether the draw was triggered' })
  triggered: boolean;
}

export class RaffleHistoryQueryDto extends PaginationQueryDto {}

export class PaginatedRaffleHistoryDto {
  @ApiProperty({ type: [RaffleResultDto] })
  data: RaffleResultDto[];

  @ApiProperty()
  meta: PaginationMeta;
}

// ── Winners leaderboard ──

export class RaffleWinnerDto {
  @ApiProperty()
  winnerId: string;

  @ApiProperty()
  winnerUsername: string;

  @ApiPropertyOptional()
  winnerAvatar?: string;

  @ApiProperty()
  prizeAmount: number;

  @ApiProperty()
  drawnAt: Date;

  @ApiProperty()
  raffleTitle: string;
}

export class RaffleWinnersQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ enum: RaffleType, description: 'Filter by raffle type' })
  @IsOptional()
  @IsEnum(RaffleType)
  type?: RaffleType;
}

export class PaginatedRaffleWinnersDto {
  @ApiProperty({ type: [RaffleWinnerDto] })
  data: RaffleWinnerDto[];

  @ApiProperty()
  meta: PaginationMeta;
}

// ── Admin DTOs ──

export class CreateRaffleDto {
  @ApiProperty()
  @IsString()
  title: string;

  @ApiProperty({ enum: RaffleType })
  @IsEnum(RaffleType)
  type: RaffleType;

  @ApiProperty()
  @IsInt()
  @Min(1)
  prizeAmount: number;

  @ApiProperty({ description: 'ISO date string for the draw' })
  @IsDateString()
  drawDate: string;
}

export class UpdateRaffleDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({ enum: RaffleType })
  @IsOptional()
  @IsEnum(RaffleType)
  type?: RaffleType;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  prizeAmount?: number;

  @ApiPropertyOptional({ description: 'ISO date string for the draw' })
  @IsOptional()
  @IsDateString()
  drawDate?: string;
}

export class AddPrerequisiteDto {
  @ApiProperty({ enum: PrerequisiteType })
  @IsEnum(PrerequisiteType)
  type: PrerequisiteType;

  @ApiProperty({ description: 'Required count for this prerequisite' })
  @IsInt()
  @Min(1)
  requiredCount: number;
}
