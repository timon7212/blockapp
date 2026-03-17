import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsInt,
  IsNumber,
  IsOptional,
  IsDateString,
  IsBoolean,
  IsEnum,
  Min,
} from 'class-validator';
import { SpinPrizeType } from '../../events/entities/spin-prize.entity';

// ── Games ──

export class CreateGameDto {
  @ApiProperty()
  @IsString()
  title: string;

  @ApiProperty()
  @IsString()
  description: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  iconUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  bannerUrl?: string;

  @ApiProperty()
  @IsInt()
  @Min(1)
  pointsReward: number;

  @ApiProperty()
  @IsInt()
  @Min(1)
  estimatedMinutes: number;

  @ApiProperty()
  @IsString()
  url: string;
}

export class UpdateGameDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  iconUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  bannerUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  pointsReward?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  estimatedMinutes?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  url?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  active?: boolean;
}

// ── Tasks ──

export class CreateTaskDto {
  @ApiProperty()
  @IsString()
  title: string;

  @ApiProperty()
  @IsString()
  description: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  iconUrl?: string;

  @ApiProperty()
  @IsInt()
  @Min(1)
  pointsReward: number;

  @ApiProperty()
  @IsString()
  category: string;

  @ApiProperty()
  @IsString()
  url: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}

export class UpdateTaskDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  iconUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  pointsReward?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  url?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  expiresAt?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  active?: boolean;
}

// ── Surveys ──

export class CreateSurveyDto {
  @ApiProperty()
  @IsString()
  title: string;

  @ApiProperty()
  @IsString()
  description: string;

  @ApiProperty()
  @IsInt()
  @Min(1)
  pointsReward: number;

  @ApiProperty()
  @IsInt()
  @Min(1)
  estimatedMinutes: number;

  @ApiProperty()
  @IsInt()
  @Min(1)
  questionCount: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  externalUrl?: string;
}

export class UpdateSurveyDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  pointsReward?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  estimatedMinutes?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  questionCount?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  externalUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  active?: boolean;
}

// ── Spin Prizes ──

export class CreateSpinPrizeDto {
  @ApiProperty({ description: 'Display label, e.g. "50 Points"' })
  @IsString()
  label: string;

  @ApiProperty({ enum: SpinPrizeType })
  @IsEnum(SpinPrizeType)
  type: SpinPrizeType;

  @ApiProperty({ description: 'Prize value (points amount, multiplier, extra cap, or 0)' })
  @IsNumber()
  @Min(0)
  value: number;

  @ApiProperty({ description: 'Relative probability weight (higher = more likely)' })
  @IsInt()
  @Min(1)
  weight: number;
}

export class UpdateSpinPrizeDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  label?: string;

  @ApiPropertyOptional({ enum: SpinPrizeType })
  @IsOptional()
  @IsEnum(SpinPrizeType)
  type?: SpinPrizeType;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  value?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  weight?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  active?: boolean;
}
