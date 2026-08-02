import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/config_keys.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/config_field.dart';
import '../application/settings_providers.dart';

class ConfigureEverythingScreen extends ConsumerStatefulWidget {
  const ConfigureEverythingScreen({super.key});

  @override
  ConsumerState<ConfigureEverythingScreen> createState() => _ConfigureEverythingScreenState();
}

class _ConfigureEverythingScreenState extends ConsumerState<ConfigureEverythingScreen> {
  final Map<String, TextEditingController> _controllers = {
    for (final key in ConfigKeys.all) key: TextEditingController(),
  };
  bool _loadedInitial = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(String key) async {
    await ref.read(configStoreProvider).setValue(key, _controllers[key]!.text.trim());
    ref.invalidate(configFieldsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(configFieldsProvider);
    final configureState = ref.watch(configureEverythingProvider);

    ref.listen(configureEverythingProvider, (prev, next) {
      if (next is ConfigureSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All set! The app is now live.'), backgroundColor: Colors.green),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Configure Everything')),
      body: fieldsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Could not load configuration')),
        data: (fields) {
          if (!_loadedInitial) {
            for (final key in ConfigKeys.all) {
              _controllers[key]!.text = fields[key]?.value ?? '';
            }
            _loadedInitial = true;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Fill in what you have. Website URL and REST API URL are required '
                'to go live - everything else can be added later without a rebuild.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final key in ConfigKeys.all) _ConfigFieldTile(
                configKey: key,
                controller: _controllers[key]!,
                field: fields[key],
                onSave: () => _save(key),
                errorText: _errorFor(configureState, key),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: configureState is ConfigureValidating
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.rocket_launch_outlined),
                label: Text(configureState is ConfigureValidating ? 'Validating...' : 'Configure Everything'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: configureState is ConfigureValidating
                    ? null
                    : () async {
                        for (final key in ConfigKeys.all) {
                          await _save(key);
                        }
                        await ref.read(configureEverythingProvider.notifier).run();
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  String? _errorFor(ConfigureState state, String key) {
    if (state is ConfigureFailed) {
      return state.errors[key];
    }
    return null;
  }
}

class _ConfigFieldTile extends StatelessWidget {
  const _ConfigFieldTile({
    required this.configKey,
    required this.controller,
    required this.field,
    required this.onSave,
    this.errorText,
  });
  final String configKey;
  final TextEditingController controller;
  final ConfigField? field;
  final VoidCallback onSave;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final status = field?.status ?? ConfigStatus.notConfigured;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ConfigKeys.labels[configKey] ?? configKey,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 4),
          Text(ConfigKeys.helpText[configKey] ?? '', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onSubmitted: (_) => onSave(),
            onEditingComplete: onSave,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ConfigStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ConfigStatus.notConfigured => ('Not Configured', Colors.grey),
      ConfigStatus.configured => ('Configured', Colors.green),
      ConfigStatus.testing => ('Testing...', Colors.orange),
      ConfigStatus.error => ('Error', Colors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
