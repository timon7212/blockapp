import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ReferralStatsDto {
  @ApiProperty({ description: 'Number of users directly invited (children)' })
  directInvites: number;

  @ApiProperty({ description: 'Number of users invited by your invitees (grandchildren)' })
  grandChildInvites: number;

  @ApiProperty({ description: 'Commission % from direct invitees (children)' })
  childCommissionPercent: number;

  @ApiProperty({ description: 'Commission % from grandchildren' })
  grandChildCommissionPercent: number;

  @ApiProperty({ description: 'Pending points from direct invitees (requires ad to collect)' })
  pendingChildPoints: number;

  @ApiProperty({ description: 'Pending points from grandchildren (requires ad to collect)' })
  pendingGrandChildPoints: number;

  @ApiProperty({ description: 'Total referral points collected all time' })
  totalCollected: number;
}

export class CollectReferralResponseDto {
  @ApiProperty({ description: 'Level collected: child or grandchild' })
  level: 'child' | 'grandchild';

  @ApiProperty()
  pointsCollected: number;

  @ApiProperty()
  newBalance: number;
}

export class InviteLinkDto {
  @ApiProperty()
  inviteLink: string;

  @ApiProperty()
  referralCode: string;
}

export class InviteeDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  displayName: string;

  @ApiProperty()
  joinedAt: Date;

  @ApiProperty({ description: 'Total points this invitee has earned you' })
  pointsEarned: number;

  @ApiPropertyOptional({ description: 'Relationship level: child or grandchild' })
  level?: 'child' | 'grandchild';
}
