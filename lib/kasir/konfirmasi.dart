import 'package:flutter/material.dart';

import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';
import 'transaksi_berhasil.dart';

/// Konfirmasi Transaksi (tombol baru aktif setelah metode pembayaran dipilih).
class KonfirmasiPage extends StatefulWidget {
  const KonfirmasiPage({super.key});

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage> {
  // Tambah / hapus metode di sini sesuai kebutuhan.
  static const _metode = ['Cash', 'QRIS', 'Transfer Bank'];

  final _store = KasirStore.instance;
  String? _dipilih;

  Future<void> _pilihMetode() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
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
              padding: const EdgeInsets.fromLTRB(25, 18, 25, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Metode Pembayaran', style: ks(18, w: FontWeight.w700)),
              ),
            ),
            for (final m in _metode)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                leading: const Icon(Icons.payments_rounded, color: KColors.amber),
                title: Text(m, style: ks(16, w: FontWeight.w600)),
                trailing: _dipilih == m
                    ? const Icon(Icons.check_circle, color: KColors.amber)
                    : null,
                onTap: () => Navigator.pop(context, m),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (res != null) setState(() => _dipilih = res);
  }

  void _konfirmasi() {
    final trx = _store.checkout(_dipilih!);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => TransaksiBerhasilPage(trx: trx)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Konfirmasi Transaksi'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(25, 19, 25, 24),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: KColors.peach,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFF835500), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Periksa kembali detail pesanan sebelum menyelesaikan transaksi.',
                          style: ks(13, w: FontWeight.w500, c: const Color(0xFF835500), h: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Detail Pesanan'),
                      const SizedBox(height: 8),
                      OrderLines(items: _store.cart),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TotalBar(jumlahItem: _store.cartCount, total: _store.cartTotal),
              ],
            ),
          ),
          // Metode pembayaran
          InkWell(
            onTap: _pilihMetode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
              decoration: const BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: KColors.divider)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_rounded, color: KColors.amber, size: 26),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Text(
                      _dipilih ?? 'Pilih Metode Pembayaran',
                      style: ks(15, w: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: KColors.muted),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 28, 25, 0),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: KButton(
                  label: 'Konfirmasi Transaksi',
                  onPressed: _dipilih == null ? null : _konfirmasi,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
