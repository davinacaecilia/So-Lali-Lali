// =====================================================
// KATEGORI
// =====================================================
class CategoryOption {
  final String key;
  final String label;
  final String prefix; // dipakai untuk kode bahan, mis. KRG-001
  const CategoryOption(this.key, this.label, this.prefix);
}

const List<CategoryOption> kCategories = [
  CategoryOption('bahan_kering', 'Bahan Kering', 'KRG'),
  CategoryOption('susu_olahan', 'Susu & Olahan Susu', 'SSU'),
  CategoryOption('daging_unggas', 'Daging & Unggas', 'DGG'),
  CategoryOption('seafood', 'Seafood', 'SEA'),
  CategoryOption('telur', 'Telur', 'TLR'),
  CategoryOption('sayur_buah', 'Sayur & Buah', 'SYB'),
  CategoryOption('bumbu_rempah', 'Bumbu & Rempah', 'BMB'),
  CategoryOption('minyak_lemak', 'Minyak & Lemak', 'MYK'),
  CategoryOption('minuman_sirup', 'Minuman & Sirup', 'MNM'),
  CategoryOption('bahan_beku', 'Bahan Beku', 'BKU'),
  CategoryOption('lainnya', 'Lainnya', 'LNY'),
];

CategoryOption categoryByKey(String key) => kCategories
    .firstWhere((c) => c.key == key, orElse: () => kCategories.last);

// =====================================================
// SATUAN
// =====================================================
class UnitOption {
  final String key; // disimpan di database, mis. "kg"
  final String label; // ditampilkan di aplikasi, mis. "kg"
  final String group; // BERAT | VOLUME | HITUNGAN | KUSTOM
  final String baseLabel; // satuan dasar penyimpanan, mis. "g"
  final int factor; // 1 kg = 1000 g
  final String? name; // nama lengkap di sheet, mis. "Kilogram"

  const UnitOption(
      this.key,
      this.label,
      this.group,
      this.baseLabel,
      this.factor, [
        this.name,
      ]);
}

const List<UnitOption> kUnits = [
  UnitOption('kg', 'kg', 'BERAT', 'g', 1000, 'Kilogram'),
  UnitOption('g', 'g', 'BERAT', 'g', 1, 'Gram'),
  UnitOption('l', 'L', 'VOLUME', 'ml', 1000, 'Liter'),
  UnitOption('ml', 'ml', 'VOLUME', 'ml', 1, 'Mililiter'),
  UnitOption('butir', 'butir', 'HITUNGAN', 'butir', 1),
  UnitOption('pcs', 'pcs', 'HITUNGAN', 'pcs', 1),
  UnitOption('pack', 'pack', 'HITUNGAN', 'pack', 1),
  UnitOption('botol', 'botol', 'HITUNGAN', 'botol', 1),
  UnitOption('kaleng', 'kaleng', 'HITUNGAN', 'kaleng', 1),
  UnitOption('sachet', 'sachet', 'HITUNGAN', 'sachet', 1),
  UnitOption('karton', 'karton', 'HITUNGAN', 'karton', 1),
];

/// Satuan khusus buatan user disimpan dengan kunci "x:<nama>", mis. "x:karung".
const String kCustomUnitPrefix = 'x:';

bool isCustomUnit(String key) => key.startsWith(kCustomUnitPrefix);

String customUnitKey(String label) =>
    '$kCustomUnitPrefix${label.trim().toLowerCase()}';

UnitOption unitByKey(String key) {
  for (final u in kUnits) {
    if (u.key == key) return u;
  }
  if (isCustomUnit(key)) {
    final label = key.substring(kCustomUnitPrefix.length);
    return UnitOption(key, label, 'KUSTOM', label, 1);
  }
  return kUnits.first;
}

/// Ubah jumlah satuan dasar (mis. 16000 g) menjadi teks tampilan ("16 kg").
String formatQty(int baseQty, UnitOption unit) {
  final value = baseQty / unit.factor;
  final text = value == value.roundToDouble()
      ? value.toInt().toString()
      : value
      .toStringAsFixed(2)
      .replaceAll(RegExp(r'\.?0+$'), '')
      .replaceAll('.', ',');
  return '$text ${unit.label}';
}

// =====================================================
// MASA SIMPAN & ALERT KEDALUWARSA
// =====================================================
class DurationOption {
  final String key;
  final String label;
  final int days;
  const DurationOption(this.key, this.label, this.days);
}

const List<DurationOption> kDurations = [
  DurationOption('hari', 'hari', 1),
  DurationOption('minggu', 'minggu', 7),
  DurationOption('bulan', 'bulan', 30),
];

int durationDays(String key) => kDurations
    .firstWhere((d) => d.key == key, orElse: () => kDurations.first)
    .days;

/// Alert "akan kadaluwarsa" mulai H-4 minggu dari tanggal kedaluwarsa batch.
/// (Nanti bisa dipindah ke Pengaturan Sistem milik Owner.)
const int kExpiryAlertWeeks = 4;
const int kExpiryAlertDays = kExpiryAlertWeeks * 7;

/// Tanggal kedaluwarsa bawaan = [from] + masa simpan.
DateTime addShelfLife(DateTime from, int value, String unit) {
  switch (unit) {
    case 'minggu':
      return from.add(Duration(days: value * 7));
    case 'bulan':
    // tambah bulan kalender; hari disesuaikan bila bulan tujuan lebih pendek
      final target = DateTime(from.year, from.month + value, 1);
      final lastDay = DateTime(target.year, target.month + 1, 0).day;
      return DateTime(
        target.year,
        target.month,
        from.day > lastDay ? lastDay : from.day,
      );
    default:
      return from.add(Duration(days: value));
  }
}

const _bulanId = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

/// 28 November 2026
String formatDateId(DateTime d) =>
    '${d.day} ${_bulanId[d.month - 1]} ${d.year}';

// =====================================================
// FOTO (Cloudinary)
// =====================================================
/// Minta Cloudinary mengecilkan foto lewat URL (hemat kuota dan lebih cepat).
/// Jika [height] diisi, foto dipotong kotak (c_fill); jika tidak, hanya
/// dibatasi lebarnya. URL non-Cloudinary dikembalikan apa adanya.
String cloudinaryResize(String url, {required int width, int? height}) {
  const marker = '/image/upload/';
  if (!url.contains('res.cloudinary.com') || !url.contains(marker)) return url;

  final transform = height != null
      ? 'c_fill,w_$width,h_$height,q_auto'
      : 'c_limit,w_$width,q_auto';
  return url.replaceFirst(marker, '$marker$transform/');
}