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

@Entity('gift_card_redemptions')
export class GiftCardRedemptionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column()
  productId: string;

  @Column()
  productName: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  faceValue: number;

  @Column({ default: 'USD' })
  currency: string;

  @Column({ type: 'int' })
  pointsSpent: number;

  @Column({ nullable: true })
  tremendousOrderId: string;

  @Column({ nullable: true })
  tremendousRewardId: string;

  @Column({ nullable: true })
  redemptionLink: string;

  @Column({ default: 'pending' })
  status: string;

  @CreateDateColumn()
  createdAt: Date;
}
