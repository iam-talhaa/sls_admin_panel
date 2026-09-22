import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/blog/data/repositories/blog_repository.dart';
import '../../features/destinations/data/repositories/destinations_repository.dart';
import '../../features/fleet/data/repositories/fleet_repository.dart';

final seedDataServiceProvider = Provider<SeedDataService>((ref) {
  return SeedDataService(
    fleetRepository: ref.watch(fleetRepositoryProvider),
    destinationsRepository: ref.watch(destinationsRepositoryProvider),
    blogRepository: ref.watch(blogRepositoryProvider),
  );
});

class SeedDataService {
  final FleetRepository fleetRepository;
  final DestinationsRepository destinationsRepository;
  final BlogRepository blogRepository;

  SeedDataService({
    required this.fleetRepository,
    required this.destinationsRepository,
    required this.blogRepository,
  });

  Future<void> seedInitialData({bool force = true}) async {
    await Future.wait([
      fleetRepository.seedInitialJets(force: force),
      destinationsRepository.seedInitialDestinations(force: force),
      blogRepository.seedInitialBlogs(force: force),
    ]);
  }
}
