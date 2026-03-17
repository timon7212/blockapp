import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
  Index,
} from 'typeorm';
import { UserEntity } from '../../auth/entities/user.entity';
import { TaskEntity } from './task.entity';

@Entity('task_progress')
@Unique(['userId', 'taskId'])
export class TaskProgressEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column()
  taskId: string;

  @ManyToOne(() => TaskEntity)
  @JoinColumn({ name: 'taskId' })
  task: TaskEntity;

  @Column({ default: 'available' })
  status: string;

  @Column({ type: 'int', default: 0 })
  pointsEarned: number;

  @CreateDateColumn()
  startedAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
