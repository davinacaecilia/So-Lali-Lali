import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import 'detail_stock.dart';
import 'kitchen_model.dart';

/// Scan QR Bahan.
/// CATATAN (backend): kamera/scan sungguhan butuh package (mis. mobile_scanner).
/// Untuk preview, TAP area kamera = simulasi "bahan terdeteksi".
class ScanQrPage extends StatefulWidget {
  final OpnameSesi sesi;
  const ScanQrPage({super.key, required this.sesi});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final _store = KitchenStore.instance;
  BahanStok? _terdeteksi;
  bool _flash = false;

  /// Simulasi hasil scan: ambil bahan pertama yang belum dihitung.
  void _simulasiScan() {
    final belum = _store.bahan.where((b) => !widget.sesi.entries.containsKey(b.id)).toList();
    setState(() => _terdeteksi = belum.isNotEmpty ? belum.first : _store.bahan.first);
  }

  Future<void> _berikutnya() async {
    final b = _terdeteksi!;
    final v = await showDetailStockSheet(
      context,
      bahan: b,
      awal: widget.sesi.entries[b.id]?.fisik,
    );
    if (v != null && mounted) {
      _store.simpanOpname(widget.sesi, b, v);
      Navigator.pop(context); // kembali ke daftar input opname
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _terdeteksi;
    return Scaffold(
      backgroundColor: KColors.navyDark,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.maybePop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Text('Scan QR Bahan',
                        textAlign: TextAlign.center,
                        style: ks(17, w: FontWeight.w700, c: Colors.white)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 24, 25, 24),
              child: GestureDetector(
                onTap: _simulasiScan,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3552),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 224,
                        height: 190,
                        child: Stack(
                          children: [
                            _corner(top: true, left: true),
                            _corner(top: true, left: false),
                            _corner(top: false, left: true),
                            _corner(top: false, left: false),
                            Center(
                              child: Container(width: 192, height: 2, color: KColors.amber),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text('Arahkan kamera ke barcode atau QR',
                          style: ks(13, w: FontWeight.w500, c: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Pastikan kode terlihat jelas dan tidak buram',
                          style: ks(13, c: const Color(0xFFF3DFC0))),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => setState(() => _flash = !_flash),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _flash ? KColors.amber : const Color(0xFF4A5468),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Panel bawah: hasil deteksi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 22, 25, 0),
            decoration: const BoxDecoration(
              color: KColors.creamCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bahan terdeteksi', style: ks(13, c: KColors.rustDark)),
                    const SizedBox(height: 4),
                    Text(b?.nama ?? 'Belum ada',
                        style: ks(20, w: FontWeight.w800, c: KColors.navy)),
                    const SizedBox(height: 2),
                    Text(
                      b == null
                          ? 'Mode preview: tap area kamera untuk simulasi scan'
                          : 'Stok sistem: ${fmtQty(b.total)} ${satuanPendek(b.satuan)} · ${b.kategori}',
                      style: ks(13, c: KColors.navy),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: Material(
                        color: b == null ? const Color(0xFFEFE9E1) : const Color(0xFFF8DFC4),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: b == null ? null : _berikutnya,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Berikutnya',
                                  style: ks(15,
                                      w: FontWeight.w700,
                                      c: b == null ? KColors.muted : KColors.rust)),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward,
                                  size: 18, color: b == null ? KColors.muted : KColors.rust),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({required bool top, required bool left}) {
    const sisi = BorderSide(color: KColors.amber, width: 5);
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top ? sisi : BorderSide.none,
            bottom: top ? BorderSide.none : sisi,
            left: left ? sisi : BorderSide.none,
            right: left ? BorderSide.none : sisi,
          ),
        ),
      ),
    );
  }
}
