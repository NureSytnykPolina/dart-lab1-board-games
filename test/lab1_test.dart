import '../bin/lab1.dart' as lab;
import 'package:test/test.dart';

void main() {
  group('Обробка даних настільних ігор', () {
    test('Коректний рядок перетворюється на настільну гру', () {
      final result = lab.parseLine(
        'Catan,Kosmos,4,90,2.5,1995,2026-10-01',
      );

      expect(result.game, isNotNull);
      expect(result.error, isNull);
      expect(result.game!.name, 'Catan');
      expect(result.game!.publisher, 'Kosmos');
      expect(result.game!.players, 4);
    });

    test('Рядок із порожнім полем повертає помилку', () {
      final result = lab.parseLine(
        'Catan,,4,90,2.5,1995,2026-10-01',
      );

      expect(result.game, isNull);
      expect(result.error, isNotNull);
    });

    test('Некоректна кількість гравців обробляється правильно', () {
      final result = lab.parseLine(
        'Catan,Kosmos,abc,90,2.5,1995,2026-10-01',
      );

      expect(result.game, isNull);
      expect(result.error, isNotNull);
    });

    test('Гра з некоректною кількістю гравців не проходить валідацію', () {
      final game = (
        name: 'Test Game',
        publisher: 'Test Publisher',
        players: 25,
        duration: 60,
        difficulty: 2.5,
        year: 2020,
        addedAt: DateTime(2026, 10, 1),
      );

      expect(lab.validateGame(game), isNotNull);
    });

    test('Ігри сортуються за роком випуску', () {
      final first = lab.parseLine(
        'Catan,Kosmos,4,90,2.5,1995,2026-10-01',
      ).game!;

      final second = lab.parseLine(
        'Azul,Next Move Games,4,45,1.8,2017,2026-10-06',
      ).game!;

      final sorted = lab.sortGames([second, first]);

      expect(sorted.first.name, 'Catan');
      expect(sorted.last.name, 'Azul');
    });

    test('Ігри групуються за видавцями', () {
      final games = [
        lab.parseLine(
          'Catan,Kosmos,4,90,2.5,1995,2026-10-01',
        ).game!,
        lab.parseLine(
          'The Crew,Kosmos,5,20,1.5,2019,2026-10-12',
        ).game!,
      ];

      final groups = lab.groupGamesByPublisher(games);

      expect(groups.containsKey('Kosmos'), isTrue);
      expect(groups['Kosmos']!.length, 2);
    });

    test('Назва видавця маскується зірочками', () {
      expect(lab.maskPublisher('Kosmos'), 'K****s');
    });

    test('Лічильник збільшується після кожного виклику', () {
      final counter = lab.createGameCounter();

      expect(counter(), 1);
      expect(counter(), 2);
      expect(counter(), 3);
    });
  });
}