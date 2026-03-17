import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsInt, Min } from 'class-validator';
import { PaginationQueryDto, PaginationMeta } from '../../common/dto/pagination.dto';

export class GameDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  description: string;

  @ApiProperty()
  iconUrl: string;

  @ApiProperty()
  bannerUrl: string;

  @ApiProperty({ description: 'Points rewarded for completing / playing' })
  pointsReward: number;

  @ApiProperty({ description: 'Estimated play time in minutes' })
  estimatedMinutes: number;

  @ApiProperty({ description: 'Whether the user has already played today' })
  playedToday: boolean;

  @ApiProperty({ description: 'External deep link or webview URL' })
  url: string;
}

export class GameCatalogQueryDto extends PaginationQueryDto {}

export class PaginatedGamesDto {
  @ApiProperty({ type: [GameDto] })
  data: GameDto[];

  @ApiProperty()
  meta: PaginationMeta;
}

export class GameCompleteDto {
  @ApiProperty({ description: 'Game ID that was completed' })
  @IsString()
  gameId: string;

  @ApiProperty({ description: 'Score achieved (if applicable)' })
  @IsInt()
  @Min(0)
  score: number;
}

export class GameCompleteResponseDto {
  @ApiProperty()
  pointsEarned: number;

  @ApiProperty()
  newBalance: number;
}
