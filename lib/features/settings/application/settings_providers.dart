import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/config_field.dart';

final configFieldsProvider = FutureProvider<Map<String, ConfigField>>((ref) {
  return ref.watch(configStoreProvider).getAll();
});

final isDemoModeProvider = FutureProvider<bool>((ref) {
  return ref.watch(configStoreProvider).isDemoMode;
});

class ConfigureEverythingController extends StateNotifier<ConfigureState> {
  ConfigureEverythingController(this._ref) : super(const ConfigureState.idle());
  final Ref _ref;

  Future<void> run() async {
    state = const ConfigureState.validating();
    final store = _ref.read(configStoreProvider);
    final fields = await store.getAll();

    final errors = <String, String>{};
    final website = fields['website_url']?.value ?? '';
    final restApi = fields['rest_api_url']?.value ?? '';

    if (website.isEmpty || !Uri.tryParse(website)!.isAbsolute) {
      errors['website_url'] = 'Enter a valid, complete URL (e.g. https://example.com)';
    }
    if (restApi.isEmpty || !Uri.tryParse(restApi)!.isAbsolute) {
      errors['rest_api_url'] = 'Enter a valid REST API URL';
    }
    // Other fields are optional for going live - WooCommerce, YouTube, etc.
    // are "future ready" per spec and don't block activation.

    await Future.delayed(const Duration(milliseconds: 600)); // simulate endpoint tests

    if (errors.isNotEmpty) {
      state = ConfigureState.failed(errors);
      return;
    }

    await store.setDemoMode(false);
    _ref.invalidate(isDemoModeProvider);
    state = const ConfigureState.success();
  }
}

sealed class ConfigureState {
  const ConfigureState();
  const factory ConfigureState.idle() = ConfigureIdle;
  const factory ConfigureState.validating() = ConfigureValidating;
  const factory ConfigureState.success() = ConfigureSuccess;
  const factory ConfigureState.failed(Map<String, String> errors) = ConfigureFailed;
}

class ConfigureIdle extends ConfigureState {
  const ConfigureIdle();
}

class ConfigureValidating extends ConfigureState {
  const ConfigureValidating();
}

class ConfigureSuccess extends ConfigureState {
  const ConfigureSuccess();
}

class ConfigureFailed extends ConfigureState {
  const ConfigureFailed(this.errors);
  final Map<String, String> errors;
}

final configureEverythingProvider =
    StateNotifierProvider<ConfigureEverythingController, ConfigureState>(
        (ref) => ConfigureEverythingController(ref));
