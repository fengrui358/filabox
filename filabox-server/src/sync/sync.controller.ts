import { Controller, Post, Get, Body, Query } from '@nestjs/common';
import { SyncService } from './sync.service';
import { SyncPushDto } from './dto/sync.dto';

@Controller('sync')
export class SyncController {
  constructor(private readonly service: SyncService) {}

  @Post('push')
  push(@Body() dto: SyncPushDto) {
    return this.service.push(dto);
  }

  @Get('pull')
  pull(@Query('since') since: string) {
    return this.service.pull(since);
  }
}
