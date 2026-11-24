import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';

const _barShadow = [
  BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2)),
];

// ---------------------------------------------------------------------------
// Header (ada tombol lonceng) & bottom nav 5 tab
// ---------------------------------------------------------------------------

class KitchenHeader extends StatelessWidget {
  const KitchenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KColors.cream,
        boxShadow: _barShadow,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 18, 25, 16),
          child: Row(
            children: [
              const KImage(
                KImage.logo,
                width: 58,
                height: 58,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SO LALI LALI',
                      style: ks(20, w: FontWeight.w800, c: KColors.brown),
                    ),
                    Text(
                      'Staff Kitchen',
                      style: ks(
                        15,
                        w: FontWeight.w500,
                        c: const Color(0xFFA8794A),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Belum ada notifikasi')),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: KColors.border),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: KColors.brown,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 4),
                  ],
                ),
                child: const ClipOval(
                  child: KImage(KImage.profil, width: 44, height: 44),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KitchenBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const KitchenBottomNav({super.key, required this.index, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Beranda'),
    (Icons.rice_bowl_outlined, Icons.rice_bowl, 'Menu'),
    (Icons.inventory_2_outlined, Icons.inventory_2, 'Stok'),
    (Icons.delete_outline, Icons.delete, 'Waste'),
    (Icons.assignment_outlined, Icons.assignment, 'Opname'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KColors.cream,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 47,
                          height: 47,
                          decoration: BoxDecoration(
                            color: i == index
                                ? KColors.divider
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            i == index ? _items[i].$2 : _items[i].$1,
                            color: KColors.brown,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_items[i].$3, style: ks(12, w: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pill status
// ---------------------------------------------------------------------------

/// Warna pill berdasarkan label status.
(Color, Color) statusColors(String s) {
  switch (s) {
    case 'Selesai':
    case 'Disetujui':
    case 'Aman':
      return (KColors.greenBg, KColors.green);
    case 'Diproses':
    case 'Rusak':
      return (const Color(0xFFD5E3FB), KColors.navyDark);
    case 'Menunggu':
    case 'Tumpah':
    case 'Menipis':
      return (const Color(0xFFFCE2B3), const Color(0xFFB8740A));
    default: // Ditolak, Expired, Habis
      return (KColors.redBg, KColors.red);
  }
}

class KPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final double? minWidth;
  final double size;

  const KPill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.minWidth,
    this.size = 11,
  });

  factory KPill.status(String label, {double? minWidth, double size = 11}) {
    final c = statusColors(label);
    return KPill(
      label: label,
      bg: c.$1,
      fg: c.$2,
      minWidth: minWidth,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth ?? 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: ks(size, w: FontWeight.w500, c: fg),
      ),
    );
  }
}

/// Badge stok: Aman / Menipis / Habis (dengan icon).
class StokBadge extends StatelessWidget {
  final StokStatus status;
  const StokBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      StokStatus.aman => (
        KColors.greenBg,
        KColors.green,
        Icons.check_circle_outline,
      ),
      StokStatus.menipis => (
        const Color(0xFFFFEFB5),
        const Color(0xFF8A5A00),
        Icons.warning_amber_rounded,
      ),
      StokStatus.habis => (KColors.redBg, KColors.red, Icons.cancel_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: ks(11, w: FontWeight.w600, c: fg),
          ),
        ],
      ),
    );
  }
}

Color stokColor(StokStatus s) => switch (s) {
  StokStatus.aman => KColors.ink,
  StokStatus.menipis => const Color(0xFF8A5A00),
  StokStatus.habis => KColors.red,
};

// ---------------------------------------------------------------------------
// Komponen form
// ---------------------------------------------------------------------------

/// Baris "Nama bahan | 18 g" (border cokelat, segmen kanan krem).
class NamaQtyRow extends StatelessWidget {
  final String nama;
  final String qty;
  final double height;
  const NamaQtyRow({
    super.key,
    required this.nama,
    required this.qty,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KColors.brown, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ks(15),
              ),
            ),
          ),
          Container(
            width: 84,
            height: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 18),
            decoration: const BoxDecoration(
              color: KColors.sand,
              border: Border(
                left: BorderSide(color: KColors.brown, width: 0.8),
              ),
            ),
            child: Text(
              qty,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ks(16, w: FontWeight.w700, c: KColors.brown),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label field: "Nama Bahan ............ *Wajib"
class FieldLabel extends StatelessWidget {
  final String text;
  final bool wajib;
  const FieldLabel(this.text, {super.key, this.wajib = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(text, style: ks(13, w: FontWeight.w700)),
          const Spacer(),
          if (wajib)
            Text(
              '*Wajib',
              style: ks(11, w: FontWeight.w500, c: KColors.red),
            ),
        ],
      ),
    );
  }
}

/// Field mirip dropdown (tap untuk memilih sesuatu).
class KDropdownField extends StatelessWidget {
  final String text;
  final bool isPlaceholder;
  final VoidCallback? onTap;
  final Widget? leading;
  final double height;

  const KDropdownField({
    super.key,
    required this.text,
    this.isPlaceholder = false,
    this.onTap,
    this.leading,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: KColors.brown, width: 0.8),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isPlaceholder
                    ? ks(13, c: KColors.brown)
                    : ks(14, w: FontWeight.w700, c: KColors.brown),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: KColors.rust,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kotak satuan terkunci: "kg 🔒".
class KUnitBox extends StatelessWidget {
  final String satuan;
  const KUnitBox(this.satuan, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 56,
      decoration: BoxDecoration(
        color: KColors.sand,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KColors.brown, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(satuan, style: ks(14, c: KColors.brown)),
          const SizedBox(width: 4),
          const Icon(Icons.lock_outline, size: 14, color: KColors.brown),
        ],
      ),
    );
  }
}

/// Input angka dengan border cokelat.
class KNumberField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool error;
  const KNumberField({
    super.key,
    required this.controller,
    this.onChanged,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: error ? KColors.red : KColors.brown,
          width: error ? 1.2 : 0.8,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: ks(15, w: FontWeight.w700),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: '0',
          hintStyle: ks(15, c: KColors.muted),
        ),
      ),
    );
  }
}

class KFab extends StatelessWidget {
  final VoidCallback onTap;
  const KFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KColors.amber,
      elevation: 4,
      shadowColor: const Color(0x55000000),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const SizedBox(
          width: 54,
          height: 54,
          child: Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

/// Kotak ikon bahan (dipakai di Stok, Waste, popup pilih bahan).
class BahanIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color bg;
  const BahanIcon(
    this.icon, {
    super.key,
    this.size = 62,
    this.bg = const Color(0xFFFFE6D2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: KColors.brown, size: size * 0.45),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet helpers
// ---------------------------------------------------------------------------

Future<T?> showKSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: builder,
  );
}

Widget sheetHandle() => Padding(
  padding: const EdgeInsets.only(top: 10),
  child: Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: const Color(0xFFD6C4AF),
      borderRadius: BorderRadius.circular(4),
    ),
  ),
);

class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

/// Pilih satu item dari list sederhana. Set [cari] = true untuk menampilkan kolom pencarian.
Future<T?> pilihDariList<T>(
  BuildContext context, {
  required String judul,
  required List<T> items,
  required String Function(T) labelOf,
  String? kosong,
  bool cari = false,
  String hintCari = 'Cari',
}) {
  return showKSheet<T>(
    context,
    (_) => _PilihList<T>(
      judul: judul,
      items: items,
      labelOf: labelOf,
      kosong: kosong,
      cari: cari,
      hintCari: hintCari,
    ),
  );
}

class _PilihList<T> extends StatefulWidget {
  final String judul;
  final List<T> items;
  final String Function(T) labelOf;
  final String? kosong;
  final bool cari;
  final String hintCari;
  const _PilihList({
    required this.judul,
    required this.items,
    required this.labelOf,
    required this.kosong,
    required this.cari,
    required this.hintCari,
  });

  @override
  State<_PilihList<T>> createState() => _PilihListState<T>();
}

class _PilihListState<T> extends State<_PilihList<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final tampil = widget.items
        .where(
          (it) =>
              widget.labelOf(it).toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 18, 23, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.judul,
                        style: ks(18, w: FontWeight.w700),
                      ),
                    ),
                    const SheetCloseButton(),
                  ],
                ),
              ),
              const Divider(height: 1, color: KColors.sand),
              if (widget.cari)
                Padding(
                  padding: const EdgeInsets.fromLTRB(23, 14, 23, 6),
                  child: KSearchField(
                    hint: widget.hintCari,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              if (tampil.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    widget.items.isEmpty
                        ? (widget.kosong ?? 'Tidak ada pilihan')
                        : 'Tidak ditemukan',
                    style: ks(14, c: KColors.muted),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final it in tampil)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25,
                          ),
                          title: Text(
                            widget.labelOf(it),
                            style: ks(15, w: FontWeight.w600),
                          ),
                          onTap: () => Navigator.pop(context, it),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kerangka sheet filter (dipakai Filter Bahan, Waste, Riwayat Restock)
// ---------------------------------------------------------------------------

class FilterSheetFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterSheetFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            sheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 20, 23, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: ks(20, w: FontWeight.w700)),
                        Text(subtitle, style: ks(12, c: KColors.inkSoft)),
                      ],
                    ),
                  ),
                  const SheetCloseButton(),
                ],
              ),
            ),
            const Divider(height: 1, color: KColors.sand),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 20, 23, 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _FilterAction(
                      label: 'Reset',
                      icon: Icons.refresh,
                      bg: KColors.peach,
                      fg: KColors.navyLight,
                      onTap: onReset,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    flex: 5,
                    child: _FilterAction(
                      label: 'Terapkan Filter',
                      icon: Icons.check,
                      bg: KColors.amber,
                      fg: Colors.white,
                      onTap: onApply,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  const _FilterAction({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(
                label,
                style: ks(15, w: FontWeight.w600, c: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterSectionLabel extends StatelessWidget {
  final String text;
  const FilterSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(23, 18, 23, 8),
      child: Text(
        text,
        style: ks(14, w: FontWeight.w700, c: KColors.rustDark),
      ),
    );
  }
}

class FilterRadioTile extends StatelessWidget {
  final String label;
  final String count;
  final bool selected;
  final VoidCallback onTap;
  const FilterRadioTile({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: Text(
                label,
                style: ks(16, w: selected ? FontWeight.w700 : FontWeight.w400),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFADEC3) : KColors.peach,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: ks(11, w: FontWeight.w600, c: KColors.inkSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip pilihan. [solid] = kalau terpilih jadi amber penuh (mis. "Semua").
class FilterChipOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;
  final bool solid;
  final Color? dot;

  const FilterChipOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.bg = KColors.creamField,
    this.fg = KColors.ink,
    this.solid = false,
    this.dot,
  });

  @override
  Widget build(BuildContext context) {
    final penuh = selected && solid;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: penuh ? KColors.amber : bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected && !solid ? fg : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: ks(12, w: FontWeight.w600, c: penuh ? Colors.white : fg),
            ),
          ],
        ),
      ),
    );
  }
}
