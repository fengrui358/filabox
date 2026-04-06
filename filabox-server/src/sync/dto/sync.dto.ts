import { IsString, IsArray, IsOptional, IsDateString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SyncOperationDto {
  @ApiProperty({ description: '操作类型', enum: ['create', 'update', 'delete'] })
  @IsString()
  operation: string;

  @ApiProperty({ description: '实体类型', enum: ['filament_type', 'inventory_item', 'usage_record', 'position'] })
  @IsString()
  entityType: string;

  @ApiProperty({ description: '实体ID' })
  @IsString()
  entityId: string;

  @ApiPropertyOptional({ description: '实体数据（create/update时需要）' })
  payload: any;

  @ApiProperty({ description: '操作时间（ISO 8601）', example: '2026-04-06T12:00:00.000Z' })
  @IsDateString()
  timestamp: string;
}

export class SyncPushDto {
  @ApiProperty({ description: '设备ID' })
  @IsString()
  deviceId: string;

  @ApiProperty({ description: '同步操作列表', type: [SyncOperationDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SyncOperationDto)
  operations: SyncOperationDto[];
}
