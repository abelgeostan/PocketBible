import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../data/repositories/bible_repository.dart';

class DailyBreadMessage {
  final String title;
  final String body;

  const DailyBreadMessage({required this.title, required this.body});
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BibleRepository _bibleRepository = BibleRepository();

  bool _initialized = false;
  String? _pendingPayload;
  void Function(String payload)? _onTapHandler;

  static const String morningChannelId = 'pocketbible_daily_verse';
  static const String morningChannelName = 'പ്രഭാത വചനം (Daily Verse)';
  static const String morningChannelDesc =
      'Daily morning Bible verse notification';

  static const String eveningChannelId = 'pocketbible_daily_bread';
  static const String eveningChannelName = 'സായാഹ്ന സന്ദേശം (Daily Bread)';
  static const String eveningChannelDesc =
      'Daily evening Bible reading reminder';

  // Rich collection of uplifting Daily Bread evening reminders
  static const List<DailyBreadMessage> dailyBreadMessages = [
    DailyBreadMessage(
      title: "🍞 Don't forget your Daily Bread",
      body: "Before this day ends, take a moment with God's Word. 📖",
    ),
    DailyBreadMessage(
      title: "🍞 Have you had your Daily Bread today?",
      body: "Before the day ends, spend a moment with God's Word. ✨",
    ),
    DailyBreadMessage(
      title: "🍞 ജീവന്റെ അപ്പം (Daily Bread)",
      body: "ഇന്നത്തെ ദിവസം അവസാനിക്കുന്നതിനു മുമ്പ് ദൈവവചനത്തിൽ അല്പം സമയം ചിലവഴിക്കൂ. 📖",
    ),
    DailyBreadMessage(
      title: "🌙 ദൈവവചനത്തോടെ ഒരു സന്ധ്യ",
      body: "സമാധാനത്തോടെ ഉറങ്ങാൻ തിരുവചനത്തിലെ വാഗ്ദത്തങ്ങൾ ധ്യാനിക്കൂ. 🕊️",
    ),
    DailyBreadMessage(
      title: "🕊️ Evening Peace with God's Word",
      body: "Rest your mind and heart in the Word before you sleep. 🌙",
    ),
    DailyBreadMessage(
      title: "📖 A Moment for Your Soul",
      body: "Take a quiet moment tonight with God's promises. 🙏",
    ),
    DailyBreadMessage(
      title: "✨ Time for Daily Bread",
      body: "Let God's Word be a lamp to your feet as the day closes. 🕯️",
    ),
    DailyBreadMessage(
      title: "🌙 Pause & Reflect",
      body: "A verse before bed brings peace to the night. Open PocketBible. 📖",
    ),
    DailyBreadMessage(
      title: "✝️ Man Shall Not Live by Bread Alone",
      body: "Nourish your soul with the Word of God this evening. 🍞",
    ),
    DailyBreadMessage(
      title: "🌿 Rest in His Presence",
      body: "Cast your cares on Him tonight. Read a chapter before sleep. 🤍",
    ),
    DailyBreadMessage(
      title: "⭐ Light for Your Evening",
      body: "Wrap up your day with comfort and wisdom from the Holy Scripture. 📖",
    ),
    DailyBreadMessage(
      title: "🙏 ഇന്നത്തെ ദിനം നന്ദിയോടെ",
      body: "ദൈവം തന്ന നന്മകൾക്ക് നന്ദി പറഞ്ഞ് ഒരു വാക്യം വായിക്കാം. ✝️",
    ),
    DailyBreadMessage(
      title: "🕯️ നിന്റെ വചനം എന്റെ കാലിന്നു ദീപം",
      body: "രാത്രിയുടെ ശാന്തതയിൽ വിശുദ്ധ വേദപുസ്തകം തുറക്കൂ. 📖",
    ),
    DailyBreadMessage(
      title: "🍞 Have you paused with the Word?",
      body: "A few minutes with Scripture can transform your evening. 🕊️",
    ),
    DailyBreadMessage(
      title: "🌟 End Your Day with Grace",
      body: "Let His peace guard your heart tonight. Spend a moment in the Word. 📖",
    ),
    DailyBreadMessage(
      title: "📖 ദൈവത്തിന്റെ വചനം ജീവനുള്ളത്",
      body: "ഉറങ്ങുന്നതിനു മുൻപ് തിരുവചനം ധ്യാനിക്കുന്നത് ഹൃദയത്തിന് ആശ്വാസം നൽകും. 🌸",
    ),
    DailyBreadMessage(
      title: "🕊️ Find Rest in Scripture",
      body: "He gives His beloved sleep. End your day with PocketBible. 🌙",
    ),
    DailyBreadMessage(
      title: "🍞 Daily Bread for the Soul",
      body: "Taste and see that the Lord is good. Read tonight's scripture. ✨",
    ),
  ];

  Future<void> initialize({void Function(String payload)? onNotificationTap}) async {
    if (_initialized) return;

    _onTapHandler = onNotificationTap;

    // 1. Initialize timezones
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (e) {
      debugPrint('NotificationService: Local timezone detection failed, using fallback: $e');
    }

    // 2. Android & iOS initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _handlePayload(payload);
        }
      },
    );

    // 3. Check if app was launched via notification click
    final launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchDetails?.notificationResponse?.payload != null) {
      _pendingPayload = launchDetails!.notificationResponse!.payload;
      if (_onTapHandler != null) {
        _onTapHandler!(_pendingPayload!);
      }
    }

    _initialized = true;
  }

  void _handlePayload(String payload) {
    _pendingPayload = payload;
    if (_onTapHandler != null) {
      _onTapHandler!(payload);
    }
  }

  String? consumePendingPayload() {
    final payload = _pendingPayload;
    _pendingPayload = null;
    return payload;
  }

  Future<bool> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedules the next 30 days of morning verses and evening reminders
  Future<void> scheduleNotifications({
    required bool morningEnabled,
    required int morningHour,
    required int morningMinute,
    required bool eveningEnabled,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Cancel existing scheduled slots (IDs 1000..1035 for morning, 2000..2035 for evening)
    for (int i = 0; i < 35; i++) {
      await _notificationsPlugin.cancel(1000 + i);
      await _notificationsPlugin.cancel(2000 + i);
    }

    final now = DateTime.now();
    final tzNow = tz.TZDateTime.now(tz.local);

    // 1. Schedule Morning Verses (Next 30 days)
    if (morningEnabled) {
      for (int i = 0; i < 30; i++) {
        final targetDay = now.add(Duration(days: i));
        final scheduledTz = tz.TZDateTime(
          tz.local,
          targetDay.year,
          targetDay.month,
          targetDay.day,
          morningHour,
          morningMinute,
        );

        // Skip if time has already passed for today
        if (scheduledTz.isBefore(tzNow)) {
          continue;
        }

        final dailyVerse = await _bibleRepository.getVerseForDate(targetDay);
        if (dailyVerse == null) continue;

        final title = '🌅 ഇന്നത്തെ വചനം • ${dailyVerse.reference}';
        final body = dailyVerse.text;
        final payload =
            'verse:${dailyVerse.bookCode}:${dailyVerse.chapter}:${dailyVerse.verse}';

        final androidDetails = AndroidNotificationDetails(
          morningChannelId,
          morningChannelName,
          channelDescription: morningChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'PocketBible • Daily Verse',
          ),
        );

        await _notificationsPlugin.zonedSchedule(
          1000 + i,
          title,
          body,
          scheduledTz,
          NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      }
    }

    // 2. Schedule Evening Daily Bread Reminders (Next 30 days)
    if (eveningEnabled) {
      for (int i = 0; i < 30; i++) {
        final targetDay = now.add(Duration(days: i));
        final scheduledTz = tz.TZDateTime(
          tz.local,
          targetDay.year,
          targetDay.month,
          targetDay.day,
          eveningHour,
          eveningMinute,
        );

        // Skip if time has already passed for today
        if (scheduledTz.isBefore(tzNow)) {
          continue;
        }

        // Varied Daily Bread message for each day
        final msgIndex = (targetDay.year * 365 +
                targetDay.month * 31 +
                targetDay.day) %
            dailyBreadMessages.length;
        final message = dailyBreadMessages[msgIndex];

        final androidDetails = AndroidNotificationDetails(
          eveningChannelId,
          eveningChannelName,
          channelDescription: eveningChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            message.body,
            contentTitle: message.title,
            summaryText: 'PocketBible • Daily Bread',
          ),
        );

        await _notificationsPlugin.zonedSchedule(
          2000 + i,
          message.title,
          message.body,
          scheduledTz,
          NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'daily_bread',
        );
      }
    }
  }

  /// Sends an immediate test notification so user can preview it
  Future<void> sendTestNotification({required bool isMorning}) async {
    if (!_initialized) {
      await initialize();
    }

    await requestPermissions();

    if (isMorning) {
      final verse = await _bibleRepository.getTodayVerse();
      final title = verse != null
          ? '🌅 ഇന്നത്തെ വചനം • ${verse.reference}'
          : '🌅 ഇന്നത്തെ വചനം (Daily Verse)';
      final body = verse?.text ??
          'യഹോവ എന്റെ ഇടയനാകുന്നു; എനിക്കു മുട്ടുണ്ടാകയില്ല. (സങ്കീർത്തനങ്ങൾ 23:1)';
      final payload = verse != null
          ? 'verse:${verse.bookCode}:${verse.chapter}:${verse.verse}'
          : 'verse:PSA:23:1';

      final androidDetails = AndroidNotificationDetails(
        morningChannelId,
        morningChannelName,
        channelDescription: morningChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'PocketBible • Daily Verse',
        ),
      );

      await _notificationsPlugin.show(
        999,
        title,
        body,
        NotificationDetails(android: androidDetails),
        payload: payload,
      );
    } else {
      final random = Random();
      final message =
          dailyBreadMessages[random.nextInt(dailyBreadMessages.length)];

      final androidDetails = AndroidNotificationDetails(
        eveningChannelId,
        eveningChannelName,
        channelDescription: eveningChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          message.body,
          contentTitle: message.title,
          summaryText: 'PocketBible • Daily Bread',
        ),
      );

      await _notificationsPlugin.show(
        998,
        message.title,
        message.body,
        NotificationDetails(android: androidDetails),
        payload: 'daily_bread',
      );
    }
  }
}
