import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiCreatedResponse } from '@nestjs/swagger';
import {
  GameCatalogQueryDto,
  PaginatedGamesDto,
  GameCompleteDto,
  GameCompleteResponseDto,
} from './dto/games.dto';
import { GamesService } from './games.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Games')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('games')
export class GamesController {
  constructor(private readonly gamesService: GamesService) {}

  @Get()
  @ApiOperation({
    summary: 'List available games',
    description: 'Returns a paginated catalog of mini-games the user can play to earn points.',
  })
  @ApiOkResponse({ type: PaginatedGamesDto })
  async getGames(
    @CurrentUser('id') userId: string,
    @Query() query: GameCatalogQueryDto,
  ): Promise<PaginatedGamesDto> {
    return this.gamesService.getGames(userId, query);
  }

  @Post('complete')
  @ApiOperation({
    summary: 'Report game completion',
    description: 'Called after the user finishes a game session. Credits points to wallet.',
  })
  @ApiCreatedResponse({ type: GameCompleteResponseDto })
  async completeGame(
    @CurrentUser('id') userId: string,
    @Body() dto: GameCompleteDto,
  ): Promise<GameCompleteResponseDto> {
    return this.gamesService.completeGame(userId, dto);
  }
}
