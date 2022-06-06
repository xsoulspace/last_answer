part of hooks;

FormHelperState useFormHelper() => use(
      LifeHook(
        debugLabel: 'FormHelperState',
        state: FormHelperState(),
      ),
    );

class FormHelperState extends LifeState {
  FormHelperState();
  final formKey = GlobalKey<FormState>();
  final loading = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    loading.dispose();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  Future<void> submit({
    required final FutureVoidCallback onValide,
  }) async {
    try {
      if (validate()) {
        loading.value = true;
        setState();
        await onValide();
      }
    } finally {
      loading.value = false;
      setState();
    }
  }
}
