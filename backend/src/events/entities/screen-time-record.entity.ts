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

@Entity('screen_time_records')
export class ScreenTimeRecordEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column()
  appId: string;

  @Column({ type: 'int' })
  minutes: number;

  @Column({ type: 'date' })
  @Index()
  date: string;

  @CreateDateColumn()
  createdAt: Date;
}
