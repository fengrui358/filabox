import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'filabox.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE filament_type (
            id TEXT PRIMARY KEY,
            code TEXT NOT NULL UNIQUE,
            brand TEXT NOT NULL DEFAULT 'Bambu Lab',
            model TEXT NOT NULL,
            diameter REAL NOT NULL DEFAULT 1.75,
            color_name TEXT NOT NULL,
            color_hex TEXT,
            print_temp_min INTEGER,
            print_temp_max INTEGER,
            bake_temp INTEGER,
            bake_time_min INTEGER,
            purchase_price REAL,
            min_price REAL,
            sku TEXT,
            notes TEXT,
            link TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE position (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL DEFAULT 'printer',
            sort_order INTEGER NOT NULL DEFAULT 0,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');

        await db.execute('''
          CREATE TABLE inventory_item (
            id TEXT PRIMARY KEY,
            filament_type_id TEXT NOT NULL REFERENCES filament_type(id),
            status TEXT NOT NULL DEFAULT 'standby',
            actual_price REAL,
            loaded_position_id TEXT REFERENCES position(id),
            loaded_at TEXT,
            unloaded_at TEXT,
            remaining_percent REAL NOT NULL DEFAULT 100.0,
            notes TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE usage_record (
            id TEXT PRIMARY KEY,
            inventory_item_id TEXT NOT NULL REFERENCES inventory_item(id),
            action TEXT NOT NULL,
            position_id TEXT REFERENCES position(id),
            occurred_at TEXT NOT NULL DEFAULT (datetime('now')),
            duration_minutes INTEGER,
            metadata TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');

        await db.execute('''
          CREATE TABLE sync_queue (
            id TEXT PRIMARY KEY,
            operation TEXT NOT NULL,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            synced_at TEXT,
            retry_count INTEGER NOT NULL DEFAULT 0,
            error TEXT
          )
        ''');

        // Indexes
        await db.execute('CREATE INDEX idx_filament_type_code ON filament_type(code)');
        await db.execute('CREATE INDEX idx_filament_type_brand ON filament_type(brand)');
        await db.execute('CREATE INDEX idx_inventory_item_status ON inventory_item(status)');
        await db.execute('CREATE INDEX idx_inventory_item_type ON inventory_item(filament_type_id)');
        await db.execute('CREATE INDEX idx_usage_record_item ON usage_record(inventory_item_id)');
        await db.execute('CREATE INDEX idx_sync_queue_pending ON sync_queue(synced_at)');
      },
    );
  }
}
