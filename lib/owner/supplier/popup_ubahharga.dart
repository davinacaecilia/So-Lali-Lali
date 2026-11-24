import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';

/// Hasil dari popup Ubah Harga.
class UbahHargaResult {
  final int? harga; // null jika bahan dihapus
  final bool utama;
  final bool hapus;

  const UbahHargaResult({this.harga, required this.utama, this.hapus = false});
}

class UbahHargaSheet extends StatefulWidget {
  final String namaBahan;
  final String kategori;
  final String satuan;
  final int hargaAwal;
  final bool utama;
  final String namaSupplier;
  final String idSupplier;

  const UbahHargaSheet({
    super.key,
    required this.namaBahan,
    required this.kategori,
    required this.satuan,
    required this.hargaAwal,
    required this.utama,
    required this.namaSupplier,
    required this.idSupplier,
  });

  /// Tampilkan popup. Mengembalikan null jika ditutup tanpa menyimpan.
  static Future<UbahHargaResult?> show(
    BuildContext context, {
    required String namaBahan,
    required String kategori,
    required String satuan,
    required int hargaAwal,
    required bool utama,
    required String namaSupplier,
    required String idSupplier,
  }) {
    return showModalBottomSheet<UbahHargaResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UbahHargaSheet(
        namaBahan: namaBahan,
        kategori: kategori,
        satuan: satuan,
        hargaAwal: hargaAwal,
        utama: utama,
        namaSupplier: namaSupplier,
        idSupplier: idSupplier,
      ),
    );
  }

  @override
  State<UbahHargaSheet> createState() => _UbahHargaSheetState();
}

class _UbahHargaSheetState extends State<UbahHargaSheet> {
  late final TextEditingController _ctrl;
  late bool _utama;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _format(widget.hargaAwal.toString()));
    _utama = widget.utama;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static String _format(String digits) {
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  int get _harga =>
      int.tryParse(_ctrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  bool get _valid => _harga > 0;

  void _simpan() {
    if (!_valid) return;
    Navigator.pop(context, UbahHargaResult(harga: _harga, utama: _utama));
  }

  Future<void> _hapus() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus dari supplier?'),
        content: Text(
            '${widget.namaBahan} akan dihapus dari daftar bahan ${widget.namaSupplier}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (yakin == true && mounted) {
      Navigator.pop(
          context, UbahHargaResult(utama: _utama, hapus: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: kFont),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  const SizedBox(height: 14),
                  _buildTitle(),
                  const SizedBox(height: 18),
                  _buildInfoBahan(),
                  const SizedBox(height: 22),
                  _buildInputHarga(),
                  const SizedBox(height: 18),
                  _buildToggleUtama(),
                  const SizedBox(height: 14),
                  _buildInfoSupplier(),
                  const SizedBox(height: 14),
                  _buildTombolSimpan(),
                  const SizedBox(height: 6),
                  _buildTombolHapus(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() => Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.dragHandle,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );

  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ubah Harga',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              SizedBox(height: 2),
              Text('Penyesuaian biaya bahan baku supplier',
                  style: TextStyle(
                      fontSize: 12.5, color: AppColors.summarySubtitle)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close,
                size: 20, color: AppColors.brownDark),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBahan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardHighlight,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco_outlined,
                size: 22, color: AppColors.brown),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.namaBahan,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text('${widget.kategori} • ${widget.satuan}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.warmSubtitle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputHarga() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Harga per Satuan (Rp)',
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownDark)),
            Text('*Wajib',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.brown, width: 1.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Text('Rp',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brown)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_RibuanFormatter()],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownDark),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              Text('/ ${widget.satuan}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.mutedText)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleUtama() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.cardHighlight,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jadikan supplier utama',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                SizedBox(height: 3),
                Text('Pilihan otomatis saat membuat resep & PO',
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.summarySubtitle)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _utama,
            onChanged: (v) => setState(() => _utama = v),
            activeColor: Colors.white,
            activeTrackColor: AppColors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.sheetRadioOff,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSupplier() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lockedFieldBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_outlined,
              size: 16, color: AppColors.brownDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontSize: 12, color: AppColors.neutralText),
                children: [
                  const TextSpan(text: 'Supplier: '),
                  TextSpan(
                    text: widget.namaSupplier,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  TextSpan(text: ' (ID: ${widget.idSupplier})'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTombolSimpan() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _valid ? _simpan : null,
        icon: const Icon(Icons.check_circle_outline, size: 22),
        label: const Text('Simpan Perubahan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.orangeAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.navDivider,
          disabledForegroundColor: AppColors.mutedIcon,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildTombolHapus() {
    return Center(
      child: TextButton.icon(
        onPressed: _hapus,
        icon: const Icon(Icons.delete_outline,
            size: 20, color: AppColors.red),
        label: const Text('Hapus dari supplier',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.red)),
      ),
    );
  }
}

/// Format angka dengan titik ribuan, mis. 18000 -> 18.000
class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 9) digits = digits.substring(0, 9);
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}