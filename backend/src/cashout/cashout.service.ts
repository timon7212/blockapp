import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CashOutRequestEntity } from './entities/cashout-request.entity';
import { UserEntity } from '../auth/entities/user.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import {
  CashOutRequestDto,
  CashOutResponseDto,
  CashOutHistoryQueryDto,
  CashOutHistoryDto,
} from './dto/cashout.dto';
import { PaginatedResponseDto, PaginationMeta } from '../common/dto/pagination.dto';

const COINS_PER_DOLLAR = 1000;

@Injectable()
export class CashOutService {
  constructor(
    @InjectRepository(CashOutRequestEntity)
    private readonly cashOutRepo: Repository<CashOutRequestEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
  ) {}

  async requestCashOut(
    userId: string,
    dto: CashOutRequestDto,
  ): Promise<CashOutResponseDto> {
    const user = await this.userRepo.findOneByOrFail({ id: userId });

    if (user.walletBalance < dto.coinAmount) {
      throw new BadRequestException(
        `Insufficient balance. Need ${dto.coinAmount}, have ${user.walletBalance}.`,
      );
    }

    const cashValue = dto.coinAmount / COINS_PER_DOLLAR;

    const cashOut = this.cashOutRepo.create({
      userId,
      pointAmount: dto.coinAmount,
      cashValue,
      paymentMethod: dto.paymentMethod,
      paymentDetails: dto.paymentDetails,
      status: 'pending',
    });
    await this.cashOutRepo.save(cashOut);

    user.walletBalance -= dto.coinAmount;
    await this.userRepo.save(user);

    const transaction = this.transactionRepo.create({
      userId,
      type: TransactionType.CASH_OUT,
      points: -dto.coinAmount,
      description: `Cash out: $${cashValue.toFixed(2)} via ${dto.paymentMethod}`,
    });
    await this.transactionRepo.save(transaction);

    return {
      success: true,
      cashOutId: cashOut.id,
      coinAmount: dto.coinAmount,
      cashValue: Number(cashValue),
      newBalance: user.walletBalance,
      status: cashOut.status,
    };
  }

  async getHistory(
    userId: string,
    query: CashOutHistoryQueryDto,
  ): Promise<PaginatedResponseDto<CashOutHistoryDto>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const [items, total] = await this.cashOutRepo.findAndCount({
      where: { userId },
      skip: (page - 1) * limit,
      take: limit,
      order: { requestedAt: 'DESC' },
    });

    const data: CashOutHistoryDto[] = items.map((r) => ({
      id: r.id,
      coinAmount: r.pointAmount,
      cashValue: Number(r.cashValue),
      paymentMethod: r.paymentMethod,
      status: r.status,
      requestedAt: r.requestedAt,
      completedAt: r.completedAt ?? null,
    }));

    const totalPages = Math.ceil(total / limit) || 1;
    const meta: PaginationMeta = {
      page,
      limit,
      total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    };

    return { data, meta };
  }
}
