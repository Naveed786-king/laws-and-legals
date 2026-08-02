enum ConfigStatus { notConfigured, configured, testing, error }

class ConfigField {
  final String key;
  final String label;
  final String helpText;
  final String value;
  final ConfigStatus status;
  final String? errorMessage;

  const ConfigField({
    required this.key,
    required this.label,
    required this.helpText,
    this.value = '',
    this.status = ConfigStatus.notConfigured,
    this.errorMessage,
  });

  ConfigField copyWith({
    String? value,
    ConfigStatus? status,
    String? errorMessage,
  }) =>
      ConfigField(
        key: key,
        label: label,
        helpText: helpText,
        value: value ?? this.value,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );
}
