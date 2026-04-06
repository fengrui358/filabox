class QrPayload {
  final String code;
  final String type; // 'filament_type' or 'inventory'
  final String? inventoryId;
  final int version;

  const QrPayload({
    required this.code,
    required this.type,
    this.inventoryId,
    this.version = 1,
  });

  static QrPayload? parse(String raw) {
    if (!raw.startsWith('FILABOX:')) return null;

    final body = raw.substring(8); // after 'FILABOX:'
    final parts = body.split('?');
    if (parts.isEmpty) return null;

    final code = parts[0];
    String type = 'filament_type';
    String? inventoryId;
    int version = 1;

    if (parts.length > 1) {
      final params = Uri.splitQueryString(parts[1]);
      type = params['t'] ?? 'filament_type';
      inventoryId = params['i'];
      version = int.tryParse(params['v'] ?? '1') ?? 1;
    }

    return QrPayload(
      code: code,
      type: type,
      inventoryId: inventoryId,
      version: version,
    );
  }

  String encode() {
    final buffer = StringBuffer('FILABOX:$code');
    buffer.write('?v=$version&t=$type');
    if (inventoryId != null) {
      buffer.write('&i=$inventoryId');
    }
    return buffer.toString();
  }

  @override
  String toString() => 'QrPayload(code: $code, type: $type, inventoryId: $inventoryId)';
}
