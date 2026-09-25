import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsStreamProvider = StreamProvider<SettingsModel>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

class SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const SettingsModel defaultSettings = SettingsModel(
    recipientEmail: 'quote@swissluxuryservices.ch',
    companyName: 'Swiss Luxury Services',
    supportEmail: 'info@swissluxuryservices.ch',
    supportPhone: '+41 44 123 45 67',
    currency: 'CHF',
    maintenanceMode: false,
  );

  SettingsModel _settings = defaultSettings;
  final _streamController = StreamController<SettingsModel>.broadcast();
  bool _isSeeded = false;

  SettingsRepository() {
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('settings').doc('general').snapshots().listen(
        (snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            _settings = SettingsModel.fromMap(snapshot.data()!);
            _streamController.add(_settings);
          } else if (!_isSeeded) {
            _isSeeded = true;
            _seedDefaultSettings();
          }
        },
        onError: (e) {
          dev.log('Firestore settings listener error: $e', name: 'SettingsRepository');
          _streamController.add(_settings);
        },
      );
    } catch (e) {
      dev.log('Error initializing settings listener: $e', name: 'SettingsRepository');
      _streamController.add(_settings);
    }
  }

  Future<void> _seedDefaultSettings() async {
    try {
      final docRef = _firestore.collection('settings').doc('general');
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set(defaultSettings.toMap(), SetOptions(merge: true));
        dev.log('Default settings seeded to Firestore', name: 'SettingsRepository');
      }
    } catch (e) {
      dev.log('Error seeding default settings: $e', name: 'SettingsRepository');
    }
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
    try {
      final doc = await _firestore.collection('settings').doc('general').get();
      if (doc.exists && doc.data() != null) {
        _settings = SettingsModel.fromMap(doc.data()!);
        _streamController.add(_settings);
      }
    } catch (e) {
      dev.log('Error fetching settings from Firestore: $e', name: 'SettingsRepository');
    }
    return _settings;
  }

  Future<void> saveSettings(SettingsModel settings) async {
    _settings = settings;
    _streamController.add(_settings);

    try {
      await _firestore.collection('settings').doc('general').set(
            settings.toMap(),
            SetOptions(merge: true),
          );
      dev.log('Settings successfully saved to Firestore', name: 'SettingsRepository');
    } catch (e) {
      dev.log('Error saving settings to Firestore: $e', name: 'SettingsRepository');
      rethrow;
    }
  }
}

