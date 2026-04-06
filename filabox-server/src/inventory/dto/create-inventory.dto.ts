import { IsString, IsOptional, IsNumber, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateInventoryDto {
  @ApiProperty({ description: '耗材类型ID' })
  @IsString()
  filamentTypeId: string;

  @ApiPropertyOptional({ description: '状态', example: 'standby', enum: ['standby', 'loaded', 'drying', 'used_up'] })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: '实际价格', example: 59.9 })
  @IsOptional()
  @IsNumber()
  actualPrice?: number;

  @ApiPropertyOptional({ description: '装载位置ID' })
  @IsOptional()
  @IsString()
  loadedPositionId?: string;

  @ApiPropertyOptional({ description: '剩余百分比', example: 100 })
  @IsOptional()
  @IsNumber()
  remainingPercent?: number;

  @ApiPropertyOptional({ description: '备注' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class UpdateStatusDto {
  @ApiProperty({ description: '目标状态', enum: ['standby', 'loaded', 'drying', 'used_up'] })
  @IsString()
  status: string;

  @ApiPropertyOptional({ description: '装载位置ID（装机时必填）' })
  @IsOptional()
  @IsString()
  loadedPositionId?: string;

  @ApiPropertyOptional({ description: '剩余百分比（下机时填写）', example: 75 })
  @IsOptional()
  @IsNumber()
  remainingPercent?: number;
}
