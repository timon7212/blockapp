import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UserEntity } from '../auth/entities/user.entity';
import { TransactionEntity } from '../wallet/entities/transaction.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity, TransactionEntity])],
  controllers: [UsersController],
  providers: [UsersService],
})
export class UsersModule {}
