import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { UserEntity } from '../../auth/entities/user.entity';

export enum TransactionType {
  SCREEN_TIME = 'screen_time',
  POINTS_COLLECTED = 'points_collected',
  SPIN_WHEEL = 'spin_wheel',
  GAME = 'game',
  TASK = 'task',
  SURVEY = 'survey',
  REFERRAL = 'referral',
  GIFT_CARD_PURCHASE = 'gift_card_purchase',
  CASH_OUT = 'cash_out',
  DONATION = 'donation',
  RAFFLE_WIN = 'raffle_win',
  WELCOME_BONUS = 'welcome_bonus',
}

@Entity('transactions')
export class TransactionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column({ type: 'enum', enum: TransactionType })
  type: TransactionType;

  @Column({ type: 'int' })
  points: number;

  @Column()
  description: string;

  @CreateDateColumn()
  @Index()
  createdAt: Date;
}
