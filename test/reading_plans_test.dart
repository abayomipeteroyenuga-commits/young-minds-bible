import 'package:flutter_test/flutter_test.dart';
import 'package:young_minds_bible/data/reading_plans.dart';

void main() {
  test('reading plans have consistent day counts and unique ids', () {
    final ids = <String>{};
    for (final plan in readingPlans) {
      expect(plan.days, greaterThan(0));
      expect(plan.readings.length, plan.days);
      expect(ids.add(plan.id), isTrue, reason: 'Duplicate reading-plan id: ${plan.id}');
    }
  });
}
