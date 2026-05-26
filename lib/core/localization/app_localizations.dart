import 'dart:io' show Platform;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Translation map
// ---------------------------------------------------------------------------

const _strings = <String, Map<String, String>>{
  // ── App shell ──
  'appTitle': {'en': 'Moments', 'zh': '片刻'},
  'homeTab': {'en': 'Home', 'zh': '首页'},
  'moveTab': {'en': 'Move', 'zh': '活动'},
  'breatheTab': {'en': 'Breathe', 'zh': '呼吸'},
  'waterTab': {'en': 'Water', 'zh': '饮水'},
  'statsTab': {'en': 'Stats', 'zh': '统计'},
  'settingsTitle': {'en': 'Settings', 'zh': '设置'},

  // ── Sedentary home ──
  'minutesSeated': {'en': 'minutes seated', 'zh': '已坐分钟'},
  'iStoodUp': {'en': 'I stood up', 'zh': '我站起来了'},
  'sitMsg0': {
    'en': 'Settle in.\nLet your shoulders drop.',
    'zh': '先坐舒服。\n放松肩膀。',
  },
  'sitMsg1': {
    'en': 'No need to rush.\nYou\'re doing fine.',
    'zh': '不用急。\n这样就好。',
  },
  'sitMsg2': {
    'en': 'How does your body feel\nright now?',
    'zh': '现在身体\n感觉怎么样？',
  },
  'sitMsg3': {
    'en': 'Your body might enjoy\na gentle stretch soon.',
    'zh': '可以试着\n轻轻伸个懒腰了。',
  },
  'sitMsg4': {
    'en': 'Whenever you\'re ready,\ngo ahead and stand up.',
    'zh': '准备好了，\n就站起来吧。',
  },
  'sitMsg5': {
    'en': 'You\'ve been still for a while.\nEven a short walk will feel nice.',
    'zh': '你已经坐了好一会儿了。\n走两步会很舒服。',
  },

  // ── Breathing ──
  'breatheIdle': {'en': 'Breathe', 'zh': '呼吸'},
  'breatheIn': {'en': 'Breathe in', 'zh': '吸气'},
  'breatheHold': {'en': 'Hold', 'zh': '屏息'},
  'breatheOut': {'en': 'Breathe out', 'zh': '呼气'},
  'breathingCycles': {'en': 'cycles', 'zh': '次'},
  'startBtn': {'en': 'Start', 'zh': '开始'},
  'stopBtn': {'en': 'Stop', 'zh': '停止'},

  // ── Hydration ──
  'ofGoal': {'en': 'of', 'zh': '/'},
  'tapToLog': {'en': 'Tap to log a glass', 'zh': '轻点记录一杯水'},
  'undoBtn': {'en': 'Undo', 'zh': '撤销'},

  // ── Stretch ──
  'gentleMovements': {'en': 'Gentle movements', 'zh': '温和运动'},
  'stretchSoon': {
    'en': 'Simple stretches and mobility exercises\nwill appear here soon.',
    'zh': '简单的拉伸和活动练习\n即将到来。',
  },

  // ── Stats ──
  'todayTitle': {'en': 'Today', 'zh': '今日'},
  'standBreaks': {'en': 'Stand breaks', 'zh': '站立休息'},
  'glassesOfWater': {'en': 'Glasses of water', 'zh': '饮水杯数'},
  'breathingMinutes': {'en': 'Breathing minutes', 'zh': '呼吸练习'},
  'timeSeated': {'en': 'Time seated', 'zh': '久坐时长'},
  'minUnit': {'en': 'min', 'zh': '分钟'},
  'statsEmpty': {
    'en': 'Your wellness summary\nwill appear here.',
    'zh': '你的健康摘要\n将出现在这里。',
  },
  'healthScore': {'en': 'Health score', 'zh': '健康评分'},
  'streakDays': {'en': 'day streak', 'zh': '天连续'},
  'weeklyTrend': {'en': 'This week', 'zh': '本周趋势'},
  'consecutiveSits': {'en': 'Sit sessions', 'zh': '久坐次数'},
  'weekDays': {'en': 'M,T,W,T,F,S,S', 'zh': '一,二,三,四,五,六,日'},

  // ── Settings ──
  'settingsSubtitle': {
    'en': 'Customize your reminders and preferences.',
    'zh': '自定义提醒和偏好。',
  },
  'sedentaryLabel': {'en': 'Sedentary reminder', 'zh': '久坐提醒'},
  'hydrationLabel': {'en': 'Hydration reminder', 'zh': '饮水提醒'},
  'minuteValue': {'en': '{n} min', 'zh': '{n} 分钟'},
  'quietModeLabel': {'en': 'Quiet mode', 'zh': '安静模式'},
  'quietStartLabel': {'en': 'From', 'zh': '从'},
  'quietEndLabel': {'en': 'To', 'zh': '至'},
  'settingsNote': {
    'en': 'During quiet hours, reminders are silent.',
    'zh': '安静时段内不会发出提醒。',
  },
  'notifTitle': {'en': 'Notifications', 'zh': '通知偏好'},
  'normalSoundLabel': {'en': 'Reminder sound', 'zh': '提醒声音'},
  'normalVibrateLabel': {'en': 'Reminder vibration', 'zh': '提醒振动'},
  'urgentSoundLabel': {'en': 'Urgent sound', 'zh': '紧急声音'},
  'urgentVibrateLabel': {'en': 'Urgent vibration', 'zh': '紧急振动'},

  // ── Notifications ──
  'notifTitleGentle': {'en': 'Time to move', 'zh': '该动一动了'},
  'notifTitleNormal': {'en': 'Still sitting?', 'zh': '还在坐着吗？'},
  'notifTitleUrgent': {'en': 'Please stand up', 'zh': '请站起来吧'},
  'notifBody': {
    'en': 'You\'ve been sitting for {minutes} minutes. '
        'A short walk would feel nice.',
    'zh': '你已经坐了 {minutes} 分钟了。\n起来走两步会很舒服。',
  },
  'notifUrgent': {
    'en': 'You\'ve been sitting for {minutes} minutes. '
        'This is too long — please take a break now.',
    'zh': '你已经坐了 {minutes} 分钟了。\n时间太久了，请立刻休息活动。',
  },
};

// ---------------------------------------------------------------------------
// AppLocalizations
// ---------------------------------------------------------------------------

class AppLocalizations {
  final String _locale;

  AppLocalizations(this._locale);

  /// Current device locale, resolved once at startup.
  static String resolvedLocale = 'en';

  /// Initialize from device locale.
  static void init() {
    try {
      final sys = Platform.localeName;
      resolvedLocale = sys.startsWith('zh') ? 'zh' : 'en';
    } catch (_) {
      resolvedLocale = 'en';
    }
  }

  // ── Lookup ──

  String get(String key) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[_locale] ?? entry['en'] ?? key;
  }

  /// Replace '{name}' placeholders with values.
  String getWith(String key, Map<String, String> placeholders) {
    var text = get(key);
    for (final entry in placeholders.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  // ── Convenience getters ──

  String get appTitle => get('appTitle');
  String get homeTab => get('homeTab');
  String get moveTab => get('moveTab');
  String get breatheTab => get('breatheTab');
  String get waterTab => get('waterTab');
  String get statsTab => get('statsTab');
  String get settingsTitle => get('settingsTitle');
  String get minutesSeated => get('minutesSeated');
  String get iStoodUp => get('iStoodUp');
  String get breatheIdle => get('breatheIdle');
  String get breatheIn => get('breatheIn');
  String get breatheHold => get('breatheHold');
  String get breatheOut => get('breatheOut');
  String get breathingCycles => get('breathingCycles');
  String get startBtn => get('startBtn');
  String get stopBtn => get('stopBtn');
  String get ofGoal => get('ofGoal');
  String get tapToLog => get('tapToLog');
  String get undoBtn => get('undoBtn');
  String get gentleMovements => get('gentleMovements');
  String get stretchSoon => get('stretchSoon');
  String get todayTitle => get('todayTitle');
  String get standBreaks => get('standBreaks');
  String get glassesOfWater => get('glassesOfWater');
  String get breathingMinutes => get('breathingMinutes');
  String get timeSeated => get('timeSeated');
  String get minUnit => get('minUnit');
  String get statsEmpty => get('statsEmpty');
  String get healthScore => get('healthScore');
  String get streakDays => get('streakDays');
  String get weeklyTrend => get('weeklyTrend');
  String get consecutiveSits => get('consecutiveSits');
  List<String> get weekDayLabels {
    final raw = get('weekDays');
    return raw.split(',');
  }

  String get settingsSubtitle => get('settingsSubtitle');
  String get sedentaryLabel => get('sedentaryLabel');
  String get hydrationLabel => get('hydrationLabel');
  String minutesValue(int n) => getWith('minuteValue', {'n': '$n'});
  String get quietModeLabel => get('quietModeLabel');
  String get quietStartLabel => get('quietStartLabel');
  String get quietEndLabel => get('quietEndLabel');
  String get settingsNote => get('settingsNote');
  String get notifTitle => get('notifTitle');
  String get normalSoundLabel => get('normalSoundLabel');
  String get normalVibrateLabel => get('normalVibrateLabel');
  String get urgentSoundLabel => get('urgentSoundLabel');
  String get urgentVibrateLabel => get('urgentVibrateLabel');

  // Sedentary messages — indexed by progress phase
  String sitMessage(double progress, int elapsedSeconds) {
    if (elapsedSeconds < 60) return get('sitMsg0');
    if (progress < 0.30) return get('sitMsg1');
    if (progress < 0.55) return get('sitMsg2');
    if (progress < 0.80) return get('sitMsg3');
    if (progress < 1.0) return get('sitMsg4');
    return get('sitMsg5');
  }

  /// For use without BuildContext (notifications).
  static String notifTitleFor(String locale, dynamic tier) {
    final key = 'notifTitle${_tierSuffix(tier)}';
    return _strings[key]?[locale] ?? _strings[key]?['en'] ?? '';
  }

  static String notifBodyFor(String locale, int minutes) {
    final raw = _strings['notifBody']?[locale] ??
        _strings['notifBody']?['en'] ??
        '';
    return raw.replaceAll('{minutes}', '$minutes');
  }

  static String notifUrgent(String locale, int minutes) {
    final raw = _strings['notifUrgent']?[locale] ??
        _strings['notifUrgent']?['en'] ??
        '';
    return raw.replaceAll('{minutes}', '$minutes');
  }

  static String _tierSuffix(dynamic tier) {
    final s = tier.toString();
    if (s.contains('normal')) return 'Normal';
    if (s.contains('urgent')) return 'Urgent';
    return 'Gentle';
  }

  // ── Delegate ──

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;
}

// ---------------------------------------------------------------------------
// LocalizationsDelegate
// ---------------------------------------------------------------------------

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'zh';

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale.languageCode);

  @override
  bool shouldReload(covariant _) => false;
}
