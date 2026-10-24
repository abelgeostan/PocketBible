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

// Curated collection of 30 uplifting Daily Bread evening reminders
  static const List<DailyBreadMessage> dailyBreadMessages = [
    DailyBreadMessage(
      title: "📖 വചനത്തിനായി ഒരു നിമിഷം",
      body: "ഇന്നത്തെ തിരക്കുകൾക്കിടയിൽ ദൈവവചനം വായിക്കാൻ അല്പസമയം മാറ്റിവെക്കൂ.",
    ),
    DailyBreadMessage(
      title: "📖 A Moment in the Word",
      body: "Set aside a few quiet minutes to read Scripture before the day ends.",
    ),
    DailyBreadMessage(
      title: "📚 വായന തുടരാം",
      body: "നിങ്ങൾ അവസാനിപ്പിച്ച അധ്യായത്തിൽ നിന്ന് വീണ്ടും വായന തുടങ്ങാം. PocketBible തുറക്കൂ.",
    ),
    DailyBreadMessage(
      title: "📚 Continue Your Reading",
      body: "Pick up where you left off and continue your Bible reading in PocketBible.",
    ),
    DailyBreadMessage(
      title: "🙏 നന്ദിയോടെ ദിനം അവസാനിപ്പിക്കാം",
      body: "ഇന്ന് ലഭിച്ച നന്മകൾ ഓർത്തു ദൈവത്തോട് നന്ദി പറയാൻ ഒരു നിമിഷം മാറ്റിവെക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🙏 End the Day with Gratitude",
      body: "Take a moment to thank God for the good you experienced today.",
    ),
    DailyBreadMessage(
      title: "🕊️ പ്രാർത്ഥനയ്ക്കൊരു നിമിഷം",
      body: "നിങ്ങളുടെ ചിന്തകളും ആവശ്യങ്ങളും ദൈവസന്നിധിയിൽ സമർപ്പിച്ച് ശാന്തമായി പ്രാർത്ഥിക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🕊️ Take a Moment to Pray",
      body: "Bring your thoughts and needs before God in a quiet moment of prayer.",
    ),
    DailyBreadMessage(
      title: "🌙 ഉറങ്ങുന്നതിനു മുമ്പ്",
      body: "രാത്രി വിശ്രമിക്കുന്നതിന് മുമ്പ് ഒരു അധ്യായം വായിച്ച് ദൈവവചനം ധ്യാനിക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🌙 Before You Rest",
      body: "Read a chapter and reflect on God's Word before settling down for the night.",
    ),
    DailyBreadMessage(
      title: "🕊️ ദൈവസമാധാനത്തിൽ വിശ്രമിക്കൂ",
      body: "ദിവസാവസാനത്തിൽ ഒരു നിമിഷം നിശ്ശബ്ദമായി ഇരുന്ന് ദൈവത്തിന്റെ സമാധാനം ധ്യാനിക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🕊️ Rest in God's Peace",
      body: "Pause for a quiet moment and reflect on God's peace as the day comes to a close.",
    ),
    DailyBreadMessage(
      title: "✨ നിമിഷം നിർത്തി ചിന്തിക്കൂ",
      body: "ഇന്നത്തെ അനുഭവങ്ങൾ ഓർത്തു ദൈവവചനത്തിന്റെ വെളിച്ചത്തിൽ ഹൃദയം പരിശോധിക്കൂ.",
    ),
    DailyBreadMessage(
      title: "✨ Pause and Reflect",
      body: "Look back on your day and reflect with a heart guided by Scripture.",
    ),
    DailyBreadMessage(
      title: "🌅 നാളേക്കുള്ള പ്രത്യാശ",
      body: "ഇന്നത്തെ ദിവസം എങ്ങനെയായിരുന്നാലും ദൈവത്തിൽ പ്രത്യാശയോടെ നാളെയെ വരവേൽക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🌅 Hope for Tomorrow",
      body: "Whatever today brought, look toward tomorrow with hope in God.",
    ),
    DailyBreadMessage(
      title: "🤍 അവന്റെ കരുതലിൽ വിശ്രമിക്കൂ",
      body: "നിങ്ങളുടെ ചിന്താകുലങ്ങൾ ദൈവത്തിന്റെ കരങ്ങളിൽ ഏൽപ്പിച്ച് സമാധാനത്തോടെ വിശ്രമിക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🤍 Rest in His Care",
      body: "Place your worries in God's hands and give yourself a quiet moment to rest.",
    ),
    DailyBreadMessage(
      title: "💪 ഇന്നത്തേക്കുള്ള ശക്തി",
      body: "ക്ഷീണിതരാകുമ്പോൾ ദൈവത്തിൽ നിന്ന് ശക്തിയും ധൈര്യവും തേടൂ.",
    ),
    DailyBreadMessage(
      title: "💪 Strength for Today",
      body: "When you feel weary, turn to God for renewed strength and courage.",
    ),
    DailyBreadMessage(
      title: "🌿 നന്ദിയുള്ള ഹൃദയം",
      body: "ചെറിയ അനുഗ്രഹങ്ങൾ പോലും ഓർത്തു നന്ദിയുള്ള ഹൃദയത്തോടെ ഈ ദിവസം അവസാനിപ്പിക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🌿 A Grateful Heart",
      body: "Notice even the small blessings and end your day with a grateful heart.",
    ),
    DailyBreadMessage(
      title: "📜 വാഗ്ദത്തങ്ങളിൽ ആശ്രയിക്കൂ",
      body: "ദൈവത്തിന്റെ വാഗ്ദത്തങ്ങൾ ഓർത്തു വിശ്വാസത്തോടെ മുന്നോട്ട് പോകൂ.",
    ),
    DailyBreadMessage(
      title: "📜 Trust His Promises",
      body: "Remember God's promises and take your next step in faith.",
    ),
    DailyBreadMessage(
      title: "🕯️ നിങ്ങളുടെ വഴിക്ക് വെളിച്ചം",
      body: "നിങ്ങളുടെ തീരുമാനങ്ങൾക്കും നാളെയുടെ വഴികൾക്കും ദൈവവചനത്തിൽ മാർഗ്ഗദർശനം തേടൂ.",
    ),
    DailyBreadMessage(
      title: "🕯️ Light for Your Path",
      body: "Seek guidance in Scripture for your choices and the path ahead.",
    ),
    DailyBreadMessage(
      title: "🌙 ദൈവത്തോടൊരു ശാന്ത നിമിഷം",
      body: "ഫോൺ മാറ്റിവെച്ച് കുറച്ചുനേരം ദൈവവചനത്തോടൊപ്പം ശാന്തമായി ഇരിക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🌙 A Quiet Moment with God",
      body: "Set distractions aside and spend a quiet moment with God's Word.",
    ),
    DailyBreadMessage(
      title: "🙏 പ്രാർത്ഥനയോടെ അവസാനിപ്പിക്കാം",
      body: "നന്ദിയും ആവശ്യങ്ങളും ദൈവത്തോട് പങ്കുവെച്ച് ഈ ദിവസം പ്രാർത്ഥനയോടെ അവസാനിപ്പിക്കൂ.",
    ),
    DailyBreadMessage(
      title: "🙏 Close with Prayer",
      body: "Share your thanks and needs with God, and close the day in prayer.",
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
