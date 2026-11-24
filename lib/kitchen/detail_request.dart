import 'package:flutter/material.dart';

import '../kasir/kasir_model.dart'; // formatWaktu
import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

class DetailRequestPage extends StatelessWidget {
  final RestockRequest request;
  const DetailRequestPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Detail Request'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(25, 23, 25, 30),
              children: [
                Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: KColors.iconBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.assignment_outlined,
                          color: KColors.brown, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(r.kode,
                          style: ks(24, w: FontWeight.w800, c: KColors.brown)),
                    ),
                    KPill.status(r.status.label, size: 12),
                  ],
                ),
                const SizedBox(height: 8),
                _infoRow('Tanggal & Waktu', formatWaktu(r.waktu)),
                _infoRow('Diajukan Oleh', r.diajukanOleh),
                const SizedBox(height: 24),
                Text('Progress Request',
                    style: ks(18, w: FontWeight.w700, c: KColors.navy)),
                const SizedBox(height: 8),
                Container(height: 1, color: const Color(0xFFDDD6CC)),
                const SizedBox(height: 22),
                _Timeline(steps: _stepsFor(r)),
                if (r.status == RestockStatus.ditolak && r.alasanTolak != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: KColors.redBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error, size: 18, color: KColors.red),
                            const SizedBox(width: 8),
                            Text('Alasan Penolakan',
                                style: ks(14, w: FontWeight.w700, c: KColors.red)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(r.alasanTolak!, style: ks(12)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),
                Text('Daftar Produk', style: ks(18, w: FontWeight.w700, c: KColors.navy)),
                const SizedBox(height: 8),
                Container(height: 1, color: KColors.border),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: KColors.creamField,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text('Dibutuhkan Sebelum', style: ks(11, c: KColors.rust)),
                      const Spacer(),
                      Text(formatTanggalPanjang(r.dibutuhkanSebelum),
                          style: ks(13, w: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (final it in r.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: NamaQtyRow(nama: it.bahan.nama, qty: it.teks),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(label, style: ks(11, w: FontWeight.w700, c: KColors.rust)),
            const Spacer(),
            Text(value, style: ks(11, c: KColors.inkSoft)),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Timeline progress
// ---------------------------------------------------------------------------

class _Step {
  final String judul;
  final DateTime? waktu;
  final Color dot;
  final bool pudar;
  const _Step(this.judul, this.waktu, this.dot, {this.pudar = false});
}

const _cAmber = Color(0xFFF0B04F);
const _cAmberMuda = Color(0xFFF9E0AC);
const _cHijau = Color(0xFF2E7D32);
const _cBiruMuda = Color(0xFFD3E3FD);
const _cAbu = Color(0xFFE6E6EA);

List<_Step> _stepsFor(RestockRequest r) {
  final awal = _Step('Request Restock Diajukan', r.waktu, _cAmber);
  switch (r.status) {
    case RestockStatus.menunggu:
      return [
        awal,
        _Step('Menunggu Verifikasi Owner', r.waktu, _cAmberMuda),
        const _Step('Hasil Verifikasi', null, _cAbu, pudar: true),
      ];
    case RestockStatus.diproses:
      return [
        awal,
        _Step('Request Disetujui Owner', r.tglVerifikasi, _cAmberMuda),
        _Step('Request Sedang Diproses Purchasing', r.tglPurchasing, _cBiruMuda),
      ];
    case RestockStatus.selesai:
      return [
        awal,
        _Step('Request Disetujui Owner', r.tglVerifikasi, _cAmberMuda),
        _Step('PO Berhasil Dibuat Purchasing', r.poDibuat ?? r.tglPurchasing, _cHijau),
      ];
    case RestockStatus.ditolak:
      return [
        awal,
        _Step('Request Ditolak Owner', r.tglVerifikasi, KColors.red),
      ];
  }
}

class _Timeline extends StatelessWidget {
  final List<_Step> steps;
  const _Timeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) _item(i),
      ],
    );
  }

  Widget _item(int i) {
    final s = steps[i];
    final terakhir = i == steps.length - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: s.dot, shape: BoxShape.circle),
              ),
              if (!terakhir)
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [s.dot, steps[i + 1].dot],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 1, bottom: terakhir ? 6 : 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.judul,
                  style: ks(14, w: FontWeight.w700,
                      c: s.pudar ? const Color(0xFFC9C5C0) : Colors.black),
                ),
                if (s.waktu != null)
                  Text(formatWaktuPanjang(s.waktu!),
                      style: ks(12, c: const Color(0xFFD98E1B))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
