import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/home_section.dart';
import '../../../domain/entities/banner_ad.dart';

final homeSectionsProvider = FutureProvider<List<HomeSection>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getHomeSections();
});

final homeBannersProvider =
    FutureProvider.family<List<BannerAd>, String>((ref, position) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getBanners(position);
});

final homeBannerByIdProvider =
    FutureProvider.family<BannerAd?, String>((ref, bannerId) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getBannerById(bannerId);
});
