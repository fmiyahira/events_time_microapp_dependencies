// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:events_time_microapp_dependencies/events_time_microapp_dependencies.dart';
import 'package:flutter/material.dart';

class SubAppRegistration {
  String name;
  Map<String, WidgetBuilder>? routes;

  SubAppRegistration({
    required this.name,
    this.routes,
  });
}

abstract class ISubApp {
  SubAppRegistration register();
  Future<void> initialize({
    required IRequesting requesting,
    required IInjector injector,
    required ILocalStorage localStorage,
  });
}
