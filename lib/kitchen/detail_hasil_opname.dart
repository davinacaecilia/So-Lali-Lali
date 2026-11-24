import 'package:flutter/material.dart';

import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';
import 'review_hasil_opname.dart';

/// Detail hasil opname yang sudah dikirim.
/// Status "menunggu" menampilkan banner persetujuan Owner; "disetujui" tanpa banner.
class DetailHasilOpnamePage extends StatelessWidget {
  final OpnameSesi sesi;
  const DetailHasilOpnamePage({super.key, required this.sesi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Detail Hasil Opname'),
          Expanded(
            child: HasilOpnameView(
              sesi: sesi,
              banner: sesi.status == OpnameStatus.menunggu,
            ),
          ),
        ],
      ),
    );
  }
}
