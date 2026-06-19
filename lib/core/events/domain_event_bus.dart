import 'package:flutter/foundation.dart';

/// Base event
abstract class DomainEvent {}

class DomainEventBus {
  DomainEventBus._internal();

  static final DomainEventBus instance = DomainEventBus._internal();

  final ValueNotifier<DomainEvent?> _stream = ValueNotifier<DomainEvent?>(null);

  ValueListenable<DomainEvent?> get stream => _stream;

  void emit(DomainEvent event) {
    _stream.value = event;
  }
}
