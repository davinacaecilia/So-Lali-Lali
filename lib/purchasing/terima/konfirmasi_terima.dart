import 'package:flutter/material.dart';

import '../partials/colors.dart';
import 'detail_nota.dart';
import 'terima_common.dart';
import 'terima_page.dart';

// ============================ KONFIRMASI PENERIMAAN ============================
class KonfirmasiTerimaPage extends StatefulWidget {
  final TerimaPo po;
  const KonfirmasiTerimaPage({super.key, required this.po});

  @override
  State<KonfirmasiTerimaPage> createState() => _KonfirmasiTerimaPageState();
}

class _KonfirmasiTerimaPageState extends State<KonfirmasiTerimaPage> {
  bool _hasPhoto = false;
  bool _susulan = false;

  bool _kurang(TerimaItem i) => (i.received ?? 0) < i.ordered;

  @override
  Widget build(BuildContext context) {
    final items = widget.po.items;
    final hasShortage = items.any(_kurang);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TerimaTopBar(title: 'Konfirmasi Penerimaan'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 18, 25, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text('Foto Nota', style: ts(12, FontWeight.w600, AppColors.brownDark))),
                    Text('*Wajib', style: ts(10, FontWeight.w500, AppColors.red)),
                  ]),
                  const SizedBox(height: 6),
                  InkWell(
                    // TODO FE: buka kamera / galeri (image_picker)
                    onTap: () => setState(() => _hasPhoto = !_hasPhoto),
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      decoration: cardDeco(color: _hasPhoto ? AppColors.cardWarnBg : Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                                color: AppColors.filterItemBg, borderRadius: BorderRadius.circular(8)),
                            child: Icon(_hasPhoto ? Icons.check : Icons.photo_camera_outlined,
                                color: AppColors.brown, size: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(_hasPhoto ? 'Foto nota terpilih' : 'Ambil foto atau pilih dari galeri',
                              style: ts(11, FontWeight.w600, AppColors.brownDark)),
                          Text('Maks. 5 MB', style: ts(10, FontWeight.w400, AppColors.subText)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  sectionTitle('Ringkasan Penerimaan'),
                  const SizedBox(height: 12),
                  for (final it in items) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: cardDeco(),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(it.name, style: ts(13, FontWeight.w600, AppColors.brownDark)),
                            Text('Exp. ${it.expiry == null ? '-' : fmtDate(it.expiry!)}',
                                style: ts(10, FontWeight.w400, AppColors.subText)),
                          ]),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${it.received ?? 0} / ${it.ordered} kg',
                              style: ts(12, FontWeight.w600, AppColors.brownDark)),
                          const SizedBox(height: 2),
                          _kurang(it)
                              ? const TBadge('Kurang', AppColors.ditolakBg, AppColors.ditolakText)
                              : const TBadge('Sesuai', AppColors.disetujuiBg, AppColors.disetujuiText),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const TWarnBox(
                      'Item yang belum dicek dianggap belum diterima, sehingga penerimaan dicatat sebagai sebagian.'),
                  if (hasShortage) ...[
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () => setState(() => _susulan = !_susulan),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(_susulan ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 20, color: _susulan ? AppColors.primary : AppColors.subText),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text('Sisa barang akan dikirim susulan, jadi PO tetap terbuka',
                                style: ts(11, FontWeight.w400, AppColors.brownDark))),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(25, 8, 25, MediaQuery.of(context).padding.bottom + 16),
            child: TButton(
              'Konfirmasi Penerimaan',
              // TODO FE: kirim ke API
              onTap: !_hasPhoto
                  ? null
                  : () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => KonfirmasiBerhasilPage(items: items))),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ BERHASIL ============================
class KonfirmasiBerhasilPage extends StatelessWidget {
  final List<TerimaItem> items;
  const KonfirmasiBerhasilPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 40, 25, 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                      width: 110, height: 110,
                      decoration: const BoxDecoration(color: AppColors.iconTile, shape: BoxShape.circle),
                      child: Center(
                        child: Container(
                          width: 80, height: 80,
                          decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: Colors.white, size: 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Penerimaan Berhasil\nDicatat',
                        textAlign: TextAlign.center,
                        style: ts(22, FontWeight.w600, AppColors.sectionTitle, h: 1.25)),
                    const SizedBox(height: 4),
                    Text('Stok Bahan sudah bertambah otomatis.',
                        style: ts(11, FontWeight.w400, AppColors.subText)),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: cardDeco(),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Stok yang Bertambah', style: ts(12, FontWeight.w600, AppColors.brownDark)),
                        const SizedBox(height: 8),
                        for (final it in items.where((e) => e.checked))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(it.name, style: ts(12, FontWeight.w500, AppColors.brownDark)),
                                  Text('Exp. ${it.expiry == null ? '-' : fmtDate(it.expiry!)}',
                                      style: ts(10, FontWeight.w400, AppColors.subText)),
                                ]),
                              ),
                              Text('+${it.received} kg',
                                  style: ts(12, FontWeight.w600, AppColors.disetujuiText)),
                            ]),
                          ),
                      ]),
                    ),
                  ]),
                ),
              ),
              TButton('Lihat Detail Penerimaan',
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const DetailNotaPage()))),
              const SizedBox(height: 10),
              TButton('Kembali ke Daftar Penerimaan',
                  outlined: true,
                  onTap: () => Navigator.pushAndRemoveUntil(
                      context, MaterialPageRoute(builder: (_) => const TerimaPage()), (r) => false)),
            ],
          ),
        ),
      ),
    );
  }
}