// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get search => 'Buscar';

  @override
  String get favorites => 'Favoritos';

  @override
  String get settings => 'Configuración';

  @override
  String get noFavorites => 'No hay favoritos aún';

  @override
  String get addFavorites =>
      'Agrega tus Pokémon favoritos tocando el ícono de corazón';

  @override
  String get height => 'Altura';

  @override
  String get weight => 'Peso';

  @override
  String get eggGroups => 'Grupos Huevo';

  @override
  String get abilities => 'Habilidades';

  @override
  String get evolutions => 'Evoluciones';

  @override
  String get noEvolutions => 'No se encontraron evoluciones';

  @override
  String get level => 'Nv';

  @override
  String get basicInfo => 'Info Básica';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get combat => 'Combate';

  @override
  String get statsOverview => 'Resumen de Stats';

  @override
  String get totalStats => 'Total de Stats';

  @override
  String get detailedStats => 'Stats Detalladas';

  @override
  String get moves => 'Movimientos';

  @override
  String get noMoves => 'No hay movimientos disponibles';

  @override
  String get weaknesses => 'Debilidades';

  @override
  String get resistances => 'Resistencias';

  @override
  String get immunities => 'Inmunidades';

  @override
  String get close => 'Cerrar';

  @override
  String get share => 'Compartir';

  @override
  String get shareCard => 'Compartir Carta';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get loading => 'Cargando...';

  @override
  String get noData => 'Sin datos';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get changeLanguage => 'Cambiar Idioma';

  @override
  String get hp => 'PS';

  @override
  String get attack => 'Ataque';

  @override
  String get defense => 'Defensa';

  @override
  String get specialAttack => 'At. Esp.';

  @override
  String get specialDefense => 'Def. Esp.';

  @override
  String get speed => 'Velocidad';

  @override
  String get learnMethod => 'Método de Aprendizaje';

  @override
  String get all => 'Todos';

  @override
  String get sortBy => 'Ordenar Por';

  @override
  String get name => 'Nombre';

  @override
  String get power => 'Potencia';

  @override
  String get accuracy => 'Precisión';

  @override
  String get type => 'Tipo';

  @override
  String get category => 'Categoría';

  @override
  String get noMovesFilter =>
      'No hay movimientos que coincidan con los filtros actuales';

  @override
  String get adjustFilters => 'Ajusta los filtros para ver más movimientos';

  @override
  String get triviaTitle => 'Trivia Pokémon';

  @override
  String get highScore => 'Récord';

  @override
  String get whoIsThatPokemon => '¿Quién es ese Pokémon?';

  @override
  String get triviaInstructions =>
      'Adivina el Pokémon por su silueta.\n¡ + rápido = + puntos!\n5 vidas x partida :p';

  @override
  String get play => 'JUGAR';

  @override
  String get question => 'Pregunta';

  @override
  String get points => 'Puntos';

  @override
  String get time => 'Tiempo';

  @override
  String correct(int points) {
    return '¡Correcto! +$points puntos';
  }

  @override
  String get timeOut => '¡Tiempo agotado!';

  @override
  String incorrect(String name) {
    return '¡Incorrecto! Era $name';
  }

  @override
  String get newRecord => '¡NUEVO RÉCORD!';

  @override
  String get gameOver => 'Juego Terminado';

  @override
  String get finalScore => 'Puntuación Final';

  @override
  String get questionsAnswered => 'Preguntas Respondidas';

  @override
  String get personalRecord => 'Récord Personal';

  @override
  String get achievementsUnlocked => 'Logros Desbloqueados';

  @override
  String get playAgain => 'JUGAR DE NUEVO';

  @override
  String get home => 'Inicio';

  @override
  String get firstCapture => 'Primera Captura';

  @override
  String get fireStreak => 'Racha de Fuego';

  @override
  String get pokemonMaster => 'Maestro Pokémon';

  @override
  String get expert => 'Experto';

  @override
  String get legend => 'Leyenda';
}
