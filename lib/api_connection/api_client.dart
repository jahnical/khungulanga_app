import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// An API client class that provides a configured Dio instance for making API requests.
class APIClient {
  /// The Dio instance used for making API requests.
  static final Dio dio = Dio();

  /// Sets up the cache interceptor for the Dio instance.
  static void setupCacheInterceptor() {
    // Create a cache interceptor with default options and a memory cache store.
    final interceptor = DioCacheInterceptor(options: CacheOptions(store: MemCacheStore()));

    // Add the cache interceptor to the Dio instance's interceptors.
    dio.interceptors.add(interceptor);
  }
}
