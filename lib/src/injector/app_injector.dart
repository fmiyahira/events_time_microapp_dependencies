import 'package:events_time_microapp_dependencies/src/injector/injector_interface.dart';
import 'package:kiwi/kiwi.dart';

class AppInjector implements IInjector {
  final KiwiContainer _kiwi = KiwiContainer();

  @override
  T get<T>() => _kiwi.resolve<T>();

  @override
  void registerFactory<T>(T Function() function) {
    _kiwi.registerFactory<T>((_) => function.call());
  }

  @override
  void registerSingleton<T>(T instance) {
    _kiwi.registerSingleton<T>((_) => instance);
  }

  @override
  void unregister<T>() {
    _kiwi.unregister<T>();
  }
}
