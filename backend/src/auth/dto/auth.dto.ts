import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsEmail, IsOptional, MinLength, MaxLength } from 'class-validator';

// ─── Registration ───

export class RegisterDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ minLength: 8, example: 'StrongP@ss1' })
  @IsString()
  @MinLength(8)
  password: string;

  @ApiProperty({ example: 'Alex' })
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  displayName: string;

  @ApiPropertyOptional({ description: 'Referral code from invite link' })
  @IsOptional()
  @IsString()
  referralCode?: string;
}

// ─── Login ───

export class LoginDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'StrongP@ss1' })
  @IsString()
  password: string;
}

// ─── Email verification ───

export class ResendVerificationDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;
}

// ─── Password reset ───

export class ForgotPasswordDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;
}

export class ResetPasswordDto {
  @ApiProperty({ description: 'Reset token from the email link' })
  @IsString()
  token: string;

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  newPassword: string;
}

export class ChangePasswordDto {
  @ApiProperty()
  @IsString()
  currentPassword: string;

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  newPassword: string;
}

// ─── Token refresh ───

export class RefreshTokenDto {
  @ApiProperty()
  @IsString()
  refreshToken: string;
}

// ─── Social sign-in ───

export class GoogleSignInDto {
  @ApiProperty({ description: 'Google OAuth2 ID token from the client SDK' })
  @IsString()
  idToken: string;

  @ApiPropertyOptional({ description: 'Referral code from invite link' })
  @IsOptional()
  @IsString()
  referralCode?: string;
}

// ─── Responses ───

export class UserSummaryDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  email: string;

  @ApiProperty()
  displayName: string;

  @ApiProperty()
  referralCode: string;

  @ApiProperty()
  emailVerified: boolean;

  @ApiProperty()
  joinedAt: Date;
}

export class AuthResponseDto {
  @ApiProperty()
  accessToken: string;

  @ApiProperty()
  refreshToken: string;

  @ApiProperty({ type: () => UserSummaryDto })
  user: UserSummaryDto;
}

export class MessageResponseDto {
  @ApiProperty()
  message: string;
}
