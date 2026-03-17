import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TransactionEntity, TransactionType } from './entities/transaction.entity';
import { UserEntity } from '../auth/entities/user.entity';
import { WalletDto, PaginatedTransactionsDto, TransactionQueryDto } from './dto/wallet.dto';

@Injectable()
export class WalletService {
  constructor(
    @InjectRepository(TransactionEntity)
    private readonly txRepo: Repository<TransactionEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
  ) {}

  async getBalance(userId: string): Promise<WalletDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const todayTxRows: { type: string; total: string }[] = await this.txRepo
      .createQueryBuilder('tx')
      .select('tx.type', 'type')
      .addSelect('COALESCE(SUM(tx.points), 0)', 'total')
      .where('tx.userId = :userId', { userId })
      .andWhere('tx.createdAt >= :startOfDay', { startOfDay })
      .groupBy('tx.type')
      .getRawMany();

    let todayPoints = 0;
    let todayReferralPoints = 0;
    for (const row of todayTxRows) {
      const pts = Number(row.total);
      if (row.type === TransactionType.REFERRAL) {
        todayReferralPoints += pts;
      }
      todayPoints += pts;
    }

    const allTimeResult = await this.txRepo
      .createQueryBuilder('tx')
      .select('COALESCE(SUM(tx.points), 0)', 'total')
      .where('tx.userId = :userId', { userId })
      .andWhere('tx.points > 0')
      .getRawOne();

    return {
      totalPoints: user.walletBalance,
      todayPoints,
      todayReferralPoints,
      uncollectedPoints: user.uncollectedPoints,
      allTimePointsEarned: Number(allTimeResult?.total ?? 0),
    };
  }

  async getTransactions(
    userId: string,
    query: TransactionQueryDto,
  ): Promise<PaginatedTransactionsDto> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const where: any = { userId };
    if (query.type) {
      where.type = query.type;
    }

    const [rows, total] = await this.txRepo.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    const totalPages = Math.ceil(total / limit) || 1;

    return {
      data: rows.map((tx) => ({
        id: tx.id,
        description: tx.description,
        points: tx.points,
        timestamp: tx.createdAt,
        type: tx.type as any,
      })),
      meta: {
        page,
        limit,
        total,
        totalPages,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      },
    };
  }

  async addTransaction(
    userId: string,
    type: TransactionType,
    points: number,
    description: string,
  ): Promise<TransactionEntity> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const tx = this.txRepo.create({ userId, type, points, description });
    await this.txRepo.save(tx);

    user.walletBalance += points;
    await this.userRepo.save(user);

    return tx;
  }
}
