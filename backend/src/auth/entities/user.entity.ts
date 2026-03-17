import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';

@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  @Index()
  email: string;

  @Column({ nullable: true })
  passwordHash: string;

  @Column({ nullable: true, unique: true })
  @Index()
  googleId: string;

  @Column()
  displayName: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @Column({ unique: true })
  @Index()
  referralCode: string;

  @Column({ nullable: true })
  referredById: string;

  @ManyToOne(() => UserEntity, { nullable: true })
  @JoinColumn({ name: 'referredById' })
  referredBy: UserEntity;

  @Column({ default: 'user' })
  role: string;

  @Column({ default: false })
  emailVerified: boolean;

  @Column({ nullable: true })
  verificationToken: string;

  @Column({ nullable: true })
  resetPasswordToken: string;

  @Column({ type: 'timestamptz', nullable: true })
  resetPasswordExpires: Date;

  @Column({ nullable: true })
  refreshToken: string;

  @Column({ default: false })
  onboardingComplete: boolean;

  @Column({ nullable: true })
  goal: string;

  @Column('simple-array', { default: '' })
  trackedAppIds: string[];

  @Column({ type: 'int', default: 0 })
  walletBalance: number;

  @Column({ type: 'int', default: 0 })
  uncollectedPoints: number;

  @Column({ type: 'int', default: 0 })
  totalScreenTimeMinutes: number;

  @Column({ type: 'int', default: 0 })
  spinsAvailable: number;

  @Column({ type: 'int', default: 0 })
  currentStreak: number;

  @Column({ type: 'int', default: 0 })
  longestStreak: number;

  @Column({ type: 'date', nullable: true })
  lastCollectionDate: string;

  @Column({ type: 'float', default: 1 })
  bonusMultiplier: number;

  @Column({ type: 'int', default: 0 })
  extraCap: number;

  @Column({ type: 'int', default: 0 })
  weeklyPoints: number;

  @Column({ type: 'int', default: 0 })
  pendingChildPoints: number;

  @Column({ type: 'int', default: 0 })
  pendingGrandChildPoints: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
