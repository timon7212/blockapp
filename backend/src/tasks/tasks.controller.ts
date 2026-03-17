import { Controller, Get, Post, Param, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiCreatedResponse } from '@nestjs/swagger';
import {
  TaskDto,
  TaskCatalogQueryDto,
  PaginatedTasksDto,
  TaskStartDto,
  TaskCompleteResponseDto,
} from './dto/tasks.dto';
import { TasksService } from './tasks.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Tasks')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Get()
  @ApiOperation({
    summary: 'List available tasks',
    description: 'Returns a paginated list of offer-wall tasks the user can complete to earn points.',
  })
  @ApiOkResponse({ type: PaginatedTasksDto })
  async getTasks(
    @CurrentUser('id') userId: string,
    @Query() query: TaskCatalogQueryDto,
  ): Promise<PaginatedTasksDto> {
    return this.tasksService.getTasks(userId, query);
  }

  @Post('start')
  @ApiOperation({
    summary: 'Start a task',
    description: 'Marks a task as in-progress and returns the redirect URL.',
  })
  @ApiCreatedResponse({ type: TaskDto })
  async startTask(
    @CurrentUser('id') userId: string,
    @Body() dto: TaskStartDto,
  ): Promise<TaskDto> {
    return this.tasksService.startTask(userId, dto.taskId);
  }

  @Post(':taskId/complete')
  @ApiOperation({
    summary: 'Mark task as completed',
    description: 'Called via callback or by the client when the task is verified complete. Credits points.',
  })
  @ApiCreatedResponse({ type: TaskCompleteResponseDto })
  async completeTask(
    @CurrentUser('id') userId: string,
    @Param('taskId') taskId: string,
  ): Promise<TaskCompleteResponseDto> {
    return this.tasksService.completeTask(userId, taskId);
  }
}
