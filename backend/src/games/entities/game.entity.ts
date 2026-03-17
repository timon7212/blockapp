import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('games')
export class GameEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column()
  description: string;

  @Column({ nullable: true })
  iconUrl: string;

  @Column({ nullable: true })
  bannerUrl: string;

  @Column({ type: 'int' })
  pointsReward: number;

  @Column({ type: 'int' })
  estimatedMinutes: number;

  @Column()
  url: string;

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
