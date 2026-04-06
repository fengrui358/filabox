import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { FilamentService } from './filament.service';
import { CreateFilamentDto } from './dto/create-filament.dto';
import { UpdateFilamentDto } from './dto/update-filament.dto';
import { FilamentQueryDto } from './dto/filament-query.dto';

@ApiTags('耗材类型')
@Controller('filament-types')
export class FilamentController {
  constructor(private readonly service: FilamentService) {}

  @Get()
  @ApiOperation({ summary: '获取耗材列表', description: '支持按品牌、型号、颜色、直径筛选和全文搜索' })
  findAll(@Query() query: FilamentQueryDto) {
    return this.service.findAll(query);
  }

  @Get('code/:code')
  @ApiOperation({ summary: '按编码查找耗材', description: '通过唯一编码获取耗材类型' })
  findByCode(@Param('code') code: string) {
    return this.service.findByCode(code);
  }

  @Post('import')
  @ApiOperation({ summary: '批量导入耗材', description: '按编码 upsert，存在则更新，不存在则创建' })
  batchImport(@Body() items: CreateFilamentDto[]) {
    return this.service.batchImport(items);
  }

  @Get(':id')
  @ApiOperation({ summary: '获取耗材详情', description: '通过ID获取耗材类型，包含关联的库存列表' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: '创建耗材类型' })
  create(@Body() dto: CreateFilamentDto) {
    return this.service.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: '更新耗材类型' })
  update(@Param('id') id: string, @Body() dto: UpdateFilamentDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除耗材类型（软删除）' })
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
