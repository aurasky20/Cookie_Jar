
class Cookies {
  final int? id;
  final String namaProduk;
  final double harga;
  final int stok;
  final int terjual;
  final String komposisi;
  final String deskripsi;
  final String linkFoto;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool isNew;

  Cookies({
  this.id,
  required this.namaProduk,
  required this.harga,
  required this.stok,
  required this.komposisi,
  required this.deskripsi,
  required this.linkFoto,
  required this.terjual,
  required this.createdAt,
  required this.updatedAt,
  this.isNew = false, // default false
});

factory Cookies.fromJson(Map<String, dynamic> json) {
  return Cookies(
    id: json['id'],
    namaProduk: json['nama_produk'],
    harga: json['harga'],
    stok: json['stok'],
    komposisi: json['komposisi'],
    deskripsi: json['deskripsi'],
    linkFoto: json['link_foto'],
    terjual: json['terjual'] ?? 0,
    isNew: json['is_new'] ?? false, // pastikan ada field is_new di database
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'terjual': terjual,
      'komposisi': komposisi,
      'deskripsi': deskripsi,
      'link_foto': linkFoto,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper method untuk parsing harga yang bisa berupa int atau double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Method untuk insert ke Supabase
  Map<String, dynamic> toInsert() {
    return {
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'terjual': terjual,
      'komposisi': komposisi,
      'deskripsi': deskripsi,
      'link_foto': linkFoto,
    };
  }

  // Method untuk update ke Supabase
  Map<String, dynamic> toUpdate() {
    return {
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'terjual': terjual,
      'komposisi': komposisi,
      'deskripsi': deskripsi,
      'link_foto': linkFoto,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
