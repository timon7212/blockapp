import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  HttpCode,
  HttpStatus,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiCreatedResponse, ApiOkResponse, ApiNoContentResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import {
  RegisterDto,
  LoginDto,
  ResendVerificationDto,
  ForgotPasswordDto,
  ResetPasswordDto,
  ChangePasswordDto,
  RefreshTokenDto,
  GoogleSignInDto,
  AuthResponseDto,
  MessageResponseDto,
} from './dto/auth.dto';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // ─── Email / Password ───

  @Post('register')
  @ApiOperation({
    summary: 'Register with email and password',
    description:
      'Creates a new account and sends a verification email via SendGrid. ' +
      'The user receives a JWT pair immediately but must verify their email before logging in again.',
  })
  @ApiCreatedResponse({ type: AuthResponseDto })
  async register(@Body() dto: RegisterDto): Promise<AuthResponseDto> {
    return this.authService.register(
      dto.email,
      dto.password,
      dto.displayName,
      dto.referralCode,
    );
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Login with email and password',
    description: 'Returns JWT pair. Requires verified email.',
  })
  @ApiOkResponse({ type: AuthResponseDto })
  async login(@Body() dto: LoginDto): Promise<AuthResponseDto> {
    return this.authService.login(dto.email, dto.password);
  }

  // ─── Email Verification ───

  @Get('verify-email')
  @ApiOperation({
    summary: 'Verify email address',
    description: 'Called when user clicks the verification link in their email.',
  })
  @ApiOkResponse({ type: MessageResponseDto })
  async verifyEmail(
    @Query('token') token: string,
  ): Promise<MessageResponseDto> {
    return this.authService.verifyEmail(token);
  }

  @Post('resend-verification')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Resend email verification link' })
  @ApiOkResponse({ type: MessageResponseDto })
  async resendVerification(
    @Body() dto: ResendVerificationDto,
  ): Promise<MessageResponseDto> {
    return this.authService.resendVerification(dto.email);
  }

  // ─── Password Reset ───

  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Request password reset email',
    description:
      'Sends a reset link to the email address. Always returns success to prevent email enumeration.',
  })
  @ApiOkResponse({ type: MessageResponseDto })
  async forgotPassword(
    @Body() dto: ForgotPasswordDto,
  ): Promise<MessageResponseDto> {
    return this.authService.forgotPassword(dto.email);
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Reset password with token',
    description: 'Token from the reset email. Invalidates all existing sessions.',
  })
  @ApiOkResponse({ type: MessageResponseDto })
  async resetPassword(
    @Body() dto: ResetPasswordDto,
  ): Promise<MessageResponseDto> {
    return this.authService.resetPassword(dto.token, dto.newPassword);
  }

  @Post('change-password')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Change password (authenticated)' })
  @ApiOkResponse({ type: MessageResponseDto })
  async changePassword(
    @CurrentUser('id') userId: string,
    @Body() dto: ChangePasswordDto,
  ): Promise<MessageResponseDto> {
    return this.authService.changePassword(
      userId,
      dto.currentPassword,
      dto.newPassword,
    );
  }

  // ─── Token Management ───

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Refresh access token',
    description: 'Rotates both access and refresh tokens.',
  })
  @ApiOkResponse({ type: AuthResponseDto })
  async refresh(@Body() dto: RefreshTokenDto): Promise<AuthResponseDto> {
    return this.authService.refreshTokens(dto.refreshToken);
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Logout and invalidate refresh token' })
  @ApiNoContentResponse({ description: 'Logged out successfully' })
  async logout(@CurrentUser('id') userId: string): Promise<void> {
    await this.authService.logout(userId);
  }

  // ─── Account ───

  @Delete('account')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete user account' })
  @ApiOkResponse({ description: 'Account deleted' })
  async deleteAccount(@CurrentUser('id') userId: string): Promise<void> {
    await this.authService.deleteAccount(userId);
  }

  // ─── Social Sign-In ───

  @Post('google')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Sign in with Google',
    description:
      'Verifies the Google ID token from the client SDK, creates or links the account, ' +
      'and returns a JWT pair. Email is automatically marked as verified.',
  })
  @ApiOkResponse({ type: AuthResponseDto })
  async signInWithGoogle(
    @Body() dto: GoogleSignInDto,
  ): Promise<AuthResponseDto> {
    return this.authService.signInWithGoogle(dto.idToken, dto.referralCode);
  }
}
