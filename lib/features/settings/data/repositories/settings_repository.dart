import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsStreamProvider = StreamProvider<SettingsModel>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

class SettingsRepository {
  SettingsModel _settings = const SettingsModel(
    recipientEmail: 'quote@swissluxuryservices.ch',
    companyName: 'Swiss Luxury Services',
    supportEmail: 'info@swissluxuryservices.ch',
    supportPhone: '+41 44 123 45 67',
    currency: 'CHF',
    maintenanceMode: false,
  );

  final _streamController = StreamController<SettingsModel>.broadcast();

  SettingsRepository() {
    _streamController.add(_settings);
  }

  Stream<SettingsModel> watchSettings() {
    return Stream<SettingsModel>.multi((controller) {
      controller.add(_settings);
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  Future<SettingsModel> getSettings() async {
    return _settings;
  }

  Future<void> saveSettings(SettingsModel settings) async {
    _settings = settings;
    _streamController.add(_settings);
  }
}
