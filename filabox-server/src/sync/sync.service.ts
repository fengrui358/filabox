import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { SyncPushDto } from './dto/sync.dto';

@Injectable()
export class SyncService {
  constructor(private prisma: PrismaService) {}

  async push(dto: SyncPushDto) {
    const results: Array<{
      entityId: string;
      success: boolean;
      result?: any;
      error?: string;
    }> = [];

    for (const op of dto.operations) {
      try {
        let result;
        const data = op.payload;

        switch (op.entityType) {
          case 'filament_type':
            result = await this.applyFilamentTypeOp(op.operation, op.entityId, data);
            break;
          case 'inventory_item':
            result = await this.applyInventoryItemOp(op.operation, op.entityId, data);
            break;
          case 'usage_record':
            result = await this.applyUsageRecordOp(op.operation, op.entityId, data);
            break;
          case 'position':
            result = await this.applyPositionOp(op.operation, op.entityId, data);
            break;
          default:
            result = { error: `Unknown entity type: ${op.entityType}` };
        }
        results.push({ entityId: op.entityId, success: true, result });
      } catch (error: any) {
        results.push({
          entityId: op.entityId,
          success: false,
          error: error.message,
        });
      }
    }

    return { processed: results.length, results };
  }

  async pull(since: string) {
    const sinceDate = new Date(since);
    const changes: Array<{
      operation: string;
      entityType: string;
      entityId: string;
      payload: any;
      serverTimestamp: any;
    }> = [];

    const [filamentTypes, inventoryItems, usageRecords, positions] =
      await Promise.all([
        this.prisma.filamentType.findMany({
          where: { updatedAt: { gte: sinceDate } },
        }),
        this.prisma.inventoryItem.findMany({
          where: { updatedAt: { gte: sinceDate } },
        }),
        this.prisma.usageRecord.findMany({
          where: { createdAt: { gte: sinceDate } },
        }),
        this.prisma.position.findMany({
          where: { createdAt: { gte: sinceDate } },
        }),
      ]);

    for (const ft of filamentTypes) {
      changes.push({
        operation: ft.isDeleted ? 'delete' : 'update',
        entityType: 'filament_type',
        entityId: ft.id,
        payload: ft,
        serverTimestamp: ft.updatedAt,
      });
    }

    for (const item of inventoryItems) {
      changes.push({
        operation: item.isDeleted ? 'delete' : 'update',
        entityType: 'inventory_item',
        entityId: item.id,
        payload: item,
        serverTimestamp: item.updatedAt,
      });
    }

    for (const record of usageRecords) {
      changes.push({
        operation: 'create',
        entityType: 'usage_record',
        entityId: record.id,
        payload: record,
        serverTimestamp: record.createdAt,
      });
    }

    for (const pos of positions) {
      changes.push({
        operation: 'update',
        entityType: 'position',
        entityId: pos.id,
        payload: pos,
        serverTimestamp: pos.createdAt,
      });
    }

    return {
      changes,
      serverTime: new Date().toISOString(),
    };
  }

  private async applyFilamentTypeOp(op: string, id: string, data: any) {
    if (op === 'create') {
      return this.prisma.filamentType.create({ data: { id, ...data } });
    } else if (op === 'update') {
      return this.prisma.filamentType.update({ where: { id }, data });
    } else if (op === 'delete') {
      return this.prisma.filamentType.update({
        where: { id },
        data: { isDeleted: true },
      });
    }
  }

  private async applyInventoryItemOp(op: string, id: string, data: any) {
    if (op === 'create') {
      return this.prisma.inventoryItem.create({ data: { id, ...data } });
    } else if (op === 'update') {
      return this.prisma.inventoryItem.update({ where: { id }, data });
    } else if (op === 'delete') {
      return this.prisma.inventoryItem.update({
        where: { id },
        data: { isDeleted: true },
      });
    }
  }

  private async applyUsageRecordOp(op: string, id: string, data: any) {
    if (op === 'create') {
      return this.prisma.usageRecord.create({ data: { id, ...data } });
    }
  }

  private async applyPositionOp(op: string, id: string, data: any) {
    if (op === 'create') {
      return this.prisma.position.create({ data: { id, ...data } });
    } else if (op === 'update') {
      return this.prisma.position.update({ where: { id }, data });
    }
  }
}
