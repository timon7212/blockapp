import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto, PaginationMeta } from '../../common/dto/pagination.dto';

export class SurveyDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  description: string;

  @ApiProperty({ description: 'Points rewarded on completion' })
  pointsReward: number;

  @ApiProperty({ description: 'Estimated time in minutes' })
  estimatedMinutes: number;

  @ApiProperty({ description: 'Number of questions in the survey' })
  questionCount: number;

  @ApiProperty({ description: 'Whether the user has already completed this survey' })
  completed: boolean;

  @ApiProperty({ description: 'External survey URL or null for in-app survey', nullable: true })
  externalUrl: string | null;
}

export class SurveyCatalogQueryDto extends PaginationQueryDto {}

export class PaginatedSurveysDto {
  @ApiProperty({ type: [SurveyDto] })
  data: SurveyDto[];

  @ApiProperty()
  meta: PaginationMeta;
}

export class SurveyAnswerDto {
  @ApiProperty()
  @IsString()
  questionId: string;

  @ApiProperty({ description: 'Selected option ID or free-text answer' })
  @IsString()
  answer: string;
}

export class SurveySubmitDto {
  @ApiProperty({ type: [SurveyAnswerDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SurveyAnswerDto)
  answers: SurveyAnswerDto[];
}

export class SurveyCompleteResponseDto {
  @ApiProperty()
  pointsEarned: number;

  @ApiProperty()
  newBalance: number;
}
