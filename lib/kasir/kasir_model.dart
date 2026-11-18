import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Helper format
// ---------------------------------------------------------------------------

String rupiah(int v, {bool space = true}) {
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}Rp${space ? ' ' : ''}$buf';
}

const _bulan = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

String formatWaktu(DateTime d) {
  final jam = d.hour.toString().padLeft(2, '0');
  final mnt = d.minute.toString().padLeft(2, '0');
  return '${formatTanggal(d)}, $jam:$mnt';
}

bool isToday(DateTime d) {
  final n = DateTime.now();
  return d.year == n.year && d.month == n.month && d.day == n.day;
}

String _kode(DateTime w, int seq) {
  final yy = (w.year % 100).toString().padLeft(2, '0');
  final mm = w.month.toString().padLeft(2, '0');
  final dd = w.day.toString().padLeft(2, '0');
  return 'TRX-$yy$mm$dd-${seq.toString().padLeft(3, '0')}';
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class Bahan {
  final String nama;
  final String takaran;
  const Bahan(this.nama, this.takaran);
}

class MenuProduk {
  final String id;
  final String nama;
  final String kategori;
  final int harga;
  final bool tersedia;
  final String gambar; // nama file di assets/images/
  final List<Bahan> resep;

  const MenuProduk({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.tersedia,
    required this.gambar,
    required this.resep,
  });
}

class CartItem {
  final MenuProduk menu;
  int qty;
  CartItem(this.menu, this.qty);
  int get subtotal => menu.harga * qty;
}

class Transaksi {
  final String kode;
  final DateTime waktu;
  final String kasir;
  final String metodeBayar;
  final List<CartItem> items;

  Transaksi({
    required this.kode,
    required this.waktu,
    required this.items,
    this.kasir = 'Kasir 1',
    this.metodeBayar = 'Cash',
  });

  int get total => items.fold(0, (s, i) => s + i.subtotal);
  int get jumlahItem => items.fold(0, (s, i) => s + i.qty);
}

// ---------------------------------------------------------------------------
// Data dummy (ganti dengan data dari backend nanti)
// ---------------------------------------------------------------------------

const _resepKopi = [
  Bahan('Biji Kopi Arabika', '18 g'),
  Bahan('Susu Cair', '120 ml'),
  Bahan('Gula Aren Cair', '20 ml'),
  Bahan('Es Batu', '100 g'),
];
const _resepNonKopi = [
  Bahan('Bubuk Minuman', '25 g'),
  Bahan('Susu Cair', '150 ml'),
  Bahan('Gula Cair', '15 ml'),
];
const _resepMakanan = [
  Bahan('Nasi Putih', '200 g'),
  Bahan('Telur Ayam', '1 butir'),
  Bahan('Bawang Merah', '15 g'),
  Bahan('Kecap Manis', '10 ml'),
];
const _resepCamilan = [
  Bahan('Tepung Terigu', '80 g'),
  Bahan('Minyak Goreng', '50 ml'),
  Bahan('Gula Pasir', '10 g'),
];

const kKategori = [
  'Makanan Utama',
  'Minuman Kopi',
  'Minuman Non-Kopi',
  'Camilan & Penutup',
];

const _menus = <MenuProduk>[
  MenuProduk(
    id: 'MKN-NGS-001',
    nama: 'Nasi Goreng Spesial',
    kategori: 'Makanan Utama',
    harga: 28000,
    tersedia: true,
    gambar: 'nasi_goreng.png',
    resep: _resepMakanan,
  ),
  MenuProduk(
    id: 'MKN-MGJ-002',
    nama: 'Mie Goreng Jawa',
    kategori: 'Makanan Utama',
    harga: 26000,
    tersedia: true,
    gambar: 'nasi_goreng.png',
    resep: _resepMakanan,
  ),
  MenuProduk(
    id: 'MKN-AGP-003',
    nama: 'Ayam Geprek',
    kategori: 'Makanan Utama',
    harga: 30000,
    tersedia: true,
    gambar: 'nasi_goreng.png',
    resep: _resepMakanan,
  ),
  MenuProduk(
    id: 'MKN-NAB-004',
    nama: 'Nasi Ayam Bakar',
    kategori: 'Makanan Utama',
    harga: 32000,
    tersedia: false,
    gambar: 'nasi_goreng.png',
    resep: _resepMakanan,
  ),
  MenuProduk(
    id: 'MKN-STA-005',
    nama: 'Soto Ayam',
    kategori: 'Makanan Utama',
    harga: 27000,
    tersedia: false,
    gambar: 'nasi_goreng.png',
    resep: _resepMakanan,
  ),
  MenuProduk(
    id: 'KPI-KSA-001',
    nama: 'Kopi Susu Gula Aren',
    kategori: 'Minuman Kopi',
    harga: 22000,
    tersedia: true,
    gambar: 'kopi_susu.png',
    resep: _resepKopi,
  ),
  MenuProduk(
    id: 'KPI-LTE-002',
    nama: 'Kopi Latte',
    kategori: 'Minuman Kopi',
    harga: 25000,
    tersedia: true,
    gambar: 'kopi_susu.png',
    resep: _resepKopi,
  ),
  MenuProduk(
    id: 'KPI-AMR-003',
    nama: 'Americano',
    kategori: 'Minuman Kopi',
    harga: 18000,
    tersedia: true,
    gambar: 'kopi_susu.png',
    resep: _resepKopi,
  ),
  MenuProduk(
    id: 'KPI-CPC-004',
    nama: 'Cappuccino',
    kategori: 'Minuman Kopi',
    harga: 24000,
    tersedia: false,
    gambar: 'kopi_susu.png',
    resep: _resepKopi,
  ),
  MenuProduk(
    id: 'NKP-TTR-001',
    nama: 'Teh Tarik',
    kategori: 'Minuman Non-Kopi',
    harga: 15000,
    tersedia: true,
    gambar: 'kopi_susu.png',
    resep: _resepNonKopi,
  ),
  MenuProduk(
    id: 'NKP-MTL-002',
    nama: 'Matcha Latte',
    kategori: 'Minuman Non-Kopi',
    harga: 26000,
    tersedia: true,
    gambar: 'kopi_susu.png',
    resep: _resepNonKopi,
  ),
  MenuProduk(
    id: 'NKP-CKP-003',
    nama: 'Coklat Panas',
    kategori: 'Minuman Non-Kopi',
    harga: 20000,
    tersedia: false,
    gambar: 'kopi_susu.png',
    resep: _resepNonKopi,
  ),
  MenuProduk(
    id: 'CMP-RBC-001',
    nama: 'Roti Bakar Coklat',
    kategori: 'Camilan & Penutup',
    harga: 18000,
    tersedia: true,
    gambar: 'nasi_goreng.png',
    resep: _resepCamilan,
  ),
  MenuProduk(
    id: 'CMP-PSG-002',
    nama: 'Pisang Goreng',
    kategori: 'Camilan & Penutup',
    harga: 15000,
    tersedia: true,
    gambar: 'nasi_goreng.png',
    resep: _resepCamilan,
  ),
];

List<Transaksi> _seedRiwayat() {
  final now = DateTime.now();
  DateTime at(int daysAgo, int h, int m) =>
      DateTime(now.year, now.month, now.day - daysAgo, h, m);

  Transaksi t(
    int seq,
    DateTime w,
    List<List<int>> lines,)
    => Transaksi(
    kode: _kode(w, seq),
    waktu: w,
    items: lines.map((l) => CartItem(_menus[l[0]], l[1])).toList(),
  );

  // Terbaru di atas.
  return [
    t(5, at(0, 19, 41), [[0, 2],[5, 2],[6, 1],]),
    t(4, at(0, 18, 12), [[2, 1],[9, 1],]),
    t(3, at(0, 16, 30), [[5, 2],[12, 1],]),
    t(2, at(0, 14, 5), [[1, 2],[10, 2],]),
    t(1, at(0, 11, 48), [[6, 3],]),
    t(4, at(1, 20, 15), [[0, 1],[7, 1],]),
    t(3, at(1, 15, 2), [[13, 2], [9, 2]]),
  ];
}

// ---------------------------------------------------------------------------
// State sederhana (tanpa package tambahan). Nanti bisa diganti API/Provider.
// ---------------------------------------------------------------------------

class KasirStore extends ChangeNotifier {
  KasirStore._();
  static final KasirStore instance = KasirStore._();

  /// Tab aktif di bottom navigation: 0 Beranda, 1 Menu, 2 Riwayat.
  final ValueNotifier<int> tab = ValueNotifier<int>(0);

  final List<MenuProduk> menus = _menus;
  final List<CartItem> cart = [];
  final List<Transaksi> riwayat = _seedRiwayat();

  int get cartCount => cart.fold(0, (s, i) => s + i.qty);
  int get cartTotal => cart.fold(0, (s, i) => s + i.subtotal);

  int countKategori(String? k) =>
      k == null ? menus.length : menus.where((m) => m.kategori == k).length;

  void addToCart(MenuProduk m, int qty) {
    final i = cart.indexWhere((c) => c.menu.id == m.id);
    if (i >= 0) {
      cart[i].qty += qty;
    } else {
      cart.add(CartItem(m, qty));
    }
    notifyListeners();
  }

  void setQty(CartItem c, int qty) {
    c.qty = qty;
    notifyListeners();
  }

  void removeFromCart(CartItem c) {
    cart.remove(c);
    notifyListeners();
  }

  /// Simpan keranjang jadi transaksi, lalu kosongkan keranjang.
  Transaksi checkout(String metodeBayar) {
    final now = DateTime.now();
    final seq = riwayat.where((t) => isToday(t.waktu)).length + 1;
    final trx = Transaksi(
      kode: _kode(now, seq),
      waktu: now,
      metodeBayar: metodeBayar,
      items: cart.map((c) => CartItem(c.menu, c.qty)).toList(),
    );
    riwayat.insert(0, trx);
    cart.clear();
    notifyListeners();
    return trx;
  }
}
