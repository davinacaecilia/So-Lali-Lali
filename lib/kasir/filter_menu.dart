import 'package:flutter/material.dart';

import 'kasir_model.dart';
import 'kasir_theme.dart';

class MenuFilter {
  final String? kategori; // null = semua kategori
  final Set<bool> ketersediaan; // kosong = semua; true = tersedia; false = tidak
  const MenuFilter({this.kategori, this.ketersediaan = const {}});

  bool get aktif => kategori != null || ketersediaan.isNotEmpty;

  bool cocok(MenuProduk m) {
    if (kategori != null && m.kategori != kategori) return false;
    if (ketersediaan.isNotEmpty && !ketersediaan.contains(m.tersedia)) return false;
    return true;
  }
}

Future<MenuFilter?> showFilterMenuSheet(BuildContext context, MenuFilter current) {
  return showModalBottomSheet<MenuFilter>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  final MenuFilter initial;
  const _FilterSheet({required this.initial});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _kategori = widget.initial.kategori;
  late final Set<bool> _ket = {...widget.initial.ketersediaan};

  @override
  Widget build(BuildContext context) {
    final store = KasirStore.instance;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD6C4AF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(23, 20, 23, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter Menu', style: ks(20, w: FontWeight.w700)),
                      Text('Pilih kategori untuk menyaring daftar menu',
                          style: ks(12, c: KColors.inkSoft)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: KColors.peach,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.close, size: 20, color: KColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF4EBDB)),
          const SizedBox(height: 10),
          _kategoriTile(store, null, 'Semua Kategori'),
          for (final k in kKategori) _kategoriTile(store, k, k),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Ketersediaan', style: ks(14, w: FontWeight.w700, c: KColors.rustDark)),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Row(
              children: [
                _chip('Tersedia', true, KColors.greenBg, KColors.green),
                const SizedBox(width: 4),
                _chip('Tidak Tersedia', false, KColors.redBg, KColors.red),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _actionButton(
                    label: 'Reset',
                    icon: Icons.refresh,
                    bg: KColors.peach,
                    fg: KColors.navyLight,
                    onTap: () => setState(() {
                      _kategori = null;
                      _ket.clear();
                    }),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  flex: 5,
                  child: _actionButton(
                    label: 'Terapkan Filter',
                    icon: Icons.check,
                    bg: KColors.amber,
                    fg: Colors.white,
                    onTap: () => Navigator.pop(
                      context,
                      MenuFilter(kategori: _kategori, ketersediaan: {..._ket}),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _kategoriTile(KasirStore store, String? value, String label) {
    final selected = _kategori == value;
    return GestureDetector(
      onTap: () => setState(() => _kategori = value),
      child: Container(
        margin: const EdgeInsets.fromLTRB(23, 2, 23, 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE6D2) : KColors.creamField,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? KColors.amber : const Color(0xFFFADEC3),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: KColors.brownDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: ks(16, w: selected ? FontWeight.w700 : FontWeight.w400)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFADEC3) : KColors.peach,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${store.countKategori(value)} menu',
                  style: ks(11, w: FontWeight.w600, c: KColors.inkSoft)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool value, Color bg, Color fg) {
    final on = _ket.contains(value);
    return GestureDetector(
      onTap: () => setState(() => on ? _ket.remove(value) : _ket.add(value)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: on ? fg : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (on) ...[Icon(Icons.check, size: 14, color: fg), const SizedBox(width: 4)],
            Text(label, style: ks(12, w: FontWeight.w500, c: fg)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Text(label, style: ks(15, w: FontWeight.w600, c: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
