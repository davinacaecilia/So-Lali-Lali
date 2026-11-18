import 'package:flutter/material.dart';

import 'konfirmasi.dart';
import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';

/// Keranjang Pesanan. Geser item ke kiri untuk menghapus.
class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = KasirStore.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final cart = store.cart;
          return Column(
            children: [
              const KasirTopBar(title: 'Keranjang Pesanan'),
              Expanded(
                child: cart.isEmpty
                    ? Center(
                        child: Text('Keranjang masih kosong',
                            style: ks(14, c: KColors.muted)),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: cart.length,
                        itemBuilder: (context, i) => _CartRow(item: cart[i]),
                      ),
              ),
              TotalBar(jumlahItem: store.cartCount, total: store.cartTotal),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(23, 18, 23, 0),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        KButton(
                          label: 'Checkout Pesanan',
                          onPressed: cart.isEmpty
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const KonfirmasiPage()),
                                  ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.add, size: 18, color: KColors.navyDark),
                          label: Text('Tambah Menu',
                              style: ks(13, w: FontWeight.w700, c: KColors.navyDark)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  const _CartRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final store = KasirStore.instance;
    final menu = item.menu;

    Future<void> hapus() async {
      if (await showHapusDialog(context, menu.nama)) {
        store.removeFromCart(item);
      }
    }

    return Dismissible(
      key: ObjectKey(item),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showHapusDialog(context, menu.nama),
      onDismissed: (_) => store.removeFromCart(item),
      background: Container(
        color: KColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            const SizedBox(height: 2),
            Text('Hapus', style: ks(14, w: FontWeight.w700, c: Colors.white)),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 18, 25, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: const Color(0xFFDDC29C).withAlpha(128))),
        ),
        child: Row(
          children: [
            KImage(menu.gambar, width: 64, height: 64, radius: 4),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ks(15, w: FontWeight.w700, h: 1.3)),
                  Text(rupiah(menu.harga), style: ks(11, c: KColors.inkSoft)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(rupiah(item.subtotal), style: ks(15, w: FontWeight.w700)),
                const SizedBox(height: 4),
                QtyStepper(
                  qty: item.qty,
                  size: 26,
                  onMinus: () {
                    if (item.qty > 1) {
                      store.setQty(item, item.qty - 1);
                    } else {
                      hapus();
                    }
                  },
                  onPlus: () => store.setQty(item, item.qty + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
