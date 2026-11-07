import 'dart:io';

typedef BoardGame = ({
  String name,
  String publisher,
  int players,
  int duration,
  double difficulty,
  int year,
  DateTime addedAt,
});

typedef ParseResult = ({BoardGame? game, String? error});

final List<String> inputData = [
  'Catan,Kosmos,4,90,2.5,1995,2026-10-01',
  'Carcassonne,Hans im Gluck,5,45,2.0,2000,2026-10-02',
  'Ticket to Ride,Days of Wonder,5,60,2.0,2004,2026-10-03',
  'Dixit,Libellud,6,40,1.5,2008,2026-10-04',
  'Pandemic,Z-Man Games,4,60,2.5,2008,2026-10-05',
  'Azul,Next Move Games,4,45,1.8,2017,2026-10-06',
  '7 Wonders,Repos Production,7,30,2.3,2010,2026-10-07',
  'Splendor,Space Cowboys,4,30,1.8,2014,2026-10-08',
  'Wingspan,Stonemaier Games,5,70,2.5,2019,2026-10-09',
  'Codenames,Czech Games Edition,8,15,1.3,2015,2026-10-10',
  'Gloomhaven,Cephalofair Games,4,120,4.5,2017,2026-10-11',
  'The Crew,Kosmos,5,20,1.5,2019,2026-10-12',
  'Root,Leder Games,4,90,3.8,2018,2026-10-13',
  'Splendor Duel,Space Cowboys,2,30,2.0,2022,2026-10-14',
  'Patchwork,Lookout Games,2,30,1.6,2014,2026-10-15',
  'Missing Publisher, ,4,60,2.0,2020,2026-10-16',
  'Wrong Players,Publisher,abc,60,2.0,2020,2026-10-17',
  'Wrong Date,Publisher,4,60,2.0,2020,invalid-date',
];

ParseResult parseLine(String line) {
  final fields = line.split(',').map((field) => field.trim()).toList();

  if (fields.length != 7) {
    return (game: null, error: 'Некоректна кількість полів');
  }

  if (fields.any((field) => field.isEmpty)) {
    return (game: null, error: 'Відсутнє обов’язкове поле');
  }

  final players = int.tryParse(fields[2]);
  final duration = int.tryParse(fields[3]);
  final difficulty = double.tryParse(fields[4]);
  final year = int.tryParse(fields[5]);
  final addedAt = DateTime.tryParse(fields[6]);

  if (players == null) {
    return (game: null, error: 'Некоректна кількість гравців');
  }

  if (duration == null) {
    return (game: null, error: 'Некоректна тривалість гри');
  }

  if (difficulty == null) {
    return (game: null, error: 'Некоректний рівень складності');
  }

  if (year == null) {
    return (game: null, error: 'Некоректний рік випуску');
  }

  if (addedAt == null) {
    return (game: null, error: 'Некоректна дата додавання');
  }

  return (
    game: (
      name: fields[0],
      publisher: fields[1],
      players: players,
      duration: duration,
      difficulty: difficulty,
      year: year,
      addedAt: addedAt,
    ),
    error: null,
  );
}

String? validateGame(BoardGame game) {
  if (game.players < 1 || game.players > 20) {
    return 'Кількість гравців має бути від 1 до 20';
  }

  if (game.duration < 5 || game.duration > 300) {
    return 'Тривалість гри має бути від 5 до 300 хвилин';
  }

  if (game.difficulty < 1 || game.difficulty > 5) {
    return 'Складність має бути від 1 до 5';
  }

  final currentYear = DateTime.now().year;

  if (game.year < 1900 || game.year > currentYear) {
    return 'Некоректний рік випуску';
  }

  return null;
}

Map<String, List<BoardGame>> groupGamesByPublisher(List<BoardGame> games) {
  return games.fold<Map<String, List<BoardGame>>>({}, (groups, game) {
    groups.putIfAbsent(game.publisher, () => []);
    groups[game.publisher]!.add(game);
    return groups;
  });
}

Map<String, double> calculateAverageDifficultyByPublisher(
  Map<String, List<BoardGame>> groups,
) {
  return groups.map((publisher, games) {
    final total = games
        .map((game) => game.difficulty)
        .fold(0.0, (sum, difficulty) => sum + difficulty);

    return MapEntry(publisher, total / games.length);
  });
}

List<BoardGame> sortGames(List<BoardGame> games, {bool ascending = true}) {
  final sortedGames = List<BoardGame>.from(games);

  sortedGames.sort((first, second) {
    var comparison = first.year.compareTo(second.year);

    if (comparison == 0) {
      comparison = first.name.compareTo(second.name);
    }

    return ascending ? comparison : -comparison;
  });

  return sortedGames;
}

String buildReport({
  required String title,
  required List<BoardGame> games,
  bool showPublisher = true,
  bool showDifficulty = true,
}) {
  final buffer = StringBuffer();

  buffer.writeln('\n$title');
  buffer.writeln('=' * title.length);

  if (games.isEmpty) {
    buffer.writeln('Даних немає');
    return buffer.toString();
  }

  for (final game in games) {
    buffer.writeln('Назва: ${game.name}');

    if (showPublisher) {
      buffer.writeln('Видавець: ${game.publisher}');
    }

    buffer.writeln('Кількість гравців: ${game.players}');
    buffer.writeln('Тривалість: ${game.duration} хв');

    if (showDifficulty) {
      buffer.writeln('Складність: ${game.difficulty}');
    }

    buffer.writeln('Рік випуску: ${game.year}');
    buffer.writeln('Дата додавання: ${game.addedAt.toString().split(' ')[0]}');
    buffer.writeln('-' * 30);
  }

  return buffer.toString();
}

int Function() createGameCounter() {
  var count = 0;

  int counter() {
    count++;
    return count;
  }

  return counter;
}

String maskPublisher(String publisher) {
  final regex = RegExp(r'^(?<first>.)(?<hidden>.*)(?<last>.)$');

  return publisher.replaceAllMapped(regex, (match) {
    final first = match.group(1)!;
    final hidden = match.group(2)!;
    final last = match.group(3)!;
    final masked = List<String>.filled(hidden.length, '*').join();

    return '$first$masked$last';
  });
}

int daysSinceAdded(BoardGame game) {
  return DateTime.now().difference(game.addedAt).inDays;
}

void main() {
  final parseResults = inputData.map(parseLine).toList();

  final validGames = parseResults
      .where((result) => result.game != null)
      .map((result) => result.game!)
      .toList();

  final parseErrors = parseResults
      .where((result) => result.error != null)
      .map((result) => result.error!)
      .toList();

  final validationErrors = validGames
      .map(validateGame)
      .where((error) => error != null)
      .toList();

  final acceptedGames = validGames
      .where((game) => validateGame(game) == null)
      .toList();

  print('ЗАГАЛЬНА СТАТИСТИКА');
  print('Усього записів: ${inputData.length}');
  print('Коректних записів: ${acceptedGames.length}');
  print('Пошкоджених записів: ${parseErrors.length}');
  print('Помилок валідації: ${validationErrors.length}');

  print('\nПОМИЛКИ РОЗБОРУ:');

  for (final error in parseErrors) {
    print('- $error');
  }

  print('\nПОМИЛКИ ВАЛІДАЦІЇ:');

  if (validationErrors.isEmpty) {
    print('Помилок валідації не знайдено');
  } else {
    for (final error in validationErrors) {
      print('- $error');
    }
  }

  final multiplayerGames = acceptedGames
      .where((game) => game.players >= 4)
      .map((game) => game.players)
      .fold(0, (sum, players) => sum + players);

  print('\nКОНВЕЄР 1 — ГРАВЦІ');
  print(
    'Сумарна кількість гравців у багатокористувацьких іграх: '
    '$multiplayerGames',
  );

  final simpleGamesReport = acceptedGames
      .where((game) => game.difficulty <= 2.5)
      .map((game) => game.name)
      .fold<StringBuffer>(StringBuffer(), (buffer, name) {
        buffer.writeln('- $name');
        return buffer;
      });

  print('\nКОНВЕЄР 2 — ІГРИ ЗІ СКЛАДНІСТЮ ДО 2.5');
  stdout.write(simpleGamesReport);

  final totalDifficulty = acceptedGames
      .where((game) => game.year >= 2010)
      .map((game) => game.difficulty)
      .fold(0.0, (sum, difficulty) => sum + difficulty);

  final recentGamesCount = acceptedGames
      .where((game) => game.year >= 2010)
      .length;

  final averageDifficulty = recentGamesCount == 0
      ? 0.0
      : totalDifficulty / recentGamesCount;

  print('\nКОНВЕЄР 3 — СЕРЕДНЯ СКЛАДНІСТЬ');
  print(
    'Середня складність ігор від 2010 року: '
    '${averageDifficulty.toStringAsFixed(2)}',
  );

  final groupedGames = groupGamesByPublisher(acceptedGames);

  print('\nГРУПУВАННЯ ЗА ВИДАВЦЯМИ');

  for (final entry in groupedGames.entries) {
    print('${entry.key}: ${entry.value.length} ігор');
  }

  final publisherStatistics = calculateAverageDifficultyByPublisher(
    groupedGames,
  );

  print('\nСЕРЕДНЯ СКЛАДНІСТЬ ЗА ВИДАВЦЯМИ');

  for (final entry in publisherStatistics.entries) {
    print('${entry.key}: ${entry.value.toStringAsFixed(2)}');
  }

  final ascendingGames = sortGames(acceptedGames);

  print('\nСОРТУВАННЯ ЗА РОКОМ — ЗРОСТАННЯ');

  for (final game in ascendingGames) {
    print('${game.year} — ${game.name}');
  }

  final descendingGames = sortGames(acceptedGames, ascending: false);

  print('\nСОРТУВАННЯ ЗА РОКОМ — СПАДАННЯ');

  for (final game in descendingGames) {
    print('${game.year} — ${game.name}');
  }

  print(buildReport(title: 'ЗВІТ ПРО НАСТІЛЬНІ ІГРИ', games: acceptedGames));

  final counter = createGameCounter();

  print('\nЛІЧИЛЬНИК ІГОР:');
  print('Перший виклик: ${counter()}');
  print('Другий виклик: ${counter()}');
  print('Третій виклик: ${counter()}');

  print('\nМАСКУВАННЯ НАЗВ ВИДАВЦІВ:');

  for (final publisher in groupedGames.keys) {
    print(maskPublisher(publisher));
  }

  print('\nКІЛЬКІСТЬ ДНІВ ВІД ДОДАВАННЯ:');

  for (final game in acceptedGames) {
    print('${game.name}: ${daysSinceAdded(game)} днів');
  }
}
