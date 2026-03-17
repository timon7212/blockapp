import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { WalletModule } from './wallet/wallet.module';
import { EventsModule } from './events/events.module';
import { StatsModule } from './stats/stats.module';
import { RafflesModule } from './raffles/raffles.module';
import { ReferralsModule } from './referrals/referrals.module';
import { LeaderboardModule } from './leaderboard/leaderboard.module';
import { GiftCardsModule } from './gift-cards/gift-cards.module';
import { CashOutModule } from './cashout/cashout.module';
import { CharityModule } from './charity/charity.module';
import { AppConfigModule } from './config/config.module';
import { DevicesModule } from './devices/devices.module';
import { GamesModule } from './games/games.module';
import { TasksModule } from './tasks/tasks.module';
import { SurveysModule } from './surveys/surveys.module';
import { AdminModule } from './admin/admin.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get('DB_USERNAME', 'postgres'),
        password: config.get('DB_PASSWORD', 'postgres'),
        database: config.get('DB_DATABASE', 'manyboost'),
        autoLoadEntities: true,
        synchronize: config.get('DB_SYNCHRONIZE', 'true') === 'true',
        ssl: config.get('DB_SSL', 'false') === 'true'
          ? { rejectUnauthorized: false }
          : false,
      }),
    }),
    ScheduleModule.forRoot(),
    AuthModule,
    UsersModule,
    WalletModule,
    EventsModule,
    StatsModule,
    RafflesModule,
    ReferralsModule,
    LeaderboardModule,
    GiftCardsModule,
    CashOutModule,
    CharityModule,
    AppConfigModule,
    DevicesModule,
    GamesModule,
    TasksModule,
    SurveysModule,
    AdminModule,
  ],
})
export class AppModule {}
