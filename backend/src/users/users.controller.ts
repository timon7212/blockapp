import { Controller, Get, Patch, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiCreatedResponse } from '@nestjs/swagger';
import { UpdateProfileDto, OnboardingDto, UserProfileDto } from './dto/users.dto';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiOkResponse({ type: UserProfileDto })
  async getProfile(@CurrentUser('id') userId: string): Promise<UserProfileDto> {
    return this.usersService.getProfile(userId);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update user profile' })
  @ApiOkResponse({ type: UserProfileDto })
  async updateProfile(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateProfileDto,
  ): Promise<UserProfileDto> {
    return this.usersService.updateProfile(userId, dto);
  }

  @Post('me/onboarding')
  @ApiOperation({
    summary: 'Submit onboarding selections',
    description: 'Saves which social apps the user wants to track and their goal.',
  })
  @ApiCreatedResponse({ type: UserProfileDto })
  async submitOnboarding(
    @CurrentUser('id') userId: string,
    @Body() dto: OnboardingDto,
  ): Promise<UserProfileDto> {
    return this.usersService.submitOnboarding(userId, dto);
  }
}
