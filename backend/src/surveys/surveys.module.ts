import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SurveysController } from './surveys.controller';
import { SurveysService } from './surveys.service';
import { SurveyEntity } from './entities/survey.entity';
import { SurveyCompletionEntity } from './entities/survey-completion.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([SurveyEntity, SurveyCompletionEntity, UserEntity, TransactionEntity]),
  ],
  controllers: [SurveysController],
  providers: [SurveysService],
  exports: [SurveysService],
})
export class SurveysModule {}
