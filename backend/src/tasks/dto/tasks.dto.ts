import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';
import { PaginationQueryDto, PaginationMeta } from '../../common/dto/pagination.dto';

export enum TaskStatus {
  AVAILABLE = 'available',
  IN_PROGRESS = 'in_progress',
  PENDING_REVIEW = 'pending_review',
  COMPLETED = 'completed',
  EXPIRED = 'expired',
}

export class TaskDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  description: string;

  @ApiProperty()
  iconUrl: string;

  @ApiProperty({ description: 'Points rewarded on completion' })
  pointsReward: number;

  @ApiProperty({ enum: TaskStatus })
  status: TaskStatus;

  @ApiProperty({ description: 'e.g. "Download app", "Sign up", "Watch video"' })
  category: string;

  @ApiProperty({ description: 'External URL or deep link to complete the task' })
  url: string;

  @ApiProperty({ description: 'Deadline to complete the task', nullable: true })
  expiresAt: Date | null;
}

export class TaskCatalogQueryDto extends PaginationQueryDto {}

export class PaginatedTasksDto {
  @ApiProperty({ type: [TaskDto] })
  data: TaskDto[];

  @ApiProperty()
  meta: PaginationMeta;
}

export class TaskStartDto {
  @ApiProperty({ description: 'Task ID to start' })
  @IsString()
  taskId: string;
}

export class TaskCompleteResponseDto {
  @ApiProperty()
  pointsEarned: number;

  @ApiProperty()
  newBalance: number;
}
