import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateFilamentDto } from './dto/create-filament.dto';
import { UpdateFilamentDto } from './dto/update-filament.dto';
import { FilamentQueryDto } from './dto/filament-query.dto';
import { Prisma } from '@prisma/client';

@Injectable()
export class FilamentService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: FilamentQueryDto) {
    const where: Prisma.FilamentTypeWhereInput = {
      isDeleted: false,
    };

    if (query.brand) where.brand = { contains: query.brand };
    if (query.model) where.model = { contains: query.model };
    if (query.colorName) where.colorName = { contains: query.colorName };
    if (query.diameter) where.diameter = query.diameter;
    if (query.search) {
      where.OR = [
        { code: { contains: query.search } },
        { brand: { contains: query.search } },
        { model: { contains: query.search } },
        { colorName: { contains: query.search } },
      ];
    }

    return this.prisma.filamentType.findMany({
      where,
      orderBy: [{ brand: 'asc' }, { model: 'asc' }, { colorName: 'asc' }],
    });
  }

  async findOne(id: string) {
    return this.prisma.filamentType.findFirst({
      where: { id, isDeleted: false },
      include: { inventoryItems: { where: { isDeleted: false } } },
    });
  }

  async findByCode(code: string) {
    return this.prisma.filamentType.findFirst({
      where: { code, isDeleted: false },
    });
  }

  async create(dto: CreateFilamentDto) {
    return this.prisma.filamentType.create({
      data: { id: crypto.randomUUID(), ...dto },
    });
  }

  async update(id: string, dto: UpdateFilamentDto) {
    return this.prisma.filamentType.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: string) {
    return this.prisma.filamentType.update({
      where: { id },
      data: { isDeleted: true },
    });
  }

  async batchImport(items: CreateFilamentDto[]) {
    const results: any[] = [];
    for (const item of items) {
      const existing = await this.prisma.filamentType.findFirst({
        where: { code: item.code, isDeleted: false },
      });
      if (existing) {
        results.push(
          await this.prisma.filamentType.update({
            where: { id: existing.id },
            data: item,
          }),
        );
      } else {
        results.push(
          await this.prisma.filamentType.create({
            data: { id: crypto.randomUUID(), ...item },
          }),
        );
      }
    }
    return results;
  }
}
