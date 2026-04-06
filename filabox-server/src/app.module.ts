import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma.module';
import { FilamentModule } from './filament/filament.module';
import { InventoryModule } from './inventory/inventory.module';
import { PositionModule } from './position/position.module';
import { SyncModule } from './sync/sync.module';

@Module({
  imports: [
    PrismaModule,
    FilamentModule,
    InventoryModule,
    PositionModule,
    SyncModule,
  ],
})
export class AppModule {}
