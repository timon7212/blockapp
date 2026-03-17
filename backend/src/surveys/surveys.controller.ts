import { Controller, Get, Post, Param, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiCreatedResponse } from '@nestjs/swagger';
import {
  SurveyCatalogQueryDto,
  PaginatedSurveysDto,
  SurveySubmitDto,
  SurveyCompleteResponseDto,
} from './dto/surveys.dto';
import { SurveysService } from './surveys.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Surveys')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('surveys')
export class SurveysController {
  constructor(private readonly surveysService: SurveysService) {}

  @Get()
  @ApiOperation({
    summary: 'List available surveys',
    description: 'Returns a paginated catalog of surveys the user can complete to earn points.',
  })
  @ApiOkResponse({ type: PaginatedSurveysDto })
  async getSurveys(
    @CurrentUser('id') userId: string,
    @Query() query: SurveyCatalogQueryDto,
  ): Promise<PaginatedSurveysDto> {
    return this.surveysService.getSurveys(userId, query);
  }

  @Post(':surveyId/submit')
  @ApiOperation({
    summary: 'Submit survey answers',
    description: 'Submits all answers for a survey and credits points on completion.',
  })
  @ApiCreatedResponse({ type: SurveyCompleteResponseDto })
  async submitSurvey(
    @CurrentUser('id') userId: string,
    @Param('surveyId') surveyId: string,
    @Body() dto: SurveySubmitDto,
  ): Promise<SurveyCompleteResponseDto> {
    return this.surveysService.submitSurvey(userId, surveyId, dto.answers);
  }
}
