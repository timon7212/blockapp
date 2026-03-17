import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('surveys')
export class SurveyEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column()
  description: string;

  @Column({ type: 'int' })
  pointsReward: number;

  @Column({ type: 'int' })
  estimatedMinutes: number;

  @Column({ type: 'int' })
  questionCount: number;

  @Column({ nullable: true })
  externalUrl: string;

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
