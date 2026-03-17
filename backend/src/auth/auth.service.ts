import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';
import { UserEntity } from './entities/user.entity';
import { EmailService } from './email.service';

const SALT_ROUNDS = 12;
const RESET_TOKEN_EXPIRY_MS = 60 * 60 * 1000; // 1 hour

@Injectable()
export class AuthService {
  private readonly googleClient: OAuth2Client;

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly emailService: EmailService,
  ) {
    this.googleClient = new OAuth2Client(
      this.configService.get<string>('GOOGLE_CLIENT_ID'),
    );
  }

  async register(
    email: string,
    password: string,
    displayName: string,
    referralCode?: string,
  ) {
    const normalizedEmail = email.toLowerCase().trim();
    const existing = await this.userRepo.findOne({ where: { email: normalizedEmail } });
    if (existing) {
      throw new ConflictException('An account with this email already exists');
    }

    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
    const verificationToken = randomUUID();

    let referredById: string | null = null;
    if (referralCode) {
      const referrer = await this.userRepo.findOne({ where: { referralCode } });
      if (referrer) {
        referredById = referrer.id;
      }
    }

    const user = this.userRepo.create({
      email: normalizedEmail,
      passwordHash,
      displayName,
      referralCode: this.generateReferralCode(),
      referredById,
      emailVerified: false,
      verificationToken,
    });

    await this.userRepo.save(user);

    await this.emailService.sendVerificationEmail(
      user.email,
      user.displayName,
      verificationToken,
    );

    const tokens = await this.generateTokens(user);
    user.refreshToken = tokens.refreshToken;
    await this.userRepo.save(user);

    return { ...tokens, user: this.toUserSummary(user) };
  }

  async login(email: string, password: string) {
    const user = await this.userRepo.findOne({
      where: { email: email.toLowerCase().trim() },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    if (!user.passwordHash) {
      throw new UnauthorizedException(
        'This account uses Google sign-in. Please log in with Google.',
      );
    }

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    if (!user.emailVerified) {
      throw new UnauthorizedException(
        'Please verify your email before logging in',
      );
    }

    const tokens = await this.generateTokens(user);
    user.refreshToken = tokens.refreshToken;
    await this.userRepo.save(user);

    return { ...tokens, user: this.toUserSummary(user) };
  }

  async verifyEmail(token: string) {
    const user = await this.userRepo.findOne({ where: { verificationToken: token } });
    if (!user) {
      throw new BadRequestException('Invalid or expired verification token');
    }

    user.emailVerified = true;
    user.verificationToken = null;
    await this.userRepo.save(user);

    return { message: 'Email verified successfully' };
  }

  async resendVerification(email: string) {
    const user = await this.userRepo.findOne({
      where: { email: email.toLowerCase().trim() },
    });
    if (!user) {
      return { message: 'If the email exists, a verification link has been sent' };
    }

    if (user.emailVerified) {
      return { message: 'Email is already verified' };
    }

    const newToken = randomUUID();
    user.verificationToken = newToken;
    await this.userRepo.save(user);

    await this.emailService.sendVerificationEmail(
      user.email,
      user.displayName,
      newToken,
    );

    return { message: 'If the email exists, a verification link has been sent' };
  }

  async forgotPassword(email: string) {
    const user = await this.userRepo.findOne({
      where: { email: email.toLowerCase().trim() },
    });

    const response = {
      message: 'If the email exists, a password reset link has been sent',
    };

    if (!user) return response;

    const resetToken = randomUUID();
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = new Date(Date.now() + RESET_TOKEN_EXPIRY_MS);
    await this.userRepo.save(user);

    await this.emailService.sendPasswordResetEmail(
      user.email,
      user.displayName,
      resetToken,
    );

    return response;
  }

  async resetPassword(token: string, newPassword: string) {
    const user = await this.userRepo.findOne({
      where: {
        resetPasswordToken: token,
        resetPasswordExpires: MoreThan(new Date()),
      },
    });
    if (!user) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    user.passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
    user.resetPasswordToken = null;
    user.resetPasswordExpires = null;
    user.refreshToken = null;
    await this.userRepo.save(user);

    return { message: 'Password reset successfully. Please log in again.' };
  }

  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string,
  ) {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!user.passwordHash) {
      throw new BadRequestException(
        'Cannot change password for a Google sign-in account',
      );
    }

    const valid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!valid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    user.passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
    await this.userRepo.save(user);

    return { message: 'Password changed successfully' };
  }

  async refreshTokens(refreshToken: string) {
    const user = await this.userRepo.findOne({ where: { refreshToken } });
    if (!user) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    try {
      this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET', 'refresh-secret'),
      });
    } catch {
      user.refreshToken = null;
      await this.userRepo.save(user);
      throw new UnauthorizedException('Refresh token expired');
    }

    const tokens = await this.generateTokens(user);
    user.refreshToken = tokens.refreshToken;
    await this.userRepo.save(user);

    return { ...tokens, user: this.toUserSummary(user) };
  }

  async logout(userId: string) {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (user) {
      user.refreshToken = null;
      await this.userRepo.save(user);
    }
  }

  async deleteAccount(userId: string) {
    await this.userRepo.delete(userId);
  }

  async signInWithGoogle(idToken: string, referralCode?: string) {
    const ticket = await this.googleClient.verifyIdToken({
      idToken,
      audience: this.configService.get<string>('GOOGLE_CLIENT_ID'),
    }).catch(() => {
      throw new UnauthorizedException('Invalid Google ID token');
    });

    const payload = ticket.getPayload();
    if (!payload || !payload.email) {
      throw new UnauthorizedException('Invalid Google ID token payload');
    }

    const { sub: googleId, email, name, picture } = payload;

    let user = await this.userRepo.findOne({ where: { googleId } });

    if (!user) {
      user = await this.userRepo.findOne({
        where: { email: email.toLowerCase() },
      });

      if (user) {
        user.googleId = googleId;
        if (picture && !user.avatarUrl) {
          user.avatarUrl = picture;
        }
      }
    }

    if (!user) {
      let referredById: string | null = null;
      if (referralCode) {
        const referrer = await this.userRepo.findOne({
          where: { referralCode },
        });
        if (referrer) referredById = referrer.id;
      }

      user = this.userRepo.create({
        email: email.toLowerCase(),
        googleId,
        displayName: name || email.split('@')[0],
        avatarUrl: picture || null,
        referralCode: this.generateReferralCode(),
        referredById,
        emailVerified: true,
      });
    }

    if (!user.emailVerified) {
      user.emailVerified = true;
      user.verificationToken = null;
    }

    const tokens = await this.generateTokens(user);
    user.refreshToken = tokens.refreshToken;
    await this.userRepo.save(user);

    return { ...tokens, user: this.toUserSummary(user) };
  }

  async validateUserById(id: string): Promise<UserEntity | null> {
    return this.userRepo.findOne({ where: { id } });
  }

  private async generateTokens(user: UserEntity) {
    const payload = { sub: user.id, email: user.email };

    const accessExpiresIn = this.configService.get<string>('JWT_EXPIRES_IN', '15m');
    const refreshExpiresIn = this.configService.get<string>('JWT_REFRESH_EXPIRES_IN', '7d');

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('JWT_SECRET', 'access-secret'),
        expiresIn: accessExpiresIn as any,
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET', 'refresh-secret'),
        expiresIn: refreshExpiresIn as any,
      }),
    ]);

    return { accessToken, refreshToken };
  }

  private toUserSummary(user: UserEntity) {
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      referralCode: user.referralCode,
      emailVerified: user.emailVerified,
      joinedAt: user.createdAt,
    };
  }

  private generateReferralCode(): string {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 8; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }
}
