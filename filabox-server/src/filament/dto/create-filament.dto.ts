import {
  IsString,
  IsOptional,
  IsNumber,
  IsBoolean,
  IsUrl,
  Min,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateFilamentDto {
  @ApiProperty({ description: '耗材编码（唯一标识）', example: 'BL-PLA-BK' })
  @IsString()
  code: string;

  @ApiPropertyOptional({ description: '品牌', example: 'Bambu Lab' })
  @IsOptional()
  @IsString()
  brand?: string;

  @ApiProperty({ description: '型号', example: 'PLA Basic' })
  @IsString()
  model: string;

  @ApiPropertyOptional({ description: '直径 (mm)', example: 1.75 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  diameter?: number;

  @ApiProperty({ description: '颜色名称', example: 'Black' })
  @IsString()
  colorName: string;

  @ApiPropertyOptional({ description: '颜色十六进制代码', example: '#1A1A1A' })
  @IsOptional()
  @IsString()
  colorHex?: string;

  @ApiPropertyOptional({ description: '最低打印温度 (°C)', example: 190 })
  @IsOptional()
  @IsNumber()
  printTempMin?: number;

  @ApiPropertyOptional({ description: '最高打印温度 (°C)', example: 230 })
  @IsOptional()
  @IsNumber()
  printTempMax?: number;

  @ApiPropertyOptional({ description: '烘烤温度 (°C)', example: 55 })
  @IsOptional()
  @IsNumber()
  bakeTemp?: number;

  @ApiPropertyOptional({ description: '烘烤时间 (分钟)', example: 480 })
  @IsOptional()
  @IsNumber()
  bakeTimeMin?: number;

  @ApiPropertyOptional({ description: '购买价格', example: 59.9 })
  @IsOptional()
  @IsNumber()
  purchasePrice?: number;

  @ApiPropertyOptional({ description: '最低价格', example: 39.9 })
  @IsOptional()
  @IsNumber()
  minPrice?: number;

  @ApiPropertyOptional({ description: 'SKU' })
  @IsOptional()
  @IsString()
  sku?: string;

  @ApiPropertyOptional({ description: '备注' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: '购买链接' })
  @IsOptional()
  @IsString()
  link?: string;
}
