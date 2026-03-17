import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DeviceEntity } from './entities/device.entity';
import { RegisterDeviceDto, DeviceResponseDto } from './dto/devices.dto';

@Injectable()
export class DevicesService {
  constructor(
    @InjectRepository(DeviceEntity)
    private readonly deviceRepo: Repository<DeviceEntity>,
  ) {}

  async register(
    userId: string,
    dto: RegisterDeviceDto,
  ): Promise<DeviceResponseDto> {
    let device = await this.deviceRepo.findOne({
      where: { userId, platform: dto.platform },
    });

    if (device) {
      device.pushToken = dto.pushToken;
      await this.deviceRepo.save(device);
    } else {
      device = this.deviceRepo.create({
        userId,
        platform: dto.platform,
        pushToken: dto.pushToken,
      });
      await this.deviceRepo.save(device);
    }

    return {
      deviceId: device.id,
      platform: dto.platform,
      registered: true,
    };
  }
}
