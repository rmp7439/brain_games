import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/game_repository.dart';
import '../repositories/mock_game_repository.dart';

/// Provides the GameRepository. 
/// The UI watches this provider, completely unaware that it is currently
/// being supplied by a MockGameRepository.
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return MockGameRepository();
});