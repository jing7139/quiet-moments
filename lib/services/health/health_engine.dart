import '../../models/session_record.dart';

// ---------------------------------------------------------------------------
// Abstract interface — swap to LLM later without changing callers
// ---------------------------------------------------------------------------

/// Analyzes wellness data and returns gentle suggestions.
///
/// Implementations:
/// - [RuleHealthEngine] — deterministic rules (current default)
/// - Future: LLM-backed engine via the same interface
abstract class HealthEngine {
  /// Generate up to 3 suggestions in the given [locale].
  /// [history] is ordered oldest → newest, excluding today.
  List<Suggestion> analyze(List<SessionRecord> history, SessionRecord today,
      {String locale = 'en'});
}

// ---------------------------------------------------------------------------
// Suggestion model
// ---------------------------------------------------------------------------

class Suggestion {
  final String text;
  final SuggestionKind kind; // positive, neutral, gentle nudge

  const Suggestion(this.text, {this.kind = SuggestionKind.neutral});
}

enum SuggestionKind { positive, neutral, nudge }

// ---------------------------------------------------------------------------
// Rule-based engine
// ---------------------------------------------------------------------------

class RuleHealthEngine implements HealthEngine {
  const RuleHealthEngine();

  @override
  List<Suggestion> analyze(
      List<SessionRecord> history, SessionRecord today,
      {String locale = 'en'}) {
    final t = (String key) => _t(key, locale);
    final result = <Suggestion>[];

    if (history.isEmpty) return result;

    final avgSeated = _avg(history.map((r) => r.totalSitsMinutes));
    final avgHydration = _avg(history.map((r) => r.hydrationCount));
    final avgStands = _avg(history.map((r) => r.standBreaks));
    final totalBreathing =
        history.map((r) => r.breathingMinutes).reduce((a, b) => a + b);

    // ── Rule 1: High sedentary today vs average ──
    if (avgSeated > 0 && today.totalSitsMinutes > avgSeated * 1.3) {
      result.add(Suggestion(
        t('high_sedentary'),
        kind: SuggestionKind.nudge,
      ));
    }

    // ── Rule 2: Declining stand breaks (last 3 days) ──
    if (history.length >= 3) {
      final recent = history.sublist(history.length - 3);
      final trend = _trend(recent.map((r) => r.standBreaks).toList());
      if (trend < 0 && today.standBreaks < 3) {
        result.add(Suggestion(
          t('declining_stands'),
          kind: SuggestionKind.nudge,
        ));
      }
    }

    // ── Rule 3: Low hydration ──
    if (avgHydration < 4) {
      result.add(Suggestion(
        t('low_hydration'),
        kind: SuggestionKind.nudge,
      ));
    }

    // ── Rule 4: No breathing practice ──
    if (totalBreathing == 0 && history.length >= 3) {
      result.add(Suggestion(
        t('no_breathing'),
        kind: SuggestionKind.neutral,
      ));
    }

    // ── Rule 5: Hydration hero ──
    if (history.length >= 5) {
      final allWellHydrated = history
          .sublist(history.length - 5)
          .every((r) => r.hydrationCount >= 7);
      if (allWellHydrated) {
        result.add(Suggestion(
          t('hydration_hero'),
          kind: SuggestionKind.positive,
        ));
      }
    }

    // ── Rule 6: Good stand rhythm today ──
    if (today.standBreaks >= 5) {
      result.add(Suggestion(
        t('good_rhythm').replaceAll('{n}', '${today.standBreaks}'),
        kind: SuggestionKind.positive,
      ));
    }

    // ── Rule 7: Improving stand trend ──
    if (history.length >= 4) {
      final full = history.map((r) => r.standBreaks).toList();
      if (_trend(full) > 0 && today.standBreaks >= 4) {
        result.add(Suggestion(
          t('improving'),
          kind: SuggestionKind.positive,
        ));
      }
    }

    // Return at most 3: prefer nudges first, then neutrals, then positives.
    result.sort((a, b) => a.kind.index.compareTo(b.kind.index));
    return result.take(3).toList();
  }

  // ── Helpers ──

  double _avg(Iterable<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Positive = increasing, negative = declining, 0 = flat.
  int _trend(List<int> values) {
    if (values.length < 2) return 0;
    int dir = 0;
    for (int i = 1; i < values.length; i++) {
      if (values[i] > values[i - 1]) dir++;
      else if (values[i] < values[i - 1]) dir--;
    }
    return dir;
  }

  // ── Templates ──

  static String _t(String key, String locale) {
    final isZh = locale == 'zh';
    switch (key) {
      case 'high_sedentary':
        return isZh
            ? '今天久坐时间偏长，记得多站起来走走'
            : 'You\'ve been sitting more than usual today — take extra breaks.';
      case 'declining_stands':
        return isZh
            ? '最近站立休息在变少，试试每45分钟起来活动一次'
            : 'Your stand breaks are declining — try getting up every 45 minutes.';
      case 'low_hydration':
        return isZh
            ? '最近饮水偏少，试试在桌边放一杯水'
            : 'You\'ve been drinking less water lately — keep a glass nearby.';
      case 'no_breathing':
        return isZh
            ? '好几天没做呼吸练习了，来一次吧？只需要一分钟'
            : 'You haven\'t done a breathing exercise in a while — just one minute helps.';
      case 'hydration_hero':
        return isZh
            ? '你最近饮水习惯特别棒，保持下去！'
            : 'Your hydration has been excellent — keep it up!';
      case 'good_rhythm':
        return isZh
            ? '今天已经站起来了 {n} 次，节奏真好'
            : 'You\'ve stood up {n} times today — great rhythm.';
      case 'improving':
        return isZh
            ? '最近活动频率在上升，身体会感谢你的'
            : 'Your activity is trending up — your body will thank you.';
      default:
        return key;
    }
  }
}
