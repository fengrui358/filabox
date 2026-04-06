import { IsString, IsArray, IsOptional, IsDateString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class SyncOperationDto {
  @IsString()
  operation: string; // 'create' | 'update' | 'delete'

  @IsString()
  entityType: string; // 'filament_type' | 'inventory_item' | 'usage_record' | 'position'

  @IsString()
  entityId: string;

  payload: any;

  @IsDateString()
  timestamp: string;
}

export class SyncPushDto {
  @IsString()
  deviceId: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SyncOperationDto)
  operations: SyncOperationDto[];
}
