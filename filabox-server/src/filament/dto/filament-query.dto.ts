import { IsOptional, IsString, IsNumber } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class FilamentQueryDto {
  @ApiPropertyOptional({ description: '按品牌筛选（模糊匹配）', example: 'Bambu Lab' })
  @IsOptional()
  @IsString()
  brand?: string;

  @ApiPropertyOptional({ description: '按型号筛选（模糊匹配）', example: 'PLA Basic' })
  @IsOptional()
  @IsString()
  model?: string;

  @ApiPropertyOptional({ description: '按颜色名称筛选（模糊匹配）', example: 'Black' })
  @IsOptional()
  @IsString()
  colorName?: string;

  @ApiPropertyOptional({ description: '按直径筛选（精确匹配）', example: 1.75 })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  diameter?: number;

  @ApiPropertyOptional({ description: '全文搜索（编码/品牌/型号/颜色）', example: 'PLA' })
  @IsOptional()
  @IsString()
  search?: string;
}
