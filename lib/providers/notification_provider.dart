import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _morningEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  bool _eveningEnabled = true;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 19, minute: 0);

  bool get morningEnabled => _morningEnabled;
  TimeOfDay get morningTime => _morningTime;
  bool get eveningEnabled => _eveningEnabled;
  TimeOfDay get eveningTime => _eveningTime;

  NotificationProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _morningEnabled =
        prefs.getBool(AppConstants.keyMorningNotificationEnabled) ?? true;
    final morningHour =
        prefs.getInt(AppConstants.keyMorningNotificationHour) ?? 7;
    final morningMinute =
        prefs.getInt(AppConstants.keyMorningNotificationMinute) ?? 0;
    _morningTime = TimeOfDay(hour: morningHour, minute: morningMinute);

    _eveningEnabled =
        prefs.getBool(AppConstants.keyEveningNotificationEnabled) ?? true;
    final eveningHour =
        prefs.getInt(AppConstants.keyEveningNotificationHour) ?? 19;
    final eveningMinute =
        prefs.getInt(AppConstants.keyEveningNotificationMinute) ?? 0;
    _eveningTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);

    notifyListeners();
    await _reschedule();
  }

  Future<void> _reschedule() async {
    await NotificationService.instance.scheduleNotifications(
      morningEnabled: _morningEnabled,
      morningHour: _morningTime.hour,
      morningMinute: _morningTime.minute,
      eveningEnabled: _eveningEnabled,
      eveningHour: _eveningTime.hour,
      eveningMinute: _eveningTime.minute,
    );
  }

  Future<void> setMorningEnabled(bool enabled) async {
    _morningEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyMorningNotificationEnabled, enabled);

    if (enabled) {
      await NotificationService.instance.requestPermissions();
    }
    await _reschedule();
  }

  Future<void> setMorningTime(TimeOfDay time) async {
    _morningTime = time;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyMorningNotificationHour, time.hour);
    await prefs.setInt(AppConstants.keyMorningNotificationMinute, time.minute);

    await _reschedule();
  }

  Future<void> setEveningEnabled(bool enabled) async {
    _eveningEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyEveningNotificationEnabled, enabled);

    if (enabled) {
      await NotificationService.instance.requestPermissions();
    }
    await _reschedule();
  }

  Future<void> setEveningTime(TimeOfDay time) async {
    _eveningTime = time;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyEveningNotificationHour, time.hour);
    await prefs.setInt(AppConstants.keyEveningNotificationMinute, time.minute);

    await _reschedule();
  }

  Future<void> sendTestNotification({required bool isMorning}) async {
    await NotificationService.instance.sendTestNotification(isMorning: isMorning);
  }
}
