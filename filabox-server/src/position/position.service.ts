import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreatePositionDto } from './dto/create-position.dto';

@Injectable()
export class PositionService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.position.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async create(dto: CreatePositionDto) {
    return this.prisma.position.create({
      data: {
        id: crypto.randomUUID(),
        ...dto,
      },
    });
  }

  async update(id: string, dto: Partial<CreatePositionDto>) {
    return this.prisma.position.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: string) {
    return this.prisma.position.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
