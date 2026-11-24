import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

class TambahWastePage extends StatefulWidget {
  const TambahWastePage({super.key});

  @override
  State<TambahWastePage> createState() => _TambahWastePageState();
}

class _TambahWastePageState extends State<TambahWastePage> {
  final _store = KitchenStore.instance;
  final _jumlah = TextEditingController();

  BahanStok? _bahan;
  Batch? _batch;
  String? _ket;
  bool _foto = false; // TODO(backend): ganti dengan file foto dari image_picker

  static const _opsiKeterangan = ['Rusak', 'Tumpah'];

  @override
  void dispose() {
    _jumlah.dispose();
    super.dispose();
  }

  double? get _angka {
    final v = parseQty(_jumlah.text);
    return (v == null || v <= 0) ? null : v;
  }

  bool get _melebihi =>
      _angka != null && _batch != null && _angka! > _batch!.stok;

  bool get _siap =>
      _bahan != null &&
      _batch != null &&
      _ket != null &&
      _angka != null &&
      !_melebihi &&
      _foto;

  Future<void> _pilihBahan() async {
    final b = await pilihDariList<BahanStok>(
      context,
      judul: 'Nama Bahan',
      items: _store.bahan,
      labelOf: (b) => b.nama,
      cari: true,
      hintCari: 'Cari nama bahan',
    );
    if (b != null) {
      setState(() {
        _bahan = b;
        _batch = null; // batch harus dipilih ulang
      });
    }
  }

  Future<void> _pilihBatch() async {
    if (_bahan == null) return;
    final b = await pilihDariList<Batch>(
      context,
      judul: 'Batch Persediaan',
      items: _bahan!.batches.where((x) => x.stok > 0).toList(),
      labelOf: (x) => '${x.nama} · ${fmtQty(x.stok)} ${_bahan!.satuan}',
      kosong: 'Bahan ini tidak punya stok',
    );
    if (b != null) setState(() => _batch = b);
  }

  Future<void> _pilihKeterangan() async {
    final k = await pilihDariList<String>(
      context,
      judul: 'Keterangan',
      items: _opsiKeterangan,
      labelOf: (s) => s,
    );
    if (k != null) setState(() => _ket = k);
  }

  void _simpan() {
    _store.addWaste(
      bahan: _bahan!,
      batch: _batch!,
      jumlah: _angka!,
      keterangan: _ket!,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Waste berhasil dicatat')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Tambah Waste Baru'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              children: [
                const FieldLabel('Nama Bahan'),
                KDropdownField(
                  text: _bahan?.nama ?? 'Pilih bahan',
                  isPlaceholder: _bahan == null,
                  onTap: _pilihBahan,
                ),
                const SizedBox(height: 14),
                const FieldLabel('Jumlah'),
                Row(
                  children: [
                    Expanded(
                      child: KNumberField(
                        controller: _jumlah,
                        error: _melebihi,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    KUnitBox(_bahan?.satuan ?? 'kg'),
                  ],
                ),
                if (_melebihi)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Melebihi stok batch (${fmtQty(_batch!.stok)} ${_bahan!.satuan})',
                      style: ks(11, c: KColors.red),
                    ),
                  ),
                const SizedBox(height: 14),
                const FieldLabel('Batch Persediaan'),
                KDropdownField(
                  text:
                      _batch?.nama ??
                      (_bahan == null ? 'Pilih bahan dulu' : 'Pilih batch'),
                  isPlaceholder: _batch == null,
                  onTap: _pilihBatch,
                ),
                const SizedBox(height: 14),
                const FieldLabel('Keterangan'),
                KDropdownField(
                  text: _ket ?? 'Pilih keterangan',
                  isPlaceholder: _ket == null,
                  onTap: _pilihKeterangan,
                ),
                const SizedBox(height: 14),
                const FieldLabel('Foto Bukti'),
                _fotoBox(),
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
                  label: 'Tambahkan Waste',
                  onPressed: _siap ? _simpan : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotoBox() {
    return GestureDetector(
      onTap: () =>
          setState(() => _foto = !_foto), // sementara: simulasi lampirkan foto
      child: Container(
        height: 154,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: KColors.brown, width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: KColors.peach,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _foto
                    ? Icons.check_circle_outline
                    : Icons.photo_camera_outlined,
                color: KColors.rust,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _foto
                  ? 'Foto terlampir (tap untuk hapus)'
                  : 'Ambil foto atau pilih dari galeri',
              style: ks(12, w: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text('Maks. 5 MB', style: ks(12, c: KColors.rust)),
          ],
        ),
      ),
    );
  }
}
