import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/views/become_pro_view/become_pro_base_view.dart';

class BecomeProView extends StatelessWidget {
  const BecomeProView({super.key});

  @override
  Widget build(final BuildContext context) {
    final purhasesNotifier = context.watch<PurchasesNotifier>();
    return BecomeProBaseView(
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(''),
        ),
      ],
    );
  }
}
