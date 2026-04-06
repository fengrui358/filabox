import { IsString, IsOptional, IsNumber, IsBoolean } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreatePositionDto {
  @ApiProperty({ description: '位置名称', example: 'AMS Slot 1' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ description: '类型', example: 'printer', enum: ['printer', 'dry_box', 'storage'] })
  @IsOptional()
  @IsString()
  type?: string;

  @ApiPropertyOptional({ description: '排序序号', example: 0 })
  @IsOptional()
  @IsNumber()
  sortOrder?: number;

  @ApiPropertyOptional({ description: '是否激活', example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
