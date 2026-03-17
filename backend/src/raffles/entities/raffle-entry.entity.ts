import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { UserEntity } from '../../auth/entities/user.entity';
import { RaffleEntity } from './raffle.entity';

@Entity('raffle_entries')
@Unique(['userId', 'raffleId'])
export class RaffleEntryEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column()
  raffleId: string;

  @ManyToOne(() => RaffleEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'raffleId' })
  raffle: RaffleEntity;

  @CreateDateColumn()
  createdAt: Date;
}
