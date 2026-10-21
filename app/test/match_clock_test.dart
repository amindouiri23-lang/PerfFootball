import 'package:flutter_test/flutter_test.dart';
import 'package:perffoot/features/matches/match_repository.dart';

void main() {
  final kickOff = DateTime.utc(2026, 10, 21, 15);
  String at(int minutes, {int seconds = 0}) => kickOff.add(Duration(minutes: minutes, seconds: seconds)).toIso8601String();

  test('1re mi-temps : minute commencée, temps additionnel au-delà de 45', () {
    final now = kickOff.add(const Duration(minutes: 22, seconds: 30));
    expect(matchClockLabel('first_half', kickOff.toIso8601String(), null, 90, now: now), "23'");
    expect(matchClockLabel('first_half', at(-46), null, 90, now: kickOff), "45+2'");
    expect(matchLiveMinute('first_half', at(-46), null, 90, now: kickOff), 47);
  });

  test('mi-temps, 2e mi-temps et fin', () {
    expect(matchClockLabel('half_time', at(0), null, 90), 'MT');
    expect(matchClockLabel('second_half', at(0), kickOff.toIso8601String(), 90, now: kickOff.add(const Duration(minutes: 21))), "67'");
    expect(matchClockLabel('second_half', at(0), at(-48), 90, now: kickOff), "90+4'");
    expect(matchClockLabel('finished', at(0), at(0), 90), 'Fin');
    expect(matchClockLabel(null, null, null, 90), '');
  });

  test('match de 70 minutes : mi-temps à 35', () {
    expect(matchClockLabel('first_half', at(-36), null, 70, now: kickOff), "35+2'");
  });
}
