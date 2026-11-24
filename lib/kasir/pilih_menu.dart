import 'package:flutter/material.dart';

import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';
import 'keranjang.dart';

/// Tambah Transaksi → Pilih Menu.
class PilihMenuPage extends StatefulWidget {
  const PilihMenuPage({super.key});

  @override
  State<PilihMenuPage> createState() => _PilihMenuPageState();
}

class _PilihMenuPageState extends State<PilihMenuPage> {
  final _store = KasirStore.instance;
  String _query = '';
  String? _kategori; // null = Semua
  MenuProduk? _selected;
  int _qty = 1;

  void _openKeranjang() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const KeranjangPage()));
  }

  void _tambah() {
    final m = _selected!;
    _store.addToCart(m, _qty);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        content: Text('$_qty × ${m.nama} ditambahkan ke keranjang'),
      ));
    setState(() {
      _selected = null;
      _qty = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final menus = _store.menus
        .where((m) => _kategori == null || m.kategori == _kategori)
        .where((m) => m.nama.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _store,
            builder: (context, _) => KasirTopBar(
              title: 'Pilih Menu',
              trailing: GestureDetector(
                onTap: _openKeranjang,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 28, color: KColors.ink),
                    if (_store.cart.isNotEmpty)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: KColors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 23, 25, 12),
            child: KSearchField(
              hint: 'Cari nama menu',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              children: [
                _chip('Semua', null),
                for (final k in kKategori) _chip(k, k),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: menus.isEmpty
                ? Center(child: Text('Menu tidak ditemukan', style: ks(14, c: KColors.muted)))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: menus.length,
                    itemBuilder: (context, i) {
                      final m = menus[i];
                      return MenuRow(
                        menu: m,
                        selected: _selected?.id == m.id,
                        onTap: m.tersedia
                            ? () => setState(() {
                                  _selected = _selected?.id == m.id ? null : m;
                                  _qty = 1;
                                })
                            : null,
                      );
                    },
                  ),
          ),
          if (_selected != null) _bottomPanel(_selected!),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final on = _kategori == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _kategori = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? KColors.navyLight : KColors.creamField,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: ks(13, w: FontWeight.w600, c: on ? Colors.white : KColors.brown)),
        ),
      ),
    );
  }

  Widget _bottomPanel(MenuProduk m) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
          decoration: const BoxDecoration(
            color: KColors.creamField,
            border: Border(top: BorderSide(color: KColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.nama, style: ks(14, w: FontWeight.w700, c: KColors.rust)),
                    Text(rupiah(m.harga), style: ks(12, c: KColors.rust)),
                  ],
                ),
              ),
              QtyStepper(
                qty: _qty,
                size: 28,
                onMinus: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                onPlus: () => setState(() => _qty++),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: KButton(
                label: 'Tambahkan ke Keranjang',
                icon: Icons.shopping_cart_outlined,
                onPressed: _tambah,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
