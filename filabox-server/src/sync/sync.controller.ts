import { Controller, Post, Get, Body, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { SyncService } from './sync.service';
import { SyncPushDto } from './dto/sync.dto';

@ApiTags('数据同步')
@Controller('sync')
export class SyncController {
  constructor(private readonly service: SyncService) {}

  @Post('push')
  @ApiOperation({ summary: '推送本地变更', description: '将客户端本地操作推送到服务器，按顺序执行 create/update/delete' })
  push(@Body() dto: SyncPushDto) {
    return this.service.push(dto);
  }

  @Get('pull')
  @ApiOperation({ summary: '拉取服务端变更', description: '获取指定时间之后的所有变更，用于同步到客户端' })
  @ApiQuery({ name: 'since', required: true, description: 'ISO 8601 时间戳，拉取此时间之后的变更' })
  pull(@Query('since') since: string) {
    return this.service.pull(since);
  }
}
