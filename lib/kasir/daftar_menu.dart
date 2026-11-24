import 'package:flutter/material.dart';

import 'filter_menu.dart';
import 'informasi_menu.dart';
import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';

class DaftarMenuPage extends StatefulWidget {
  const DaftarMenuPage({super.key});

  @override
  State<DaftarMenuPage> createState() => _DaftarMenuPageState();
}

class _DaftarMenuPageState extends State<DaftarMenuPage> {
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
                  itemBuilder: (context, i) => MenuRow(
                    menu: menus[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InformasiMenuPage(menu: menus[i])),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
