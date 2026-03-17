import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
  Index,
} from 'typeorm';
import { UserEntity } from '../../auth/entities/user.entity';
import { SurveyEntity } from './survey.entity';

@Entity('survey_completions')
@Unique(['userId', 'surveyId'])
export class SurveyCompletionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column()
  surveyId: string;

  @ManyToOne(() => SurveyEntity)
  @JoinColumn({ name: 'surveyId' })
  survey: SurveyEntity;

  @Column({ type: 'jsonb', nullable: true })
  answers: any;

  @Column({ type: 'int' })
  pointsEarned: number;

  @CreateDateColumn()
  createdAt: Date;
}
