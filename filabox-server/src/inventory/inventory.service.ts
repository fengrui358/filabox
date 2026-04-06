import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateInventoryDto, UpdateStatusDto } from './dto/create-inventory.dto';
import { UpdateInventoryDto } from './dto/update-inventory.dto';
import { Prisma } from '@prisma/client';

@Injectable()
export class InventoryService {
  constructor(private prisma: PrismaService) {}

  async findAll(status?: string, brand?: string) {
    const where: Prisma.InventoryItemWhereInput = {
      isDeleted: false,
    };
    if (status) where.status = status;
    if (brand) {
      where.filamentType = { brand: { contains: brand } };
    }

    return this.prisma.inventoryItem.findMany({
      where,
      include: {
        filamentType: true,
        loadedPosition: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    return this.prisma.inventoryItem.findFirst({
      where: { id, isDeleted: false },
      include: {
        filamentType: true,
        loadedPosition: true,
        usageRecords: { orderBy: { occurredAt: 'desc' } },
      },
    });
  }

  async create(dto: CreateInventoryDto) {
    const item = await this.prisma.inventoryItem.create({
      data: { id: crypto.randomUUID(), ...dto },
    });

    await this.prisma.usageRecord.create({
      data: {
        id: crypto.randomUUID(),
        inventoryItemId: item.id,
        action: 'stocked',
        occurredAt: new Date(),
      },
    });

    return this.findOne(item.id);
  }

  async update(id: string, dto: UpdateInventoryDto) {
    return this.prisma.inventoryItem.update({
      where: { id },
      data: dto,
    });
  }

  async updateStatus(id: string, dto: UpdateStatusDto) {
    const item = await this.prisma.inventoryItem.update({
      where: { id },
      data: {
        status: dto.status,
        loadedPositionId: dto.loadedPositionId ?? null,
        remainingPercent: dto.remainingPercent ?? undefined,
      },
    });

    // Auto-set timestamps based on action
    if (dto.status === 'loaded') {
      await this.prisma.inventoryItem.update({
        where: { id },
        data: { loadedAt: new Date(), unloadedAt: null },
      });
    } else if (dto.status === 'used_up' || dto.status === 'standby') {
      const updateData: any = { unloadedAt: new Date() };
      if (dto.status === 'used_up') updateData.remainingPercent = 0;
      await this.prisma.inventoryItem.update({
        where: { id },
        data: updateData,
      });
    }

    // Create usage record
    const prevItem = await this.prisma.inventoryItem.findFirst({
      where: { id },
    });

    let durationMinutes: number | null = null;
    if (dto.status === 'used_up' || (dto.status === 'standby' && prevItem?.loadedAt)) {
      durationMinutes = prevItem?.loadedAt
        ? Math.round(
            (Date.now() - new Date(prevItem.loadedAt).getTime()) / 60000,
          )
        : null;
    }

    await this.prisma.usageRecord.create({
      data: {
        id: crypto.randomUUID(),
        inventoryItemId: id,
        action: dto.status === 'loaded' ? 'loaded' : dto.status === 'used_up' ? 'marked_used_up' : 'unloaded',
        positionId: dto.loadedPositionId ?? null,
        durationMinutes,
        occurredAt: new Date(),
      },
    });

    return this.findOne(id);
  }

  async remove(id: string) {
    return this.prisma.inventoryItem.update({
      where: { id },
      data: { isDeleted: true },
    });
  }

  async getStats() {
    const [standby, loaded, drying, usedUp] = await Promise.all([
      this.prisma.inventoryItem.count({ where: { status: 'standby', isDeleted: false } }),
      this.prisma.inventoryItem.count({ where: { status: 'loaded', isDeleted: false } }),
      this.prisma.inventoryItem.count({ where: { status: 'drying', isDeleted: false } }),
      this.prisma.inventoryItem.count({ where: { status: 'used_up', isDeleted: false } }),
    ]);

    const totalValue = await this.prisma.inventoryItem.aggregate({
      _sum: { actualPrice: true },
      where: { isDeleted: false, status: { not: 'used_up' } },
    });

    return {
      standby,
      loaded,
      drying,
      usedUp,
      total: standby + loaded + drying + usedUp,
      totalValue: totalValue._sum.actualPrice ?? 0,
    };
  }
}
