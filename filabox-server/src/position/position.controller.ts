import { Controller, Get, Post, Put, Delete, Body, Param } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { PositionService } from './position.service';
import { CreatePositionDto } from './dto/create-position.dto';

@ApiTags('位置管理')
@Controller('positions')
export class PositionController {
  constructor(private readonly service: PositionService) {}

  @Get()
  @ApiOperation({ summary: '获取位置列表', description: '返回所有激活位置，按排序序号排列' })
  findAll() {
    return this.service.findAll();
  }

  @Post()
  @ApiOperation({ summary: '创建位置', description: '创建打印机位、烘干箱或存储位' })
  create(@Body() dto: CreatePositionDto) {
    return this.service.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: '更新位置' })
  update(@Param('id') id: string, @Body() dto: Partial<CreatePositionDto>) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除位置（软删除）' })
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
