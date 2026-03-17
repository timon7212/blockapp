import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsArray } from 'class-validator';

export class UpdateProfileDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  displayName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  avatarUrl?: string;
}

export class OnboardingDto {
  @ApiProperty({
    type: [String],
    description: 'Bundle IDs of social apps the user wants to track (e.g. com.instagram.android)',
  })
  @IsArray()
  @IsString({ each: true })
  trackedAppIds: string[];

  @ApiProperty({ description: 'User goal: earn_rewards | track_usage | reduce_screen_time' })
  @IsString()
  goal: string;
}

export class UserProfileDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  email: string;

  @ApiProperty()
  displayName: string;

  @ApiPropertyOptional()
  avatarUrl?: string;

  @ApiProperty()
  referralCode: string;

  @ApiProperty()
  directInvites: number;

  @ApiProperty()
  joinedAt: Date;

  @ApiProperty({ description: 'Total points in wallet' })
  totalPoints: number;

  @ApiProperty({ description: 'Uncollected points (capped)' })
  uncollectedPoints: number;

  @ApiProperty({ description: 'Consecutive days of collecting points' })
  currentStreak: number;

  @ApiProperty()
  onboardingComplete: boolean;

  @ApiProperty({ type: [String], description: 'Bundle IDs of tracked social apps' })
  trackedAppIds: string[];

  @ApiProperty({ description: 'Number of spin-wheel spins available' })
  spinsAvailable: number;
}
