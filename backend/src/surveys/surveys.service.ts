import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SurveyEntity } from './entities/survey.entity';
import { SurveyCompletionEntity } from './entities/survey-completion.entity';
import { UserEntity } from '../auth/entities/user.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import {
  SurveyDto,
  SurveyCatalogQueryDto,
  SurveyAnswerDto,
  SurveyCompleteResponseDto,
} from './dto/surveys.dto';
import { PaginatedResponseDto, PaginationMeta } from '../common/dto/pagination.dto';

@Injectable()
export class SurveysService {
  constructor(
    @InjectRepository(SurveyEntity)
    private readonly surveyRepo: Repository<SurveyEntity>,
    @InjectRepository(SurveyCompletionEntity)
    private readonly completionRepo: Repository<SurveyCompletionEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
  ) {}

  async getSurveys(
    userId: string,
    query: SurveyCatalogQueryDto,
  ): Promise<PaginatedResponseDto<SurveyDto>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const [surveys, total] = await this.surveyRepo.findAndCount({
      where: { active: true },
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    const data: SurveyDto[] = await Promise.all(
      surveys.map(async (survey) => {
        const completion = await this.completionRepo.findOne({
          where: { userId, surveyId: survey.id },
        });

        return {
          id: survey.id,
          title: survey.title,
          description: survey.description,
          pointsReward: survey.pointsReward,
          estimatedMinutes: survey.estimatedMinutes,
          questionCount: survey.questionCount,
          completed: !!completion,
          externalUrl: survey.externalUrl ?? null,
        };
      }),
    );

    const totalPages = Math.ceil(total / limit) || 1;
    const meta: PaginationMeta = {
      page,
      limit,
      total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    };

    return { data, meta };
  }

  async submitSurvey(
    userId: string,
    surveyId: string,
    answers: SurveyAnswerDto[],
  ): Promise<SurveyCompleteResponseDto> {
    const survey = await this.surveyRepo.findOne({
      where: { id: surveyId, active: true },
    });
    if (!survey) {
      throw new NotFoundException('Survey not found');
    }

    const existing = await this.completionRepo.findOne({
      where: { userId, surveyId },
    });
    if (existing) {
      throw new BadRequestException('Survey already completed');
    }

    const completion = this.completionRepo.create({
      userId,
      surveyId,
      answers,
      pointsEarned: survey.pointsReward,
    });
    await this.completionRepo.save(completion);

    const user = await this.userRepo.findOneByOrFail({ id: userId });
    user.walletBalance += survey.pointsReward;
    await this.userRepo.save(user);

    const transaction = this.transactionRepo.create({
      userId,
      type: TransactionType.SURVEY,
      points: survey.pointsReward,
      description: `Survey completed: ${survey.title}`,
    });
    await this.transactionRepo.save(transaction);

    return {
      pointsEarned: survey.pointsReward,
      newBalance: user.walletBalance,
    };
  }
}
