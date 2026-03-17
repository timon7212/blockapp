import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as sgMail from '@sendgrid/mail';

@Injectable()
export class EmailService implements OnModuleInit {
  private readonly logger = new Logger(EmailService.name);
  private fromEmail: string;
  private appName: string;
  private appUrl: string;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    const apiKey = this.configService.get<string>('SENDGRID_API_KEY', '');
    if (apiKey) {
      sgMail.setApiKey(apiKey);
      this.logger.log('SendGrid configured');
    } else {
      this.logger.warn(
        'SENDGRID_API_KEY is not set — emails will be logged to console',
      );
    }

    this.fromEmail = this.configService.get<string>(
      'SENDGRID_FROM_EMAIL',
      'noreply@manyboost.app',
    );
    this.appName = this.configService.get<string>('APP_NAME', 'ManyBoost');
    this.appUrl = this.configService.get<string>(
      'APP_URL',
      'http://localhost:3000',
    );
  }

  async sendVerificationEmail(
    to: string,
    displayName: string,
    token: string,
  ): Promise<void> {
    const verifyUrl = `${this.appUrl}/api/auth/verify-email?token=${token}`;

    const msg = {
      to,
      from: { email: this.fromEmail, name: this.appName },
      subject: `Verify your ${this.appName} account`,
      html: `
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 20px;">
          <h2 style="color: #1a1a1a; margin-bottom: 8px;">Welcome, ${displayName}!</h2>
          <p style="color: #666; font-size: 16px; line-height: 1.5;">
            Thanks for signing up for ${this.appName}. Please verify your email address to get started.
          </p>
          <a href="${verifyUrl}"
             style="display: inline-block; background: #1a1a1a; color: #fff; padding: 14px 32px;
                    border-radius: 12px; text-decoration: none; font-weight: 600; font-size: 16px;
                    margin: 24px 0;">
            Verify Email
          </a>
          <p style="color: #999; font-size: 13px; margin-top: 32px;">
            Or copy this link: <a href="${verifyUrl}" style="color: #666;">${verifyUrl}</a>
          </p>
          <p style="color: #999; font-size: 13px;">
            If you didn't create an account, you can safely ignore this email.
          </p>
        </div>
      `,
    };

    await this.send(msg);
  }

  async sendPasswordResetEmail(
    to: string,
    displayName: string,
    token: string,
  ): Promise<void> {
    const resetUrl = `${this.appUrl}/api/auth/reset-password?token=${token}`;

    const msg = {
      to,
      from: { email: this.fromEmail, name: this.appName },
      subject: `Reset your ${this.appName} password`,
      html: `
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 20px;">
          <h2 style="color: #1a1a1a; margin-bottom: 8px;">Password Reset</h2>
          <p style="color: #666; font-size: 16px; line-height: 1.5;">
            Hi ${displayName}, we received a request to reset your password. Click the button below to choose a new one.
          </p>
          <a href="${resetUrl}"
             style="display: inline-block; background: #1a1a1a; color: #fff; padding: 14px 32px;
                    border-radius: 12px; text-decoration: none; font-weight: 600; font-size: 16px;
                    margin: 24px 0;">
            Reset Password
          </a>
          <p style="color: #999; font-size: 13px; margin-top: 32px;">
            This link expires in 1 hour. If you didn't request a reset, ignore this email.
          </p>
        </div>
      `,
    };

    await this.send(msg);
  }

  private async send(msg: sgMail.MailDataRequired): Promise<void> {
    const apiKey = this.configService.get<string>('SENDGRID_API_KEY', '');
    if (!apiKey) {
      this.logger.log(
        `[EMAIL PREVIEW] To: ${msg.to} | Subject: ${msg.subject}`,
      );
      this.logger.debug(`HTML body logged (no SendGrid key configured)`);
      return;
    }

    try {
      await sgMail.send(msg);
      this.logger.log(`Email sent to ${msg.to}: "${msg.subject}"`);
    } catch (error: any) {
      this.logger.error(
        `SendGrid error: ${error?.response?.body?.errors?.[0]?.message || error.message}`,
      );
      throw error;
    }
  }
}
