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

@Entity('cashout_requests')
export class CashOutRequestEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column({ type: 'int' })
  pointAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  cashValue: number;

  @Column()
  paymentMethod: string;

  @Column()
  paymentDetails: string;

  @Column({ default: 'pending' })
  status: string;

  @CreateDateColumn()
  requestedAt: Date;

  @Column({ type: 'timestamptz', nullable: true })
  completedAt: Date;
}
