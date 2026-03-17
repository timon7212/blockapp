import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThanOrEqual, Repository, IsNull } from 'typeorm';
import { RaffleEntity, RaffleType } from './entities/raffle.entity';
import { RaffleEntryEntity } from './entities/raffle-entry.entity';
import { RafflePrerequisiteEntity } from './entities/raffle-prerequisite.entity';
import { WalletService } from '../wallet/wallet.service';
import { TransactionType } from '../wallet/entities/transaction.entity';

const NEXT_DRAW_OFFSETS: Record<RaffleType, number> = {
  [RaffleType.DAILY]: 1,
  [RaffleType.WEEKLY]: 7,
  [RaffleType.MONTHLY]: 30,
};

@Injectable()
export class RaffleCronService {
  private readonly logger = new Logger(RaffleCronService.name);

  constructor(
    @InjectRepository(RaffleEntity)
    private readonly raffleRepo: Repository<RaffleEntity>,
    @InjectRepository(RaffleEntryEntity)
    private readonly entryRepo: Repository<RaffleEntryEntity>,
    @InjectRepository(RafflePrerequisiteEntity)
    private readonly prereqRepo: Repository<RafflePrerequisiteEntity>,
    private readonly walletService: WalletService,
  ) {}

  @Cron(CronExpression.EVERY_MINUTE)
  async handleRaffleDraw(): Promise<void> {
    const now = new Date();
    const expiredRaffles = await this.raffleRepo.find({
      where: {
        active: true,
        winnerId: IsNull(),
        drawDate: LessThanOrEqual(now),
      },
      relations: ['prerequisites'],
    });

    for (const raffle of expiredRaffles) {
      await this.drawRaffle(raffle);
    }
  }

  async drawRaffle(raffle: RaffleEntity): Promise<void> {
    const entries = await this.entryRepo.find({
      where: { raffleId: raffle.id },
    });

    if (entries.length === 0) {
      this.logger.log(
        `Raffle "${raffle.title}" (${raffle.id}) expired with no entries — deactivating`,
      );
      raffle.active = false;
      await this.raffleRepo.save(raffle);
    } else {
      const winnerEntry = entries[Math.floor(Math.random() * entries.length)];
      raffle.winnerId = winnerEntry.userId;
      raffle.active = false;
      await this.raffleRepo.save(raffle);

      await this.walletService.addTransaction(
        winnerEntry.userId,
        TransactionType.RAFFLE_WIN,
        raffle.prizeAmount,
        `Won raffle: ${raffle.title}`,
      );

      this.logger.log(
        `Raffle "${raffle.title}" drawn — winner: ${winnerEntry.userId}, prize: ${raffle.prizeAmount} pts`,
      );
    }

    await this.createNextRaffle(raffle);
  }

  private async createNextRaffle(previous: RaffleEntity): Promise<void> {
    const offsetDays = NEXT_DRAW_OFFSETS[previous.type];
    const nextDrawDate = new Date(previous.drawDate);
    nextDrawDate.setDate(nextDrawDate.getDate() + offsetDays);

    const next = this.raffleRepo.create({
      title: previous.title,
      type: previous.type,
      prizeAmount: previous.prizeAmount,
      drawDate: nextDrawDate,
      active: true,
    });
    const savedNext = await this.raffleRepo.save(next);

    if (previous.prerequisites?.length > 0) {
      const newPrereqs = previous.prerequisites.map((p) =>
        this.prereqRepo.create({
          raffleId: savedNext.id,
          type: p.type,
          requiredCount: p.requiredCount,
        }),
      );
      await this.prereqRepo.save(newPrereqs);
    }

    this.logger.log(
      `Created next ${previous.type} raffle "${next.title}" — draws at ${nextDrawDate.toISOString()}`,
    );
  }
}
