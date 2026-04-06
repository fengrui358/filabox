import {
  IsString,
  IsOptional,
  IsNumber,
  IsBoolean,
  IsUrl,
  Min,
} from 'class-validator';

export class CreateFilamentDto {
  @IsString()
  code: string;

  @IsOptional()
  @IsString()
  brand?: string;

  @IsString()
  model: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  diameter?: number;

  @IsString()
  colorName: string;

  @IsOptional()
  @IsString()
  colorHex?: string;

  @IsOptional()
  @IsNumber()
  printTempMin?: number;

  @IsOptional()
  @IsNumber()
  printTempMax?: number;

  @IsOptional()
  @IsNumber()
  bakeTemp?: number;

  @IsOptional()
  @IsNumber()
  bakeTimeMin?: number;

  @IsOptional()
  @IsNumber()
  purchasePrice?: number;

  @IsOptional()
  @IsNumber()
  minPrice?: number;

  @IsOptional()
  @IsString()
  sku?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  link?: string;
}
