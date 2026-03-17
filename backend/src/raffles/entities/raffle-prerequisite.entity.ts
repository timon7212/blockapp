import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { RaffleEntity } from './raffle.entity';

export enum PrerequisiteType {
  ADS_WATCHED = 'ads_watched',
  TASKS_COMPLETED = 'tasks_completed',
  SURVEYS_COMPLETED = 'surveys_completed',
  GAMES_COMPLETED = 'games_completed',
}

@Entity('raffle_prerequisites')
export class RafflePrerequisiteEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  raffleId: string;

  @ManyToOne(() => RaffleEntity, (raffle) => raffle.prerequisites, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'raffleId' })
  raffle: RaffleEntity;

  @Column({ type: 'enum', enum: PrerequisiteType })
  type: PrerequisiteType;

  @Column({ type: 'int' })
  requiredCount: number;

  @CreateDateColumn()
  createdAt: Date;
}
