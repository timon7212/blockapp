import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('charities')
export class CharityEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  emoji: string;

  @Column()
  description: string;

  @Column()
  color: string;

  @Column({ default: true })
  active: boolean;
}
