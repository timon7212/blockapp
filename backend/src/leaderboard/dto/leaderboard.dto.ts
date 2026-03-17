import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationQueryDto, PaginationMeta } from '../../common/dto/pagination.dto';

export class LeaderboardEntryDto {
  @ApiProperty()
  rank: number;

  @ApiProperty()
  userId: string;

  @ApiProperty()
  username: string;

  @ApiPropertyOptional()
  avatarUrl?: string;

  @ApiProperty()
  coins: number;
}

export class LeaderboardQueryDto extends PaginationQueryDto {}

export class PaginatedLeaderboardDto {
  @ApiProperty({ type: [LeaderboardEntryDto] })
  data: LeaderboardEntryDto[];

  @ApiProperty()
  meta: PaginationMeta;
}

export class UserRankDto {
  @ApiProperty()
  rank: number;

  @ApiProperty()
  coins: number;

  @ApiProperty({ type: [LeaderboardEntryDto], description: 'Users around current user' })
  surrounding: LeaderboardEntryDto[];
}
