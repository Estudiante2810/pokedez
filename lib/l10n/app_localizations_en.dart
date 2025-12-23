// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get search => 'Search';

  @override
  String get favorites => 'Favorites';

  @override
  String get settings => 'Settings';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get addFavorites =>
      'Add your favorite Pokémon by tapping the heart icon';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get eggGroups => 'Egg Groups';

  @override
  String get abilities => 'Abilities';

  @override
  String get evolutions => 'Evolutions';

  @override
  String get noEvolutions => 'No evolutions found';

  @override
  String get level => 'Lv';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get statistics => 'Statistics';

  @override
  String get combat => 'Combat';

  @override
  String get statsOverview => 'Stats Overview';

  @override
  String get totalStats => 'Total Stats';

  @override
  String get detailedStats => 'Detailed Stats';

  @override
  String get moves => 'Moves';

  @override
  String get noMoves => 'No moves available';

  @override
  String get weaknesses => 'Weaknesses';

  @override
  String get resistances => 'Resistances';

  @override
  String get immunities => 'Immunities';

  @override
  String get close => 'Close';

  @override
  String get share => 'Share';

  @override
  String get shareCard => 'Share Card';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get hp => 'HP';

  @override
  String get attack => 'Attack';

  @override
  String get defense => 'Defense';

  @override
  String get specialAttack => 'Sp. Atk';

  @override
  String get specialDefense => 'Sp. Def';

  @override
  String get speed => 'Speed';

  @override
  String get learnMethod => 'Learn Method';

  @override
  String get all => 'All';

  @override
  String get sortBy => 'Sort By';

  @override
  String get name => 'Name';

  @override
  String get power => 'Power';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get type => 'Type';

  @override
  String get category => 'Category';

  @override
  String get noMovesFilter => 'No moves match the current filters';

  @override
  String get adjustFilters => 'Adjust the filters to see more moves';

  @override
  String get triviaTitle => 'Pokémon Trivia';

  @override
  String get highScore => 'High Score';

  @override
  String get whoIsThatPokemon => 'Who\'s that Pokémon?';

  @override
  String get triviaInstructions =>
      'Guess the Pokémon by its silhouette.\nFaster = more points!\n5 lives per game :p';

  @override
  String get play => 'PLAY';

  @override
  String get question => 'Question';

  @override
  String get points => 'Points';

  @override
  String get time => 'Time';

  @override
  String correct(int points) {
    return 'Correct! +$points points';
  }

  @override
  String get timeOut => 'Time\'s up!';

  @override
  String incorrect(String name) {
    return 'Incorrect! It was $name';
  }

  @override
  String get newRecord => 'NEW RECORD!';

  @override
  String get gameOver => 'Game Over';

  @override
  String get finalScore => 'Final Score';

  @override
  String get questionsAnswered => 'Questions Answered';

  @override
  String get personalRecord => 'Personal Record';

  @override
  String get achievementsUnlocked => 'Achievements Unlocked';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get home => 'Home';

  @override
  String get firstCapture => 'First Capture';

  @override
  String get fireStreak => 'Fire Streak';

  @override
  String get pokemonMaster => 'Pokémon Master';

  @override
  String get expert => 'Expert';

  @override
  String get legend => 'Legend';
}
