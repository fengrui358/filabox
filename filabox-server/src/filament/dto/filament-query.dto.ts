import { IsOptional, IsString, IsNumber } from 'class-validator';
import { Type } from 'class-transformer';

export class FilamentQueryDto {
  @IsOptional()
  @IsString()
  brand?: string;

  @IsOptional()
  @IsString()
  model?: string;

  @IsOptional()
  @IsString()
  colorName?: string;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  diameter?: number;

  @IsOptional()
  @IsString()
  search?: string;
}
