import '../../models/session_record.dart';

/// Rule-based health scoring (0–100).
///
/// Stand breaks:     0–30 pts  (7+ breaks = full)
/// Hydration:        0–25 pts  (8+ glasses = full)
/// Breathing:        0–20 pts  (10+ min = full)
/// Sedentary ratio:  0–25 pts  (≤4h seated = full, ≥8h = 0)
class HealthScorer {
  static const passThreshold = 60;

  /// Score a single day.
  static int score(SessionRecord r) {
    final stand = (r.standBreaks / 7).clamp(0.0, 1.0) * 30;
    final water = (r.hydrationCount / 8).clamp(0.0, 1.0) * 25;
    final breathe = (r.breathingMinutes / 10).clamp(0.0, 1.0) * 20;

    // Seated: 4h = 240 min = full points; 8h = 480 min = 0 points
    final sitRatio = 1.0 - ((r.totalSitsMinutes - 240) / 240).clamp(0.0, 1.0);
    final seated = sitRatio * 25;

    return (stand + water + breathe + seated).round().clamp(0, 100);
  }

  /// Count consecutive healthy days ending at [records] (including today).
  /// [records] must be ordered oldest → newest.
  static int streak(List<SessionRecord> records) {
    int count = 0;
    for (int i = records.length - 1; i >= 0; i--) {
      if (score(records[i]) >= passThreshold) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Whether today is a healthy day.
  static bool isHealthy(SessionRecord today) => score(today) >= passThreshold;
}

extension ClampInt on int {
  int clamp(int min, int max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}
