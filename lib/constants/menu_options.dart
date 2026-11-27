// =====================================================
// KATEGORI MENU
// =====================================================
class MenuCategoryOption {
  final String key; // disimpan di database, mis. "minuman_kopi"
  final String label; // ditampilkan di aplikasi
  final String prefix; // untuk kode menu, mis. MKP-001
  const MenuCategoryOption(this.key, this.label, this.prefix);
}

const List<MenuCategoryOption> kMenuCategories = [
  MenuCategoryOption('makanan_utama', 'Makanan Utama', 'MKU'),
  MenuCategoryOption('camilan_penutup', 'Camilan & Penutup', 'CMP'),
  MenuCategoryOption('roti_kue', 'Roti & Kue', 'RTK'),
  MenuCategoryOption('minuman_kopi', 'Minuman Kopi', 'MKP'),
  MenuCategoryOption('minuman_non_kopi', 'Minuman Non-Kopi', 'MNK'),
  MenuCategoryOption('lainnya', 'Lainnya', 'LNY'),
];

MenuCategoryOption menuCategoryByKey(String key) => kMenuCategories
    .firstWhere((c) => c.key == key, orElse: () => kMenuCategories.last);

/// Cari kategori dari label tampilannya (dipakai halaman yang masih
/// bekerja dengan label, mis. data dummy). Tidak ketemu -> "Lainnya".
MenuCategoryOption menuCategoryByLabel(String label) {
  final l = label.trim().toLowerCase();
  return kMenuCategories.firstWhere(
        (c) => c.label.toLowerCase() == l,
    orElse: () => kMenuCategories.last,
  );
}