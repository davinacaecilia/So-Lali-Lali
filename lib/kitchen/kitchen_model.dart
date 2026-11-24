import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Helper format
// ---------------------------------------------------------------------------

const _bulanPanjang = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String _dua(int n) => n.toString().padLeft(2, '0');

/// 24 November 2026
String formatTanggalPanjang(DateTime d) =>
    '${d.day} ${_bulanPanjang[d.month - 1]} ${d.year}';

/// 24 November 2026, 20:00
String formatWaktuPanjang(DateTime d) =>
    '${formatTanggalPanjang(d)}, ${_dua(d.hour)}:${_dua(d.minute)}';

/// 13:59 WIB
String formatJamWib(DateTime d) => '${_dua(d.hour)}:${_dua(d.minute)} WIB';

/// 16 -> "16", 12.5 -> "12,5"
String fmtQty(double v) => v == v.roundToDouble()
    ? v.toInt().toString()
    : v.toString().replaceAll('.', ',');

double? parseQty(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

const _bulanPendek = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// 16 Nov
String formatTglBulan(DateTime d) => '${d.day} ${_bulanPendek[d.month - 1]}';

const namaBulan = _bulanPanjang;

/// liter -> L, lainnya tetap
String satuanPendek(String s) => s == 'liter' ? 'L' : s;

/// -2 + "kg" -> "-2kg" ; 2 + "liter" -> "+2L" ; 0 -> "0kg"
String fmtSelisih(double v, String satuan) {
  final tanda = v > 0 ? '+' : (v < 0 ? '-' : '');
  return '$tanda${fmtQty(v.abs())}${satuanPendek(satuan)}';
}

String _kodeRR(DateTime w, int seq) {
  final yy = _dua(w.year % 100);
  return 'RR-$yy${_dua(w.month)}${_dua(w.day)}-${seq.toString().padLeft(3, '0')}';
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

enum StokStatus { aman, menipis, habis }

extension StokStatusX on StokStatus {
  String get label => switch (this) {
        StokStatus.aman => 'Aman',
        StokStatus.menipis => 'Menipis',
        StokStatus.habis => 'Habis',
      };
}

enum RestockStatus { menunggu, diproses, selesai, ditolak }

extension RestockStatusX on RestockStatus {
  String get label => switch (this) {
        RestockStatus.menunggu => 'Menunggu',
        RestockStatus.diproses => 'Diproses',
        RestockStatus.selesai => 'Selesai',
        RestockStatus.ditolak => 'Ditolak',
      };
}

class Batch {
  final String nama;
  double stok;
  final DateTime baikSebelum;
  Batch(this.nama, this.stok, this.baikSebelum);

  int get sisaHari {
    final n = DateTime.now();
    final hariIni = DateTime(n.year, n.month, n.day);
    return baikSebelum.difference(hariIni).inDays;
  }

  bool get akanKadaluwarsa => sisaHari <= 7;
}

const kKategoriBahan = [
  'Bahan Kering',
  'Minuman & Biji Kopi',
  'Susu & Olahan',
  'Protein & Daging',
  'Bumbu & Rempah',
];

class BahanStok {
  final String id;
  final String nama;
  final String kategori;
  final String satuan;
  final String gambar; // file di assets/images/
  final IconData ikon;
  final double minimum;
  final int batasKadaluwarsaHari;
  final List<Batch> batches;

  BahanStok({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.satuan,
    required this.ikon,
    required this.minimum,
    required this.batasKadaluwarsaHari,
    required this.batches,
    this.gambar = 'kopi_susu.png',
  });

  double get total => batches.fold(0.0, (s, b) => s + b.stok);

  StokStatus get status {
    if (total <= 0) return StokStatus.habis;
    if (total <= minimum) return StokStatus.menipis;
    return StokStatus.aman;
  }

  /// Batch diurutkan dari kadaluwarsa terdekat.
  List<Batch> get batchTerurut =>
      [...batches]..sort((a, b) => a.baikSebelum.compareTo(b.baikSebelum));

  /// Sisa hari batch (yang masih ada stoknya) paling cepat kadaluwarsa.
  int? get sisaHariTerdekat {
    final aktif = batches.where((b) => b.stok > 0).map((b) => b.sisaHari);
    if (aktif.isEmpty) return null;
    return aktif.reduce((a, b) => a < b ? a : b);
  }
}

class WasteRecord {
  final BahanStok bahan;
  final String batch;
  final double jumlah;
  final String keterangan; // Rusak | Tumpah | Expired
  final DateTime waktu;
  WasteRecord({
    required this.bahan,
    required this.batch,
    required this.jumlah,
    required this.keterangan,
    required this.waktu,
  });
}

class RestockItem {
  final BahanStok bahan;
  final double jumlah;
  RestockItem(this.bahan, this.jumlah);
  String get teks => '${fmtQty(jumlah)} ${bahan.satuan}';
}

class RestockRequest {
  final String kode;
  final DateTime waktu;
  final String diajukanOleh;
  final RestockStatus status;
  final List<RestockItem> items;
  final DateTime dibutuhkanSebelum;
  final DateTime? tglVerifikasi;
  final DateTime? tglPurchasing;
  final DateTime? poDibuat;
  final String? alasanTolak;

  RestockRequest({
    required this.kode,
    required this.waktu,
    required this.items,
    required this.dibutuhkanSebelum,
    this.status = RestockStatus.menunggu,
    this.diajukanOleh = 'Kitchen Staff 1',
    this.tglVerifikasi,
    this.tglPurchasing,
    this.poDibuat,
    this.alasanTolak,
  });
}

/// Satu hasil hitung bahan pada sesi opname.
class OpnameEntry {
  final BahanStok bahan;
  final double sistem; // stok menurut sistem saat dihitung
  final double fisik; // jumlah hasil hitung fisik
  OpnameEntry(this.bahan, this.sistem, this.fisik);
  double get selisih => fisik - sistem;
}

enum OpnameStatus { berjalan, menunggu, disetujui }

/// Satu sesi opname (mingguan).
class OpnameSesi {
  final String id;
  final DateTime mulai;
  final DateTime akhir;
  OpnameStatus status;
  String? dicatatOleh;
  DateTime? dikirimPada;
  final Map<String, OpnameEntry> entries; // key = id bahan

  OpnameSesi({
    required this.id,
    required this.mulai,
    required this.akhir,
    this.status = OpnameStatus.berjalan,
    this.dicatatOleh,
    this.dikirimPada,
    Map<String, OpnameEntry>? entries,
  }) : entries = entries ?? {};

  int get terisi => entries.length;
  int get jumlahSesuai => entries.values.where((e) => e.selisih == 0).length;
  int get jumlahSelisih => entries.values.where((e) => e.selisih != 0).length;
  List<OpnameEntry> get kurang => entries.values.where((e) => e.selisih < 0).toList();
  List<OpnameEntry> get berlebih => entries.values.where((e) => e.selisih > 0).toList();
  String get periodeTeks => '${formatTglBulan(mulai)} - ${formatTglBulan(akhir)}';
}

enum AktivitasJenis { restock, waste, opname }

class Aktivitas {
  final AktivitasJenis jenis;
  final String judul;
  final String subjudul;
  final DateTime waktu;
  final String? status; // label pill (Diproses, Menunggu, ...)
  final String? nilai; // mis. "2 L"
  final Object? ref; // RestockRequest / WasteRecord untuk navigasi
  Aktivitas({
    required this.jenis,
    required this.judul,
    required this.subjudul,
    required this.waktu,
    this.status,
    this.nilai,
    this.ref,
  });
}

// ---------------------------------------------------------------------------
// Data dummy (ganti dengan data dari backend nanti)
// ---------------------------------------------------------------------------

DateTime _hariIni(int tambahHari) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day + tambahHari);
}

List<BahanStok> _seedBahan() => [
      BahanStok(
        id: 'BHN-001', nama: 'Tepung Terigu Protein Tinggi', kategori: 'Bahan Kering',
        satuan: 'kg', ikon: Icons.bakery_dining_outlined, minimum: 10, batasKadaluwarsaHari: 180,
        batches: [Batch('Batch 02', 4, _hariIni(1)), Batch('Batch 03', 12, _hariIni(50))],
      ),
      BahanStok(
        id: 'BHN-002', nama: 'Gula Pasir', kategori: 'Bahan Kering',
        satuan: 'kg', ikon: Icons.grain, minimum: 5, batasKadaluwarsaHari: 365,
        batches: [Batch('Batch 01', 12.5, _hariIni(120))],
      ),
      BahanStok(
        id: 'BHN-003', nama: 'Susu UHT Full Cream', kategori: 'Susu & Olahan',
        satuan: 'liter', ikon: Icons.local_drink_outlined, minimum: 10, batasKadaluwarsaHari: 90,
        batches: [Batch('Batch 01', 6, _hariIni(20))],
      ),
      BahanStok(
        id: 'BHN-004', nama: 'Biji Kopi Arabika', kategori: 'Minuman & Biji Kopi',
        satuan: 'kg', ikon: Icons.coffee_outlined, minimum: 3, batasKadaluwarsaHari: 180,
        batches: [Batch('Batch 01', 8, _hariIni(90))],
      ),
      BahanStok(
        id: 'BHN-005', nama: 'Mentega', kategori: 'Susu & Olahan',
        satuan: 'kg', ikon: Icons.layers_outlined, minimum: 3, batasKadaluwarsaHari: 120,
        batches: [Batch('Batch 01', 2, _hariIni(14))],
      ),
      BahanStok(
        id: 'BHN-006', nama: 'Fillet Ayam', kategori: 'Protein & Daging',
        satuan: 'kg', ikon: Icons.kebab_dining_outlined, minimum: 5, batasKadaluwarsaHari: 7,
        batches: [],
      ),
      BahanStok(
        id: 'BHN-007', nama: 'Telur Ayam', kategori: 'Protein & Daging',
        satuan: 'kg', ikon: Icons.egg_outlined, minimum: 5, batasKadaluwarsaHari: 21,
        batches: [Batch('Batch 01', 9, _hariIni(5))],
      ),
      BahanStok(
        id: 'BHN-008', nama: 'Bawang Putih', kategori: 'Bumbu & Rempah',
        satuan: 'kg', ikon: Icons.eco_outlined, minimum: 2, batasKadaluwarsaHari: 60,
        batches: [Batch('Batch 01', 4, _hariIni(30))],
      ),
      BahanStok(
        id: 'BHN-009', nama: 'Kecap Manis', kategori: 'Bumbu & Rempah',
        satuan: 'liter', ikon: Icons.water_drop_outlined, minimum: 2, batasKadaluwarsaHari: 365,
        batches: [Batch('Batch 01', 5, _hariIni(200))],
      ),
      BahanStok(
        id: 'BHN-010', nama: 'Matcha Bubuk', kategori: 'Minuman & Biji Kopi',
        satuan: 'kg', ikon: Icons.emoji_food_beverage_outlined, minimum: 1, batasKadaluwarsaHari: 240,
        batches: [Batch('Batch 01', 3, _hariIni(150))],
      ),
    ];

List<WasteRecord> _seedWaste(List<BahanStok> b) {
  DateTime at(int daysAgo, int h, int m) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day - daysAgo, h, m);
  }

  return [
    WasteRecord(bahan: b[2], batch: 'Batch 01', jumlah: 2, keterangan: 'Tumpah', waktu: at(0, 13, 59)),
    WasteRecord(bahan: b[0], batch: 'Batch 02', jumlah: 2, keterangan: 'Rusak', waktu: at(1, 19, 41)),
    WasteRecord(bahan: b[6], batch: 'Batch 01', jumlah: 1, keterangan: 'Expired', waktu: at(2, 8, 10)),
  ];
}

List<RestockRequest> _seedRequests(List<BahanStok> b) {
  DateTime at(int daysAgo, int h, int m) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day - daysAgo, h, m);
  }

  List<RestockItem> items() =>
      [RestockItem(b[3], 18), RestockItem(b[2], 10), RestockItem(b[1], 5)];

  final w1 = at(4, 19, 41), w2 = at(3, 19, 41), w3 = at(2, 19, 41), w4 = at(1, 19, 41);
  return [
    RestockRequest(
      kode: _kodeRR(w4, 4), waktu: w4, items: items(), dibutuhkanSebelum: _hariIni(3),
      status: RestockStatus.ditolak, tglVerifikasi: at(1, 20, 5), alasanTolak: 'Masih Banyak Stok',
    ),
    RestockRequest(
      kode: _kodeRR(w3, 3), waktu: w3, items: items(), dibutuhkanSebelum: _hariIni(4),
      status: RestockStatus.menunggu,
    ),
    RestockRequest(
      kode: _kodeRR(w2, 2), waktu: w2, items: items(), dibutuhkanSebelum: _hariIni(5),
      status: RestockStatus.diproses, tglVerifikasi: at(3, 21, 0), tglPurchasing: at(2, 9, 0),
    ),
    RestockRequest(
      kode: _kodeRR(w1, 1), waktu: w1, items: items(), dibutuhkanSebelum: _hariIni(2),
      status: RestockStatus.selesai, tglVerifikasi: at(4, 20, 30), tglPurchasing: at(3, 9, 0),
      poDibuat: at(3, 10, 0),
    ),
  ];
}

List<OpnameSesi> _seedOpname(List<BahanStok> bahan) {
  final n = DateTime.now();
  final senin = DateTime(n.year, n.month, n.day - (n.weekday - 1));
  DateTime hari(DateTime d, int tambah) => DateTime(d.year, d.month, d.day + tambah);

  // Selisih dummy per bahan (urut sama dengan _seedBahan).
  const off = [0.0, 0.0, -2.0, 2.0, 0.0, -1.0, 0.0, 1.0, 0.0, 0.0];

  OpnameSesi selesai(String id, int mingguLalu, OpnameStatus st, String oleh) {
    final mulai = hari(senin, -7 * mingguLalu);
    final sesi = OpnameSesi(
      id: id,
      mulai: mulai,
      akhir: hari(mulai, 6),
      status: st,
      dicatatOleh: oleh,
      dikirimPada: DateTime(hari(mulai, 6).year, hari(mulai, 6).month, hari(mulai, 6).day, 16, 0),
    );
    for (var i = 0; i < bahan.length; i++) {
      final sistem = bahan[i].total;
      final fisik = (sistem + off[i % off.length]).clamp(0, double.infinity).toDouble();
      sesi.entries[bahan[i].id] = OpnameEntry(bahan[i], sistem, fisik);
    }
    return sesi;
  }

  return [
    OpnameSesi(id: 'OPN-0', mulai: senin, akhir: hari(senin, 6)), // sedang berjalan
    selesai('OPN-1', 1, OpnameStatus.menunggu, 'Staff Kitchen'),
    selesai('OPN-2', 2, OpnameStatus.disetujui, 'Staff Purchasing'),
    selesai('OPN-3', 3, OpnameStatus.disetujui, 'Staff Kitchen'),
  ];
}

// ---------------------------------------------------------------------------
// State sederhana (tanpa package tambahan). Nanti bisa diganti API/Provider.
// ---------------------------------------------------------------------------

class KitchenStore extends ChangeNotifier {
  KitchenStore._();
  static final KitchenStore instance = KitchenStore._();

  /// 0 Beranda, 1 Menu, 2 Stok, 3 Waste, 4 Opname
  final ValueNotifier<int> tab = ValueNotifier<int>(0);

  late final List<BahanStok> bahan = _seedBahan();
  late final List<WasteRecord> waste = _seedWaste(bahan);
  late final List<RestockRequest> requests = _seedRequests(bahan);
  late final List<OpnameSesi> opname = _seedOpname(bahan);

  int countKategori(String? k) =>
      k == null ? bahan.length : bahan.where((b) => b.kategori == k).length;

  int get jumlahMenipis => bahan.where((b) => b.status != StokStatus.aman).length;

  int get jumlahHampirExpired => bahan
      .expand((b) => b.batches)
      .where((x) => x.stok > 0 && x.akanKadaluwarsa)
      .length;

  List<Aktivitas> get aktivitas {
    final list = <Aktivitas>[
      for (final r in requests)
        Aktivitas(
          jenis: AktivitasJenis.restock, judul: 'Request Restock', subjudul: r.kode,
          waktu: r.waktu, status: r.status.label, ref: r,
        ),
      for (final w in waste)
        Aktivitas(
          jenis: AktivitasJenis.waste, judul: 'Waste', subjudul: w.bahan.nama,
          waktu: w.waktu, nilai: '${fmtQty(w.jumlah)} ${w.bahan.satuan}', ref: w,
        ),
      for (final o in opname.where((o) => o.status != OpnameStatus.berjalan))
        Aktivitas(
          jenis: AktivitasJenis.opname,
          judul: 'Opname Mingguan',
          subjudul: o.periodeTeks,
          waktu: o.dikirimPada ?? o.akhir,
          status: o.status == OpnameStatus.menunggu ? 'Menunggu' : 'Disetujui',
          ref: o,
        ),
    ]..sort((a, b) => b.waktu.compareTo(a.waktu));
    return list;
  }

  RestockRequest addRequest(List<RestockItem> items, DateTime dibutuhkanSebelum) {
    final now = DateTime.now();
    final seq = requests
            .where((r) =>
                r.waktu.year == now.year && r.waktu.month == now.month && r.waktu.day == now.day)
            .length +
        1;
    final req = RestockRequest(
      kode: _kodeRR(now, seq),
      waktu: now,
      items: List.of(items),
      dibutuhkanSebelum: dibutuhkanSebelum,
    );
    requests.insert(0, req);
    notifyListeners();
    return req;
  }

  /// Catat waste dan kurangi stok batch yang dipilih.
  void addWaste({
    required BahanStok bahan,
    required Batch batch,
    required double jumlah,
    required String keterangan,
  }) {
    batch.stok = (batch.stok - jumlah).clamp(0, double.infinity).toDouble();
    waste.insert(
      0,
      WasteRecord(
        bahan: bahan, batch: batch.nama, jumlah: jumlah,
        keterangan: keterangan, waktu: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Simpan hasil hitung fisik satu bahan pada sesi opname.
  void simpanOpname(OpnameSesi sesi, BahanStok b, double fisik) {
    final lama = sesi.entries[b.id];
    sesi.entries[b.id] = OpnameEntry(b, lama?.sistem ?? b.total, fisik);
    notifyListeners();
  }

  /// Kirim hasil opname ke Owner (status jadi "menunggu").
  void kirimOpname(OpnameSesi sesi) {
    sesi.status = OpnameStatus.menunggu;
    sesi.dicatatOleh = 'Staff Kitchen';
    sesi.dikirimPada = DateTime.now();
    notifyListeners();
  }
}
