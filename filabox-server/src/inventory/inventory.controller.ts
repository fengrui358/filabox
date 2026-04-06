import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Patch,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { InventoryService } from './inventory.service';
import { CreateInventoryDto, UpdateStatusDto } from './dto/create-inventory.dto';
import { UpdateInventoryDto } from './dto/update-inventory.dto';

@ApiTags('库存管理')
@Controller('inventory')
export class InventoryController {
  constructor(private readonly service: InventoryService) {}

  @Get('stats')
  @ApiOperation({ summary: '获取库存统计', description: '返回各状态数量和总价值' })
  getStats() {
    return this.service.getStats();
  }

  @Get()
  @ApiOperation({ summary: '获取库存列表', description: '支持按状态和品牌筛选，返回带关联数据的库存列表' })
  @ApiQuery({ name: 'status', required: false, description: '按状态筛选' })
  @ApiQuery({ name: 'brand', required: false, description: '按品牌筛选' })
  findAll(
    @Query('status') status?: string,
    @Query('brand') brand?: string,
  ) {
    return this.service.findAll(status, brand);
  }

  @Get(':id')
  @ApiOperation({ summary: '获取库存详情', description: '包含耗材类型、位置和使用记录' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: '创建库存项（入库）', description: '自动创建 stocked 使用记录' })
  create(@Body() dto: CreateInventoryDto) {
    return this.service.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: '更新库存项' })
  update(@Param('id') id: string, @Body() dto: UpdateInventoryDto) {
    return this.service.update(id, dto);
  }

  @Patch(':id/status')
  @ApiOperation({
    summary: '更新库存状态',
    description: '状态流转：standby→loaded（装机）、loaded→standby（下机）、standby→drying（开始烘干）等，自动记录使用记录',
  })
  updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto) {
    return this.service.updateStatus(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除库存项（软删除）' })
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
