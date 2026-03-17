import { Controller, Get, Post, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiCreatedResponse } from '@nestjs/swagger';
import { CharityDto, DonateDto, DonationResponseDto } from './dto/charity.dto';
import { CharityService } from './charity.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Charity')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('charities')
export class CharityController {
  constructor(private readonly charityService: CharityService) {}

  @Get()
  @ApiOperation({ summary: 'List available charities' })
  @ApiOkResponse({ type: [CharityDto] })
  async getCharities(): Promise<CharityDto[]> {
    return this.charityService.getCharities();
  }

  @Post(':charityId/donate')
  @ApiOperation({ summary: 'Donate coins to a charity' })
  @ApiCreatedResponse({ type: DonationResponseDto })
  async donate(
    @CurrentUser('id') userId: string,
    @Param('charityId') charityId: string,
    @Body() dto: DonateDto,
  ): Promise<DonationResponseDto> {
    return this.charityService.donate(userId, charityId, dto.amount);
  }
}
