import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class APIClient {
  static final Dio dio = Dio();

  static void setupCacheInterceptor() {
    final interceptor = DioCacheInterceptor(options: CacheOptions(store: MemCacheStore()));
    dio.interceptors.add(interceptor);
  }
}
