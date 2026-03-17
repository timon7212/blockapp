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
import { CharityEntity } from './charity.entity';

@Entity('charity_donations')
export class CharityDonationEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column()
  charityId: string;

  @ManyToOne(() => CharityEntity)
  @JoinColumn({ name: 'charityId' })
  charity: CharityEntity;

  @Column({ type: 'int' })
  points: number;

  @CreateDateColumn()
  createdAt: Date;
}
