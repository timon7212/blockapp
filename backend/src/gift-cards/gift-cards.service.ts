import {
  Injectable,
  BadRequestException,
  InternalServerErrorException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GiftCardRedemptionEntity } from './entities/gift-card-redemption.entity';
import { UserEntity } from '../auth/entities/user.entity';
import {
  TransactionEntity,
  TransactionType,
} from '../wallet/entities/transaction.entity';
import { TremendousService } from './tremendous.service';
import {
  GiftCardDto,
  GiftCardCatalogQueryDto,
  RedeemGiftCardDto,
  RedemptionResponseDto,
  RedemptionHistoryQueryDto,
  RedemptionHistoryDto,
} from './dto/gift-cards.dto';
import { PaginatedResponseDto, PaginationMeta } from '../common/dto/pagination.dto';
import { paginate } from '../common/dto/pagination.dto';

const COINS_PER_DOLLAR = 1000;

@Injectable()
export class GiftCardsService {
  constructor(
    private readonly tremendousService: TremendousService,
    @InjectRepository(GiftCardRedemptionEntity)
    private readonly redemptionRepo: Repository<GiftCardRedemptionEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactionRepo: Repository<TransactionEntity>,
  ) {}

  async getCatalog(
    query: GiftCardCatalogQueryDto,
  ): Promise<PaginatedResponseDto<GiftCardDto>> {
    const products = await this.tremendousService.listProducts({
      country: query.country,
      currency: query.currency,
      subcategory: query.subcategory,
    });

    const mapped: GiftCardDto[] = products.map((p) => ({
      id: p.id,
      name: p.name,
      description: p.description,
      category: p.category,
      subcategory: p.subcategory,
      currencyCodes: p.currency_codes,
      countries: p.countries,
      images: p.images,
      skus: p.skus,
      coinCost: p.skus?.[0]?.min
        ? Math.round(p.skus[0].min * COINS_PER_DOLLAR)
        : undefined,
    }));

    return paginate(mapped, query.page, query.limit);
  }

  async redeem(
    userId: string,
    dto: RedeemGiftCardDto,
  ): Promise<RedemptionResponseDto> {
    const currency = dto.currency || 'USD';
    const coinsRequired = Math.round(dto.amount * COINS_PER_DOLLAR);

    const user = await this.userRepo.findOneByOrFail({ id: userId });

    if (user.walletBalance < coinsRequired) {
      throw new BadRequestException(
        `Insufficient coins. Need ${coinsRequired}, have ${user.walletBalance}.`,
      );
    }

    const product = await this.tremendousService.getProduct(dto.productId);
    if (!product) {
      throw new BadRequestException(
        `Product ${dto.productId} not found in Tremendous catalog.`,
      );
    }

    const validSku = product.skus?.some(
      (sku) => dto.amount >= sku.min && dto.amount <= sku.max,
    );
    if (!validSku) {
      const ranges = product.skus
        ?.map((s) => `$${s.min}-$${s.max}`)
        .join(', ');
      throw new BadRequestException(
        `Amount $${dto.amount} is outside allowed denominations for ${product.name}: ${ranges}`,
      );
    }

    const externalId = `blockapp_${userId}_${Date.now()}`;
    const order = await this.tremendousService.createOrder({
      productId: dto.productId,
      amount: dto.amount,
      currency,
      recipientName: user.displayName,
      recipientEmail: user.email,
      externalId,
    });

    if (!order) {
      throw new InternalServerErrorException(
        'Failed to create Tremendous order. Please try again.',
      );
    }

    const redemption = this.redemptionRepo.create({
      userId,
      productId: dto.productId,
      productName: product.name,
      faceValue: dto.amount,
      currency,
      pointsSpent: coinsRequired,
      tremendousOrderId: order.id,
      tremendousRewardId: order.reward.id,
      redemptionLink: order.reward.delivery?.link,
      status: 'delivered',
    });
    await this.redemptionRepo.save(redemption);

    user.walletBalance -= coinsRequired;
    await this.userRepo.save(user);

    const transaction = this.transactionRepo.create({
      userId,
      type: TransactionType.GIFT_CARD_PURCHASE,
      points: -coinsRequired,
      description: `Gift card: ${product.name} ($${dto.amount})`,
    });
    await this.transactionRepo.save(transaction);

    return {
      success: true,
      orderId: order.id,
      rewardId: order.reward.id,
      redemptionLink: order.reward.delivery?.link,
      coinsSpent: coinsRequired,
      newBalance: user.walletBalance,
    };
  }

  async getHistory(
    userId: string,
    query: RedemptionHistoryQueryDto,
  ): Promise<PaginatedResponseDto<RedemptionHistoryDto>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    const [items, total] = await this.redemptionRepo.findAndCount({
      where: { userId },
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    const data: RedemptionHistoryDto[] = items.map((r) => ({
      id: r.id,
      orderId: r.tremendousOrderId,
      productName: r.productName,
      faceValue: Number(r.faceValue),
      currency: r.currency,
      coinCost: r.pointsSpent,
      redemptionLink: r.redemptionLink,
      status: r.status,
      redeemedAt: r.createdAt,
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
