import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

export enum SpinPrizeType {
  POINTS = 'points',
  BONUS_MULTIPLIER = 'bonus_multiplier',
  EXTRA_CAP = 'extra_cap',
  NOTHING = 'nothing',
}

@Entity('spin_prizes')
export class SpinPrizeEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  label: string;

  @Column({ type: 'enum', enum: SpinPrizeType })
  type: SpinPrizeType;

  @Column({ type: 'float' })
  value: number;

  @Column({ type: 'int' })
  weight: number;

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
