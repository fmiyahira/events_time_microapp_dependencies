// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:events_time_microapp_dependencies/src/injector/injector_interface.dart';
import 'package:flutter/material.dart';

import '../requesting/all.dart';

class SubAppRegistration {
  String name;
  Map<String, WidgetBuilder> routes;

  SubAppRegistration({
    required this.name,
    required this.routes,
  });
}

abstract class ISubApp {
  SubAppRegistration register();
  Future<void> initialize({
    required IRequesting requesting,
    required IInjector injector,
  });
}
