-- CreateTable
CREATE TABLE "filament_type" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "code" TEXT NOT NULL,
    "brand" TEXT NOT NULL DEFAULT 'Bambu Lab',
    "model" TEXT NOT NULL,
    "diameter" REAL NOT NULL DEFAULT 1.75,
    "color_name" TEXT NOT NULL,
    "color_hex" TEXT,
    "print_temp_min" INTEGER,
    "print_temp_max" INTEGER,
    "bake_temp" INTEGER,
    "bake_time_min" INTEGER,
    "purchase_price" REAL,
    "min_price" REAL,
    "sku" TEXT,
    "notes" TEXT,
    "link" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false
);

-- CreateTable
CREATE TABLE "inventory_item" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "filament_type_id" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'standby',
    "actual_price" REAL,
    "loaded_position_id" TEXT,
    "loaded_at" DATETIME,
    "unloaded_at" DATETIME,
    "remaining_percent" REAL NOT NULL DEFAULT 100,
    "notes" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "inventory_item_filament_type_id_fkey" FOREIGN KEY ("filament_type_id") REFERENCES "filament_type" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "inventory_item_loaded_position_id_fkey" FOREIGN KEY ("loaded_position_id") REFERENCES "position" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "usage_record" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "inventory_item_id" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "position_id" TEXT,
    "occurred_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "duration_minutes" INTEGER,
    "metadata" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "usage_record_inventory_item_id_fkey" FOREIGN KEY ("inventory_item_id") REFERENCES "inventory_item" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "usage_record_position_id_fkey" FOREIGN KEY ("position_id") REFERENCES "position" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "position" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'printer',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateIndex
CREATE UNIQUE INDEX "filament_type_code_key" ON "filament_type"("code");
