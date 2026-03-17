import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api');
  app.enableCors();
  app.useGlobalPipes(
    new ValidationPipe({ whitelist: true, transform: true }),
  );

  const config = new DocumentBuilder()
    .setTitle('ManyBoost API')
    .setDescription(
      'Backend API for ManyBoost — the screen time rewards app. ' +
        'Users earn 1 point per minute of social media usage (up to a configurable cap). ' +
        'Once the cap is reached, they collect points and redeem them for gift cards, cash out, raffles, or charity.',
    )
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('Auth', 'Email/password sign-in, token refresh, logout')
    .addTag('Users', 'User profile, onboarding, preferences')
    .addTag('Wallet', 'Point balance, transaction ledger')
    .addTag('Events', 'Screen time sync, point collection')
    .addTag('Stats', 'Daily screen time, weekly trends, collection streaks')
    .addTag('Raffles', 'Daily/weekly/monthly raffles')
    .addTag('Referrals', 'Referral earnings from children and grandchildren')
    .addTag('Leaderboard', 'Weekly leaderboard rankings')
    .addTag('Gift Cards', 'Gift card catalog and redemption')
    .addTag('Cash Out', 'Cash out requests and history')
    .addTag('Charity', 'Charity donations')
    .addTag('Games', 'Mini-games to earn points')
    .addTag('Tasks', 'Offer-wall tasks to earn points')
    .addTag('Surveys', 'Surveys to earn points')
    .addTag('Config', 'Remote app configuration')
    .addTag('Devices', 'Push notification token registration')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  await app.listen(3000);
  console.log('Server running on http://localhost:3000');
  console.log('Swagger docs at http://localhost:3000/docs');
}
bootstrap();
