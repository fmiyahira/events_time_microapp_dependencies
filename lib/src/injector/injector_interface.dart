abstract class IInjector {
  void registerSingleton<T>(T instance);

  void registerFactory<T>(T Function() function);

  T get<T>();

  void unregister<T>();
}
