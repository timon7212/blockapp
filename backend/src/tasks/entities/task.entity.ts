import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('tasks')
export class TaskEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column()
  description: string;

  @Column({ nullable: true })
  iconUrl: string;

  @Column({ type: 'int' })
  pointsReward: number;

  @Column()
  category: string;

  @Column()
  url: string;

  @Column({ type: 'timestamptz', nullable: true })
  expiresAt: Date;

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
