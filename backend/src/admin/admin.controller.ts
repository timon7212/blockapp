import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiOkResponse,
  ApiCreatedResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminGuard } from './guards/admin.guard';
import { AdminService } from './admin.service';
import {
  CreateRaffleDto,
  UpdateRaffleDto,
  AddPrerequisiteDto,
} from '../raffles/dto/raffles.dto';
import {
  CreateGameDto,
  UpdateGameDto,
  CreateTaskDto,
  UpdateTaskDto,
  CreateSurveyDto,
  UpdateSurveyDto,
  CreateSpinPrizeDto,
  UpdateSpinPrizeDto,
} from './dto/admin.dto';

@ApiTags('Admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  // ── Raffles ──

  @Post('raffles')
  @ApiOperation({ summary: 'Create a raffle' })
  @ApiCreatedResponse()
  async createRaffle(@Body() dto: CreateRaffleDto) {
    return this.adminService.createRaffle(dto);
  }

  @Get('raffles/:id')
  @ApiOperation({ summary: 'Get raffle with prerequisites' })
  @ApiOkResponse()
  async getRaffle(@Param('id') id: string) {
    return this.adminService.getRaffleWithPrereqs(id);
  }

  @Put('raffles/:id')
  @ApiOperation({ summary: 'Update a raffle' })
  @ApiOkResponse()
  async updateRaffle(@Param('id') id: string, @Body() dto: UpdateRaffleDto) {
    return this.adminService.updateRaffle(id, dto);
  }

  @Delete('raffles/:id')
  @ApiOperation({ summary: 'Delete a raffle' })
  async deleteRaffle(@Param('id') id: string) {
    await this.adminService.deleteRaffle(id);
    return { deleted: true };
  }

  @Post('raffles/:id/prerequisites')
  @ApiOperation({ summary: 'Add a prerequisite to a raffle' })
  @ApiCreatedResponse()
  async addPrerequisite(
    @Param('id') raffleId: string,
    @Body() dto: AddPrerequisiteDto,
  ) {
    return this.adminService.addPrerequisite(raffleId, dto);
  }

  @Delete('raffles/:id/prerequisites/:prereqId')
  @ApiOperation({ summary: 'Remove a prerequisite from a raffle' })
  async removePrerequisite(
    @Param('id') raffleId: string,
    @Param('prereqId') prereqId: string,
  ) {
    await this.adminService.removePrerequisite(raffleId, prereqId);
    return { deleted: true };
  }

  // ── Games ──

  @Post('games')
  @ApiOperation({ summary: 'Create a game' })
  @ApiCreatedResponse()
  async createGame(@Body() dto: CreateGameDto) {
    return this.adminService.createGame(dto);
  }

  @Put('games/:id')
  @ApiOperation({ summary: 'Update a game' })
  @ApiOkResponse()
  async updateGame(@Param('id') id: string, @Body() dto: UpdateGameDto) {
    return this.adminService.updateGame(id, dto);
  }

  @Delete('games/:id')
  @ApiOperation({ summary: 'Deactivate a game' })
  async deleteGame(@Param('id') id: string) {
    await this.adminService.deleteGame(id);
    return { deactivated: true };
  }

  // ── Tasks ──

  @Post('tasks')
  @ApiOperation({ summary: 'Create a task' })
  @ApiCreatedResponse()
  async createTask(@Body() dto: CreateTaskDto) {
    return this.adminService.createTask(dto);
  }

  @Put('tasks/:id')
  @ApiOperation({ summary: 'Update a task' })
  @ApiOkResponse()
  async updateTask(@Param('id') id: string, @Body() dto: UpdateTaskDto) {
    return this.adminService.updateTask(id, dto);
  }

  @Delete('tasks/:id')
  @ApiOperation({ summary: 'Deactivate a task' })
  async deleteTask(@Param('id') id: string) {
    await this.adminService.deleteTask(id);
    return { deactivated: true };
  }

  // ── Surveys ──

  @Post('surveys')
  @ApiOperation({ summary: 'Create a survey' })
  @ApiCreatedResponse()
  async createSurvey(@Body() dto: CreateSurveyDto) {
    return this.adminService.createSurvey(dto);
  }

  @Put('surveys/:id')
  @ApiOperation({ summary: 'Update a survey' })
  @ApiOkResponse()
  async updateSurvey(@Param('id') id: string, @Body() dto: UpdateSurveyDto) {
    return this.adminService.updateSurvey(id, dto);
  }

  @Delete('surveys/:id')
  @ApiOperation({ summary: 'Deactivate a survey' })
  async deleteSurvey(@Param('id') id: string) {
    await this.adminService.deleteSurvey(id);
    return { deactivated: true };
  }

  // ── Spin Prizes ──

  @Get('spin-prizes')
  @ApiOperation({ summary: 'List all spin prizes (including inactive)' })
  @ApiOkResponse()
  async getSpinPrizes() {
    return this.adminService.getSpinPrizes();
  }

  @Post('spin-prizes')
  @ApiOperation({ summary: 'Create a spin prize' })
  @ApiCreatedResponse()
  async createSpinPrize(@Body() dto: CreateSpinPrizeDto) {
    return this.adminService.createSpinPrize(dto);
  }

  @Put('spin-prizes/:id')
  @ApiOperation({ summary: 'Update a spin prize' })
  @ApiOkResponse()
  async updateSpinPrize(
    @Param('id') id: string,
    @Body() dto: UpdateSpinPrizeDto,
  ) {
    return this.adminService.updateSpinPrize(id, dto);
  }

  @Delete('spin-prizes/:id')
  @ApiOperation({ summary: 'Delete a spin prize' })
  async deleteSpinPrize(@Param('id') id: string) {
    await this.adminService.deleteSpinPrize(id);
    return { deleted: true };
  }
}
