/// Pilihan termin pembayaran (sesuai desain).
const List<String> kPaymentTerms = [
  'Tunai (COD)',
  '7 hari',
  '14 hari',
  '30 hari',
  '45 hari',
  '60 hari',
];

/// 18000 -> "Rp 18.000"
String formatRupiah(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

/// Inisial untuk avatar: lewati awalan badan usaha 2 huruf (CV, PT, UD, ...).
/// "CV Sumber Pangan Jaya" -> "SP"
String supplierInitials(String name) {
  final w = name.split(' ').where((e) => e.isNotEmpty).toList();
  if (w.isEmpty) return '?';
  final isi = (w.length > 1 && w.first.length <= 2) ? w.skip(1) : w;
  return isi.take(2).map((e) => e[0].toUpperCase()).join();
}

/// Awalan kode supplier (3 huruf) dari nama.
/// "CV Sumber Pangan Jaya" -> "SPJ", "UD Tani Makmur" -> "TMA"
String supplierPrefix(String name) {
  final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length > 1 && words.first.length <= 2) words.removeAt(0);

  final letters = words
      .map((w) => w.replaceAll(RegExp(r'[^A-Za-z]'), ''))
      .where((w) => w.isNotEmpty)
      .toList();

  var p = letters.take(3).map((w) => w[0]).join().toUpperCase();
  if (p.length < 3 && letters.isNotEmpty) {
    p = p + letters.first.substring(1).toUpperCase();
  }
  if (p.length > 3) p = p.substring(0, 3);
  return p.padRight(3, 'X');
}