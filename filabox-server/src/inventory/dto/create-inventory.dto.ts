import { IsString, IsOptional, IsNumber, IsEnum } from 'class-validator';

export class CreateInventoryDto {
  @IsString()
  filamentTypeId: string;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsNumber()
  actualPrice?: number;

  @IsOptional()
  @IsString()
  loadedPositionId?: string;

  @IsOptional()
  @IsNumber()
  remainingPercent?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}

export class UpdateStatusDto {
  @IsString()
  status: string;

  @IsOptional()
  @IsString()
  loadedPositionId?: string;

  @IsOptional()
  @IsNumber()
  remainingPercent?: number;
}
