import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { UserEntity } from '../../auth/entities/user.entity';
import { RafflePrerequisiteEntity } from './raffle-prerequisite.entity';

export enum RaffleType {
  DAILY = 'daily',
  WEEKLY = 'weekly',
  MONTHLY = 'monthly',
}

@Entity('raffles')
export class RaffleEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'enum', enum: RaffleType })
  type: RaffleType;

  @Column({ type: 'int' })
  prizeAmount: number;

  @Column({ type: 'timestamptz' })
  drawDate: Date;

  @Column({ nullable: true })
  winnerId: string;

  @ManyToOne(() => UserEntity, { nullable: true })
  @JoinColumn({ name: 'winnerId' })
  winner: UserEntity;

  @OneToMany(() => RafflePrerequisiteEntity, (p) => p.raffle, {
    cascade: true,
    eager: false,
  })
  prerequisites: RafflePrerequisiteEntity[];

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
