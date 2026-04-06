class FilamentType {
  final String id;
  final String code;
  final String brand;
  final String model;
  final double diameter;
  final String colorName;
  final String? colorHex;
  final int? printTempMin;
  final int? printTempMax;
  final int? bakeTemp;
  final int? bakeTimeMin;
  final double? purchasePrice;
  final double? minPrice;
  final String? sku;
  final String? notes;
  final String? link;
  final DateTime createdAt;
  final DateTime updatedAt;

  FilamentType({
    required this.id,
    required this.code,
    required this.brand,
    required this.model,
    required this.diameter,
    required this.colorName,
    this.colorHex,
    this.printTempMin,
    this.printTempMax,
    this.bakeTemp,
    this.bakeTimeMin,
    this.purchasePrice,
    this.minPrice,
    this.sku,
    this.notes,
    this.link,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FilamentType.fromMap(Map<String, dynamic> m) => FilamentType(
        id: m['id'] as String,
        code: m['code'] as String,
        brand: m['brand'] as String,
        model: m['model'] as String,
        diameter: (m['diameter'] as num).toDouble(),
        colorName: m['color_name'] as String,
        colorHex: m['color_hex'] as String?,
        printTempMin: m['print_temp_min'] as int?,
        printTempMax: m['print_temp_max'] as int?,
        bakeTemp: m['bake_temp'] as int?,
        bakeTimeMin: m['bake_time_min'] as int?,
        purchasePrice: (m['purchase_price'] as num?)?.toDouble(),
        minPrice: (m['min_price'] as num?)?.toDouble(),
        sku: m['sku'] as String?,
        notes: m['notes'] as String?,
        link: m['link'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'brand': brand,
        'model': model,
        'diameter': diameter,
        'color_name': colorName,
        'color_hex': colorHex,
        'print_temp_min': printTempMin,
        'print_temp_max': printTempMax,
        'bake_temp': bakeTemp,
        'bake_time_min': bakeTimeMin,
        'purchase_price': purchasePrice,
        'min_price': minPrice,
        'sku': sku,
        'notes': notes,
        'link': link,
        'updated_at': DateTime.now().toIso8601String(),
      };

  String get qrPayload => 'FILABOX:$code?v=1&t=filament_type';
}
