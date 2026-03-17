import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsEnum } from 'class-validator';

export enum Platform {
  IOS = 'ios',
  ANDROID = 'android',
}

export class RegisterDeviceDto {
  @ApiProperty({ enum: Platform })
  @IsEnum(Platform)
  platform: Platform;

  @ApiProperty({ description: 'FCM or APNs push token' })
  @IsString()
  pushToken: string;
}

export class DeviceResponseDto {
  @ApiProperty()
  deviceId: string;

  @ApiProperty({ enum: Platform })
  platform: Platform;

  @ApiProperty()
  registered: boolean;
}
