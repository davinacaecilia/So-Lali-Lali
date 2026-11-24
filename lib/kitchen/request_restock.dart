import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'detail_request.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';
import 'pilih_bahan.dart';

class RequestRestockPage extends StatefulWidget {
  final BahanStok? bahanAwal;
  const RequestRestockPage({super.key, this.bahanAwal});

  @override
  State<RequestRestockPage> createState() => _RequestRestockPageState();
}

class _RequestRestockPageState extends State<RequestRestockPage> {
  DateTime? _tanggal;
  final List<RestockItem> _items = [];

  bool get _siap => _tanggal != null && _items.isNotEmpty;

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
    );
    if (res != null) setState(() => _tanggal = res);
  }

  @override
  void initState() {
    super.initState();
    final b = widget.bahanAwal;
    if (b != null) {
      // buka popup jumlah untuk bahan ini begitu halaman tampil
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tambahBahan(awal: b);
      });
    }
  }

  Future<void> _tambahBahan({BahanStok? awal}) async {
    // ← ubah
    final item = await showPilihBahanSheet(
      context,
      sudahDipilih: _items.map((e) => e.bahan.id).toSet(),
      bahanAwal: awal,
    );
    if (item != null) setState(() => _items.add(item));
  }

  void _ajukan() {
    final req = KitchenStore.instance.addRequest(_items, _tanggal!);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Request restock berhasil diajukan')),
      );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DetailRequestPage(request: req)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Request Restock'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              children: [
                const FieldLabel('Dibutuhkan Sebelum'),
                KDropdownField(
                  text: _tanggal == null
                      ? 'Pilih Tanggal'
                      : formatTanggalPanjang(_tanggal!),
                  isPlaceholder: _tanggal == null,
                  onTap: _pilihTanggal,
                ),
                const SizedBox(height: 18),
                const FieldLabel('Daftar Request Restock'),
                for (var i = 0; i < _items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: NamaQtyRow(
                            nama: _items[i].bahan.nama,
                            qty: _items[i].teks,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _items.removeAt(i)),
                          child: Container(
                            width: 60,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: KColors.brown,
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: KColors.rust,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Belum ada bahan. Tekan "Tambah Bahan".',
                      style: ks(12, c: KColors.muted),
                    ),
                  ),
                Material(
                  color: KColors.creamField,
                  elevation: 1,
                  shadowColor: const Color(0x33000000),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _tambahBahan,
                    child: SizedBox(
                      height: 52,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 22,
                            color: KColors.ink,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tambah Bahan',
                            style: ks(14, w: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 8, 25, 0),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: KButton(
                  label: 'Ajukan Request',
                  onPressed: _siap ? _ajukan : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
