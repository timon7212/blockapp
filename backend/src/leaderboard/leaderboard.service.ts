import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { MoreThan, Repository } from 'typeorm';
import { UserEntity } from '../auth/entities/user.entity';
import {
  LeaderboardQueryDto,
  PaginatedLeaderboardDto,
  LeaderboardEntryDto,
  UserRankDto,
} from './dto/leaderboard.dto';

@Injectable()
export class LeaderboardService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
  ) {}

  async getWeeklyLeaderboard(
    query: LeaderboardQueryDto,
  ): Promise<PaginatedLeaderboardDto> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const [users, total] = await this.userRepo.findAndCount({
      order: { weeklyPoints: 'DESC' },
      skip,
      take: limit,
    });

    const data: LeaderboardEntryDto[] = users.map((user, index) => ({
      rank: skip + index + 1,
      userId: user.id,
      username: user.displayName,
      avatarUrl: user.avatarUrl,
      coins: user.weeklyPoints,
    }));

    const totalPages = Math.ceil(total / limit) || 1;

    return {
      data,
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

  async getUserRank(userId: string): Promise<UserRankDto> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const rank =
      (await this.userRepo.count({
        where: { weeklyPoints: MoreThan(user.weeklyPoints) },
      })) + 1;

    const above = await this.userRepo
      .createQueryBuilder('u')
      .where('u.weeklyPoints > :pts', { pts: user.weeklyPoints })
      .orderBy('u.weeklyPoints', 'ASC')
      .limit(2)
      .getMany();

    const below = await this.userRepo
      .createQueryBuilder('u')
      .where('u.weeklyPoints < :pts', { pts: user.weeklyPoints })
      .orderBy('u.weeklyPoints', 'DESC')
      .limit(2)
      .getMany();

    const surroundingUsers = [...above.reverse(), ...below];

    const surrounding: LeaderboardEntryDto[] = [];
    for (const s of surroundingUsers) {
      const sRank =
        (await this.userRepo.count({
          where: { weeklyPoints: MoreThan(s.weeklyPoints) },
        })) + 1;

      surrounding.push({
        rank: sRank,
        userId: s.id,
        username: s.displayName,
        avatarUrl: s.avatarUrl,
        coins: s.weeklyPoints,
      });
    }

    return {
      rank,
      coins: user.weeklyPoints,
      surrounding,
    };
  }
}
