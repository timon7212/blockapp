import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiCreatedResponse } from '@nestjs/swagger';
import { RegisterDeviceDto, DeviceResponseDto } from './dto/devices.dto';
import { DevicesService } from './devices.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Devices')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('devices')
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Post()
  @ApiOperation({
    summary: 'Register push notification token',
    description: 'Register or update FCM/APNs token for push notifications.',
  })
  @ApiCreatedResponse({ type: DeviceResponseDto })
  async register(
    @CurrentUser('id') userId: string,
    @Body() dto: RegisterDeviceDto,
  ): Promise<DeviceResponseDto> {
    return this.devicesService.register(userId, dto);
  }
}
