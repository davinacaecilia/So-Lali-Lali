import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import 'detail_hasil_opname.dart';
import 'input_opname.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

/// Tab Opname: daftar sesi opname mingguan + filter tahun & bulan.
class OpnamePage extends StatefulWidget {
  const OpnamePage({super.key});

  @override
  State<OpnamePage> createState() => _OpnamePageState();
}

class _OpnamePageState extends State<OpnamePage> {
  late int _tahun = DateTime.now().year;
  late int _bulan = DateTime.now().month;

  Future<void> _pilihTahun() async {
    final now = DateTime.now();
    final res = await pilihDariList<int>(
      context,
      judul: 'Pilih Tahun',
      items: [for (var y = now.year; y >= now.year - 2; y--) y],
      labelOf: (y) => '$y',
    );
    if (res != null) setState(() => _tahun = res);
  }

  Future<void> _pilihBulan() async {
    final res = await pilihDariList<int>(
      context,
      judul: 'Pilih Bulan',
      items: [for (var m = 1; m <= 12; m++) m],
      labelOf: (m) => namaBulan[m - 1],
    );
    if (res != null) setState(() => _bulan = res);
  }

  @override
  Widget build(BuildContext context) {
    final store = KitchenStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final list =
            store.opname
                .where((s) => s.mulai.year == _tahun && s.mulai.month == _bulan)
                .toList()
              ..sort((a, b) => b.mulai.compareTo(a.mulai));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 23, 25, 14),
              child: Row(
                children: [
                  Expanded(
                    child: KDropdownField(
                      text: '$_tahun',
                      height: 48,
                      onTap: _pilihTahun,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KDropdownField(
                      text: namaBulan[_bulan - 1],
                      height: 48,
                      onTap: _pilihBulan,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada sesi opname di bulan ini',
                        style: ks(14, c: KColors.muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: list.length,
                      itemBuilder: (context, i) =>
                          _SesiCard(sesi: list[i], total: store.bahan.length),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SesiCard extends StatelessWidget {
  final OpnameSesi sesi;
  final int total;
  const _SesiCard({required this.sesi, required this.total});

  void _buka(BuildContext context) {
    final Widget page = sesi.status == OpnameStatus.berjalan
        ? InputOpnamePage(sesi: sesi)
        : DetailHasilOpnamePage(sesi: sesi);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final berjalan = sesi.status == OpnameStatus.berjalan;
    final menunggu = sesi.status == OpnameStatus.menunggu;
    final (bulatBg, bulatFg, bulatIcon) = menunggu
        ? (
            statusColors('Rusak').$1,
            statusColors('Rusak').$2,
            Icons.access_time_rounded,
          )
        : (const Color(0xFF1E8E4E), Colors.white, Icons.check);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: KColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _buka(context),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    berjalan
                        ? Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: KColors.iconBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.assignment_outlined,
                              color: KColors.brown,
                              size: 30,
                            ),
                          )
                        : SizedBox(
                            width: 62,
                            height: 62,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: bulatBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  bulatIcon,
                                  color: bulatFg,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opname Mingguan',
                            style: ks(16, w: FontWeight.w700),
                          ),
                          Text(
                            sesi.periodeTeks,
                            style: ks(12, c: KColors.inkSoft),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sesi.terisi}/$total Bahan',
                            style: ks(
                              12,
                              w: FontWeight.w700,
                              c: const Color(0xFF8A5A00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: KColors.muted,
                    ),
                  ],
                ),
              ),
              if (!berjalan && sesi.dicatatOleh != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6C8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: ks(11, c: const Color(0xFF8A5A00)),
                      children: [
                        const TextSpan(
                          text: 'Dicatat Oleh: ',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(text: sesi.dicatatOleh),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
