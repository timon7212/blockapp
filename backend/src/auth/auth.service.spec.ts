import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UserEntity } from './entities/user.entity';
import { EmailService } from './email.service';
import { OAuth2Client } from 'google-auth-library';

jest.mock('google-auth-library');

const mockUser = (overrides: Partial<UserEntity> = {}): UserEntity =>
  ({
    id: 'user-uuid-1',
    email: 'test@gmail.com',
    passwordHash: null,
    displayName: 'Test User',
    avatarUrl: null,
    referralCode: 'ABCD1234',
    referredById: null,
    emailVerified: true,
    verificationToken: null,
    googleId: 'google-sub-123',
    refreshToken: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  }) as UserEntity;

describe('AuthService', () => {
  let service: AuthService;
  let userRepo: Record<string, jest.Mock>;
  let jwtService: Record<string, jest.Mock>;
  let mockVerifyIdToken: jest.Mock;

  beforeEach(async () => {
    userRepo = {
      findOne: jest.fn(),
      create: jest.fn((dto) => ({ ...dto, id: 'new-user-uuid' })),
      save: jest.fn((entity) => Promise.resolve(entity)),
      delete: jest.fn(),
    };

    jwtService = {
      signAsync: jest.fn().mockResolvedValue('mock-jwt-token'),
      verify: jest.fn(),
    };

    const configValues: Record<string, string> = {
      GOOGLE_CLIENT_ID: 'test-google-client-id',
      JWT_SECRET: 'test-secret',
      JWT_REFRESH_SECRET: 'test-refresh-secret',
      JWT_EXPIRES_IN: '15m',
      JWT_REFRESH_EXPIRES_IN: '7d',
    };

    mockVerifyIdToken = jest.fn();
    (OAuth2Client as jest.MockedClass<typeof OAuth2Client>).mockImplementation(
      () => ({ verifyIdToken: mockVerifyIdToken }) as any,
    );

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(UserEntity), useValue: userRepo },
        { provide: JwtService, useValue: jwtService },
        {
          provide: ConfigService,
          useValue: { get: jest.fn((key: string, def?: string) => configValues[key] ?? def) },
        },
        {
          provide: EmailService,
          useValue: {
            sendVerificationEmail: jest.fn(),
            sendPasswordResetEmail: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  const mockGooglePayload = (overrides: Record<string, any> = {}) => {
    const payload = {
      sub: 'google-sub-123',
      email: 'test@gmail.com',
      name: 'Test User',
      picture: 'https://lh3.googleusercontent.com/photo.jpg',
      ...overrides,
    };
    mockVerifyIdToken.mockResolvedValue({ getPayload: () => payload });
  };

  describe('signInWithGoogle', () => {
    it('creates a new user on first Google sign-in', async () => {
      mockGooglePayload();
      userRepo.findOne.mockResolvedValue(null);

      const result = await service.signInWithGoogle('valid-id-token');

      expect(mockVerifyIdToken).toHaveBeenCalledWith({
        idToken: 'valid-id-token',
        audience: 'test-google-client-id',
      });
      expect(userRepo.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: 'test@gmail.com',
          googleId: 'google-sub-123',
          displayName: 'Test User',
          emailVerified: true,
        }),
      );
      expect(userRepo.save).toHaveBeenCalled();
      expect(result.accessToken).toBeDefined();
      expect(result.refreshToken).toBeDefined();
      expect(result.user).toBeDefined();
    });

    it('logs in an existing user matched by googleId', async () => {
      mockGooglePayload();
      const existing = mockUser();
      userRepo.findOne.mockResolvedValueOnce(existing);

      const result = await service.signInWithGoogle('valid-id-token');

      expect(userRepo.create).not.toHaveBeenCalled();
      expect(result.user.email).toBe('test@gmail.com');
    });

    it('links Google to an existing email/password account', async () => {
      mockGooglePayload();
      const existing = mockUser({
        googleId: null as any,
        passwordHash: '$2b$12$hashedpassword',
        avatarUrl: null,
      });
      userRepo.findOne
        .mockResolvedValueOnce(null)
        .mockResolvedValueOnce(existing);

      const result = await service.signInWithGoogle('valid-id-token');

      expect(existing.googleId).toBe('google-sub-123');
      expect(existing.avatarUrl).toBe(
        'https://lh3.googleusercontent.com/photo.jpg',
      );
      expect(result.user.email).toBe('test@gmail.com');
    });

    it('does not overwrite existing avatar when linking', async () => {
      mockGooglePayload();
      const existing = mockUser({
        googleId: null as any,
        avatarUrl: 'https://existing-avatar.com/photo.jpg',
      });
      userRepo.findOne
        .mockResolvedValueOnce(null)
        .mockResolvedValueOnce(existing);

      await service.signInWithGoogle('valid-id-token');

      expect(existing.avatarUrl).toBe(
        'https://existing-avatar.com/photo.jpg',
      );
    });

    it('marks unverified email as verified on Google sign-in', async () => {
      mockGooglePayload();
      const existing = mockUser({
        emailVerified: false,
        verificationToken: 'some-token',
      });
      userRepo.findOne.mockResolvedValueOnce(existing);

      await service.signInWithGoogle('valid-id-token');

      expect(existing.emailVerified).toBe(true);
      expect(existing.verificationToken).toBeNull();
    });

    it('processes referral code for new Google user', async () => {
      mockGooglePayload();
      const referrer = mockUser({ id: 'referrer-uuid', referralCode: 'REF123' });
      userRepo.findOne
        .mockResolvedValueOnce(null)
        .mockResolvedValueOnce(null)
        .mockResolvedValueOnce(referrer);

      await service.signInWithGoogle('valid-id-token', 'REF123');

      expect(userRepo.create).toHaveBeenCalledWith(
        expect.objectContaining({ referredById: 'referrer-uuid' }),
      );
    });

    it('throws UnauthorizedException for invalid Google token', async () => {
      mockVerifyIdToken.mockRejectedValue(new Error('Invalid token'));

      await expect(service.signInWithGoogle('bad-token')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('throws UnauthorizedException when payload has no email', async () => {
      mockVerifyIdToken.mockResolvedValue({
        getPayload: () => ({ sub: 'google-sub-123' }),
      });

      await expect(service.signInWithGoogle('token-no-email')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('throws UnauthorizedException when payload is null', async () => {
      mockVerifyIdToken.mockResolvedValue({ getPayload: () => null });

      await expect(service.signInWithGoogle('token-null')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('uses email prefix as displayName when name is missing', async () => {
      mockGooglePayload({ name: undefined });
      userRepo.findOne.mockResolvedValue(null);

      await service.signInWithGoogle('valid-id-token');

      expect(userRepo.create).toHaveBeenCalledWith(
        expect.objectContaining({ displayName: 'test' }),
      );
    });
  });

  describe('login — Google-only account guard', () => {
    it('rejects password login for Google-only account', async () => {
      const googleOnlyUser = mockUser({ passwordHash: null });
      userRepo.findOne.mockResolvedValue(googleOnlyUser);

      await expect(
        service.login('test@gmail.com', 'any-password'),
      ).rejects.toThrow(UnauthorizedException);

      await expect(
        service.login('test@gmail.com', 'any-password'),
      ).rejects.toThrow('Google sign-in');
    });
  });

  describe('changePassword — Google-only account guard', () => {
    it('rejects password change for Google-only account', async () => {
      const googleOnlyUser = mockUser({ passwordHash: null });
      userRepo.findOne.mockResolvedValue(googleOnlyUser);

      await expect(
        service.changePassword('user-uuid-1', 'old', 'new'),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
