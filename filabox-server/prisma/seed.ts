import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const BAMBU_LAB_FILAMENTS = [
  { code: 'BL-PETG-BK', model: 'PETG Basic', colorName: 'Black', colorHex: '#1A1A1A', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-WH', model: 'PETG Basic', colorName: 'White', colorHex: '#FFFFFF', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-GY', model: 'PETG Basic', colorName: 'Grey', colorHex: '#808080', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-RD', model: 'PETG Basic', colorName: 'Red', colorHex: '#E83030', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-BL', model: 'PETG Basic', colorName: 'Blue', colorHex: '#1E5098', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-GN', model: 'PETG Basic', colorName: 'Green', colorHex: '#009E60', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-YL', model: 'PETG Basic', colorName: 'Yellow', colorHex: '#FFD700', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-OR', model: 'PETG Basic', colorName: 'Orange', colorHex: '#FF6600', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-TP', model: 'PETG Basic', colorName: 'Transparent', colorHex: '#E8F0FE', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PETG-CB', model: 'PETG Basic', colorName: 'Cocoa Brown', colorHex: '#6B3A2A', printTempMin: 220, printTempMax: 260, bakeTemp: 65, bakeTimeMin: 480 },
  { code: 'BL-PLA-BK', model: 'PLA Basic', colorName: 'Black', colorHex: '#1A1A1A', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-WH', model: 'PLA Basic', colorName: 'White', colorHex: '#FFFFFF', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-GY', model: 'PLA Basic', colorName: 'Grey', colorHex: '#808080', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-RD', model: 'PLA Basic', colorName: 'Red', colorHex: '#E83030', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-BL', model: 'PLA Basic', colorName: 'Blue', colorHex: '#1E5098', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-GN', model: 'PLA Basic', colorName: 'Green', colorHex: '#009E60', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-YL', model: 'PLA Basic', colorName: 'Yellow', colorHex: '#FFD700', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-OR', model: 'PLA Basic', colorName: 'Orange', colorHex: '#FF6600', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-PK', model: 'PLA Basic', colorName: 'Pink', colorHex: '#FF69B4', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-PP', model: 'PLA Basic', colorName: 'Purple', colorHex: '#800080', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-SK', model: 'PLA Silk', colorName: 'Silver Silk', colorHex: '#C0C0C0', printTempMin: 200, printTempMax: 240, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-MG', model: 'PLA Matte', colorName: 'Matte Grey', colorHex: '#A0A0A0', printTempMin: 190, printTempMax: 230, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-ABS-BK', model: 'ABS', colorName: 'Black', colorHex: '#1A1A1A', printTempMin: 240, printTempMax: 280, bakeTemp: 80, bakeTimeMin: 480 },
  { code: 'BL-ABS-WH', model: 'ABS', colorName: 'White', colorHex: '#FFFFFF', printTempMin: 240, printTempMax: 280, bakeTemp: 80, bakeTimeMin: 480 },
  { code: 'BL-ASA-BK', model: 'ASA', colorName: 'Black', colorHex: '#1A1A1A', printTempMin: 240, printTempMax: 270, bakeTemp: 70, bakeTimeMin: 480 },
  { code: 'BL-ASA-GY', model: 'ASA', colorName: 'Grey', colorHex: '#808080', printTempMin: 240, printTempMax: 270, bakeTemp: 70, bakeTimeMin: 480 },
  { code: 'BL-TPU-BK', model: 'TPU', colorName: 'Black', colorHex: '#1A1A1A', printTempMin: 220, printTempMax: 240, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-TPU-WH', model: 'TPU', colorName: 'White', colorHex: '#FFFFFF', printTempMin: 220, printTempMax: 240, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PLA-CF', model: 'PLA-CF', colorName: 'Carbon Fiber Black', colorHex: '#2C2C2C', printTempMin: 220, printTempMax: 240, bakeTemp: 55, bakeTimeMin: 480 },
  { code: 'BL-PETG-CF', model: 'PETG-CF', colorName: 'Carbon Fiber Black', colorHex: '#2C2C2C', printTempMin: 240, printTempMax: 270, bakeTemp: 65, bakeTimeMin: 480 },
];

const DEFAULT_POSITIONS = [
  { id: crypto.randomUUID(), name: 'A1 Mini - Slot 1', type: 'printer', sortOrder: 1 },
  { id: crypto.randomUUID(), name: 'A1 Mini - Slot 2', type: 'printer', sortOrder: 2 },
  { id: crypto.randomUUID(), name: 'X1C - Slot 1', type: 'printer', sortOrder: 3 },
  { id: crypto.randomUUID(), name: 'X1C - Slot 2', type: 'printer', sortOrder: 4 },
  { id: crypto.randomUUID(), name: 'X1C - Slot 3', type: 'printer', sortOrder: 5 },
  { id: crypto.randomUUID(), name: 'X1C - Slot 4', type: 'printer', sortOrder: 6 },
  { id: crypto.randomUUID(), name: 'Dry Box A', type: 'dry_box', sortOrder: 10 },
  { id: crypto.randomUUID(), name: 'Dry Box B', type: 'dry_box', sortOrder: 11 },
  { id: crypto.randomUUID(), name: 'Storage Shelf', type: 'storage', sortOrder: 20 },
];

async function main() {
  console.log('Seeding database...');

  // Seed filament types
  for (const item of BAMBU_LAB_FILAMENTS) {
    await prisma.filamentType.upsert({
      where: { code: item.code },
      update: item,
      create: {
        id: crypto.randomUUID(),
        brand: 'Bambu Lab',
        diameter: 1.75,
        ...item,
      },
    });
  }
  console.log(`Seeded ${BAMBU_LAB_FILAMENTS.length} filament types`);

  // Seed positions
  for (const pos of DEFAULT_POSITIONS) {
    await prisma.position.upsert({
      where: { id: pos.id },
      update: pos,
      create: pos,
    });
  }
  console.log(`Seeded ${DEFAULT_POSITIONS.length} positions`);

  console.log('Seed completed!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
