
import 'package:dio/dio.dart';
import 'package:foxschool/di/intercepter/AuthInterceptor.dart';
import 'package:foxschool/di/intercepter/LoggingInterceptor.dart';
import 'package:foxschool/domain/repository/FoxSchoolRepository.dart';
import 'package:foxschool/data/repository/FoxSchoolRepositoryImpl.dart';
import 'package:foxschool/presentation/bloc/flashcard/api/FlashcardBloc.dart';
import 'package:foxschool/presentation/bloc/movie/api/MovieContentsBloc.dart';
import 'package:foxschool/presentation/bloc/vocabulary/api/VocabularyBloc.dart';
import 'package:foxschool/common/FoxschoolLocalization.dart';
import 'package:foxschool/data/remote/ApiClient.dart';
import 'package:get_it/get_it.dart';


final getIt = GetIt.instance;
Future<void> init() async
{
  final FoxschoolLocalization foxschoolLocalization = FoxschoolLocalization(filePath: 'assets/json/string_kr.json');
  await foxschoolLocalization.onSetting();
  getIt.registerSingleton(foxschoolLocalization);

  final dio = Dio();
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LoggingInterceptor());
  getIt.registerSingleton(dio);

  final apiClient = ApiClient(getIt<Dio>());
  getIt.registerSingleton(apiClient);

  getIt.registerLazySingleton<FoxSchoolRepository>(() => FoxSchoolRepositoryImpl(dio: getIt<Dio>(), apiClient: getIt<ApiClient>()));
  getIt.registerLazySingleton(() => MovieContentsBloc(repository: getIt<FoxSchoolRepository>()));
  getIt.registerLazySingleton(() => VocabularyBloc(repository: getIt<FoxSchoolRepository>()));
  getIt.registerLazySingleton(() => FlashcardBloc(repository: getIt<FoxSchoolRepository>()));
}



