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
import { GameEntity } from './game.entity';

@Entity('game_completions')
export class GameCompletionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column()
  gameId: string;

  @ManyToOne(() => GameEntity)
  @JoinColumn({ name: 'gameId' })
  game: GameEntity;

  @Column({ type: 'int', default: 0 })
  score: number;

  @Column({ type: 'int' })
  pointsEarned: number;

  @Column({ type: 'date' })
  date: string;

  @CreateDateColumn()
  createdAt: Date;
}
