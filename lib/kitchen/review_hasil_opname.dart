import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';
import 'opname_terkirim.dart';

/// Review Hasil Opname + tombol Kirim (dengan dialog konfirmasi).
class ReviewHasilOpnamePage extends StatelessWidget {
  final OpnameSesi sesi;
  const ReviewHasilOpnamePage({super.key, required this.sesi});

  Future<void> _kirim(BuildContext context) async {
    final ya = await _showKirimDialog(context, sesi.periodeTeks);
    if (ya != true || !context.mounted) return;
    KitchenStore.instance.kirimOpname(sesi);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OpnameTerkirimPage(sesi: sesi)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Review Hasil Opname'),
          Expanded(child: HasilOpnameView(sesi: sesi)),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 8, 25, 0),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: KButton(label: 'Kirim Hasil Opname', onPressed: () => _kirim(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Isi halaman hasil opname (dipakai juga oleh Detail Hasil Opname)
// ---------------------------------------------------------------------------

class HasilOpnameView extends StatefulWidget {
  final OpnameSesi sesi;
  final bool banner; // tampilkan "menunggu persetujuan Owner"
  const HasilOpnameView({super.key, required this.sesi, this.banner = false});

  @override
  State<HasilOpnameView> createState() => _HasilOpnameViewState();
}

class _HasilOpnameViewState extends State<HasilOpnameView> {
  bool _kurang = true; // tab aktif: Kurang / Berlebih

  @override
  Widget build(BuildContext context) {
    final s = widget.sesi;
    final total = KitchenStore.instance.bahan.length;
    final list = _kurang ? s.kurang : s.berlebih;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Header sesi
        Container(
          color: KColors.creamCard,
          padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: KColors.iconBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.assignment_outlined, color: KColors.brown, size: 30),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Opname Mingguan', style: ks(16, w: FontWeight.w700)),
                  Text(s.periodeTeks, style: ks(12, c: KColors.inkSoft)),
                  Text('${s.terisi}/$total Bahan',
                      style: ks(12, w: FontWeight.w700, c: const Color(0xFF8A5A00))),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 18, 25, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.banner)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                          'Hasil Opname sedang menunggu persetujuan dari Owner',
                          style: ks(13, w: FontWeight.w500, c: const Color(0xFF835500), h: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Sesuai',
                      nilai: s.jumlahSesuai,
                      bg: KColors.greenBg,
                      fg: KColors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatBox(
                      label: 'Selisih',
                      nilai: s.jumlahSelisih,
                      bg: KColors.redBg,
                      fg: KColors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text('Detail Selisih', style: ks(20, w: FontWeight.w700, c: KColors.navy)),
              const SizedBox(height: 8),
              Container(height: 1, color: const Color(0xFFDDD6CC)),
              const SizedBox(height: 16),
              // Tab Kurang | Berlebih
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3E3FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _tab('Kurang', _kurang, () => setState(() => _kurang = true)),
                    _tab('Berlebih', !_kurang, () => setState(() => _kurang = false)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      _kurang ? 'Tidak ada bahan yang kurang' : 'Tidak ada bahan yang berlebih',
                      style: ks(13, c: KColors.muted),
                    ),
                  ),
                ),
              for (final e in list)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: KColors.divider)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.bahan.nama,
                            style: ks(14, w: FontWeight.w500, c: KColors.rust)),
                      ),
                      Text(
                        fmtSelisih(e.selisih, e.bahan.satuan),
                        style: ks(14,
                            w: FontWeight.w700,
                            c: e.selisih < 0 ? KColors.red : KColors.green),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tab(String label, bool aktif, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: aktif ? KColors.navyDark : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: ks(13,
                  w: FontWeight.w600, c: aktif ? Colors.white : KColors.inkSoft)),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int nilai;
  final Color bg;
  final Color fg;
  const _StatBox({required this.label, required this.nilai, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ks(13, w: FontWeight.w700, c: KColors.brownDark)),
          const SizedBox(height: 4),
          Text('$nilai', style: ks(28, w: FontWeight.w800, c: fg)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog konfirmasi kirim
// ---------------------------------------------------------------------------

Future<bool?> _showKirimDialog(BuildContext context, String periode) {
  return showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 66),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE3B0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.help_outline, color: Color(0xFFC9801A), size: 38),
            ),
            const SizedBox(height: 14),
            Text.rich(
              TextSpan(
                style: ks(16, w: FontWeight.w700, h: 1.4),
                children: [
                  const TextSpan(text: 'Kirim Hasil '),
                  TextSpan(
                    text: 'Opname Mingguan ($periode)',
                    style: const TextStyle(color: KColors.amber),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text('Tindakan ini tidak dapat\ndiulang kembali',
                textAlign: TextAlign.center,
                style: ks(13, c: KColors.grey, h: 1.4)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: KColors.brownDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Batal',
                          style: ks(14, w: FontWeight.w700, c: KColors.brownDark)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.amber,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Kirim', style: ks(14, w: FontWeight.w700, c: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
