import 'package:flutter/material.dart';

import 'kasir_model.dart';
import 'kasir_theme.dart';

// ---------------------------------------------------------------------------
// Gambar dari assets/images/ (ada placeholder kalau file belum ditemukan)
// ---------------------------------------------------------------------------

class KImage extends StatelessWidget {
  static const logo = 'logo.png';
  static const profil = 'profil.png';

  final String name;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  const KImage(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/images/$name',
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: KColors.sand,
          child: const Icon(Icons.image_outlined, color: KColors.muted),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header & top bar
// ---------------------------------------------------------------------------

const _barShadow = [
  BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2)),
];

/// Header halaman utama (logo + "SO LALI LALI" + foto profil).
class KasirHeader extends StatelessWidget {
  const KasirHeader({super.key});

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
                      'Staff Kasir',
                      style: ks(
                        15,
                        w: FontWeight.w500,
                        c: const Color(0xFFA8794A),
                      ),
                    ),
                  ],
                ),
              ),
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

/// Top bar halaman dalam (tombol back + judul di tengah + aksi opsional).
class KasirTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool showBack;

  const KasirTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
    this.showBack = true,
  });

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
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 18),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: showBack
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onBack ?? () => Navigator.maybePop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: KColors.ink,
                          size: 24,
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: ks(17, w: FontWeight.w700),
                ),
              ),
              SizedBox(width: 32, child: trailing),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation
// ---------------------------------------------------------------------------

class KasirBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const KasirBottomNav({super.key, required this.index, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Beranda'),
    (Icons.rice_bowl_outlined, Icons.rice_bowl, 'Menu'),
    (Icons.history, Icons.history, 'Riwayat'),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: SizedBox(
                    width: 90,
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
                            i == index
                                ? _items[i].$2
                                : _items[i].$1, // fill kalau dipilih
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
// Komponen kecil
// ---------------------------------------------------------------------------

class KSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const KSearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: KColors.creamField.withAlpha(153),
        border: Border.all(color: KColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: KColors.inkSoft),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: ks(14),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: ks(14, c: KColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KFilterButton extends StatelessWidget {
  final VoidCallback onTap;
  const KFilterButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: KColors.creamField.withAlpha(153),
          border: Border.all(color: KColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.tune, size: 22, color: KColors.inkSoft),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final bool tersedia;
  const StatusPill({super.key, required this.tersedia});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 103),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: tersedia ? KColors.greenBg : KColors.redBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tersedia ? 'Tersedia' : 'Tidak Tersedia',
        textAlign: TextAlign.center,
        style: ks(
          12,
          w: FontWeight.w500,
          c: tersedia ? KColors.green : KColors.red,
        ),
      ),
    );
  }
}

/// Satu baris menu (dipakai di Daftar Menu & Pilih Menu).
class MenuRow extends StatelessWidget {
  final MenuProduk menu;
  final bool selected;
  final VoidCallback? onTap;
  const MenuRow({
    super.key,
    required this.menu,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dim = !menu.tersedia;
    final textColor = dim ? KColors.grey : KColors.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      child: Material(
        color: selected ? const Color(0xFFF1E6D8) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            child: Row(
              children: [
                Opacity(
                  opacity: dim ? 0.6 : 1,
                  child: KImage(menu.gambar, width: 64, height: 64, radius: 6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ks(16, w: FontWeight.w700, c: textColor, h: 1.3),
                      ),
                      Text(
                        menu.kategori,
                        style: ks(11, c: dim ? KColors.grey : KColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rupiah(menu.harga),
                      style: ks(16, w: FontWeight.w700, c: textColor),
                    ),
                    const SizedBox(height: 6),
                    StatusPill(tersedia: menu.tersedia),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const QtyButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: KColors.qtyBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size * 0.6, color: KColors.rust),
      ),
    );
  }
}

class QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final double size;
  const QtyStepper({
    super.key,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        QtyButton(icon: Icons.remove, onTap: onMinus, size: size),
        SizedBox(
          width: 34,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: ks(16, c: KColors.navyDark),
          ),
        ),
        QtyButton(icon: Icons.add, onTap: onPlus, size: size),
      ],
    );
  }
}

/// Judul section biru + garis bawah (mis. "Detail Menu", "Detail Pesanan").
class SectionTitle extends StatelessWidget {
  final String text;
  final double size;
  final Color lineColor;
  const SectionTitle(
    this.text, {
    super.key,
    this.size = 16,
    this.lineColor = const Color(0xFFF3DFC4),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: ks(size, w: FontWeight.w700, c: KColors.navy),
        ),
        const SizedBox(height: 10),
        Container(height: 2, color: lineColor),
      ],
    );
  }
}

/// Daftar baris pesanan: "Kopi Latte   2 × Rp25.000   Rp 50.000".
class OrderLines extends StatelessWidget {
  final List<CartItem> items;
  const OrderLines({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final i in items)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: KColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    i.menu.nama,
                    style: ks(14, w: FontWeight.w500, c: KColors.rust),
                  ),
                ),
                Text(
                  '${i.qty} × ${rupiah(i.menu.harga, space: false)}',
                  style: ks(14, c: KColors.grey),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    rupiah(i.subtotal),
                    textAlign: TextAlign.right,
                    style: ks(14, w: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class TotalBar extends StatelessWidget {
  final int jumlahItem;
  final int total;
  const TotalBar({super.key, required this.jumlahItem, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: KColors.creamCard,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
      child: Row(
        children: [
          Text('Total ($jumlahItem Item)', style: ks(13, w: FontWeight.w700)),
          const Spacer(),
          Text(
            rupiah(total),
            style: ks(26, w: FontWeight.w800, c: KColors.rust),
          ),
        ],
      ),
    );
  }
}

/// Tombol utama (amber) atau outline (navy).
class KButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  const KButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = outlined ? KColors.navyDark : Colors.white;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Material(
        color: outlined
            ? Colors.white
            : (enabled ? KColors.amber : KColors.amberDisabled),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: outlined
              ? const BorderSide(color: KColors.navyDark)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: ks(16, w: FontWeight.w700, c: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Popup hapus item keranjang. Mengembalikan true kalau user menekan "Hapus".
// ---------------------------------------------------------------------------

Future<bool> showHapusDialog(BuildContext context, String namaItem) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 68),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: KColors.dangerBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: KColors.danger,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text.rich(
              TextSpan(
                style: ks(18, w: FontWeight.w700, h: 1.4),
                children: [
                  const TextSpan(text: 'Hapus Item '),
                  TextSpan(
                    text: namaItem,
                    style: const TextStyle(color: KColors.amber),
                  ),
                  const TextSpan(text: ' dari Keranjang?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: KColors.brownDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: ks(14, w: FontWeight.w700, c: KColors.brownDark),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.danger,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Hapus',
                        style: ks(14, w: FontWeight.w700, c: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return res ?? false;
}
