import 'package:flutter/widgets.dart';
import 'package:lastanswer/settings/views/become_pro_view/become_pro_base_view.dart';

class BecomeProView extends StatelessWidget {
  const BecomeProView({super.key});

  @override
  Widget build(final BuildContext context) => const BecomeProBaseView(
        children: [
          Text(
            'Unfortunately this platform is not supporting Pro upgrade. Please use website to upgrade.',
          ),
        ],
      );
}
