import 'package:flutter/material.dart';

import '../kasir/filter_menu.dart'; // MenuFilter + sheet filter menu (sama dengan Kasir)
import '../kasir/kasir_model.dart'; // MenuProduk + KasirStore (data menu)
import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'informasi_menu.dart';

class DaftarMenuKitchenPage extends StatefulWidget {
  const DaftarMenuKitchenPage({super.key});

  @override
  State<DaftarMenuKitchenPage> createState() => _DaftarMenuKitchenPageState();
}

class _DaftarMenuKitchenPageState extends State<DaftarMenuKitchenPage> {
  String _query = '';
  MenuFilter _filter = const MenuFilter();

  @override
  Widget build(BuildContext context) {
    final menus = KasirStore.instance.menus
        .where((m) => _filter.cocok(m))
        .where((m) => m.nama.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 23, 25, 10),
          child: Row(
            children: [
              Expanded(
                child: KSearchField(
                  hint: 'Cari nama menu',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 9),
              KFilterButton(onTap: () async {
                final res = await showFilterMenuSheet(context, _filter);
                if (res != null) setState(() => _filter = res);
              }),
            ],
          ),
        ),
        Expanded(
          child: menus.isEmpty
              ? Center(child: Text('Menu tidak ditemukan', style: ks(14, c: KColors.muted)))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: menus.length,
                  itemBuilder: (context, i) => _MenuRow(
                    menu: menus[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => InformasiMenuKitchenPage(menu: menus[i])),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final MenuProduk menu;
  final VoidCallback onTap;
  const _MenuRow({required this.menu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dim = !menu.tersedia;
    final textColor = dim ? KColors.grey : KColors.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
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
                    Text(menu.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ks(16, w: FontWeight.w700, c: textColor, h: 1.3)),
                    Text(menu.kategori,
                        style: ks(11, c: dim ? KColors.grey : KColors.inkSoft)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${menu.resep.length} bahan',
                      style: ks(16, w: FontWeight.w700, c: textColor)),
                  const SizedBox(height: 6),
                  StatusPill(tersedia: menu.tersedia),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
