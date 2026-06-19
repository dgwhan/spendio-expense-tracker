import 'package:spend_io_app/core/events/domain_event_bus.dart';

class TransactionCreatedEvent extends DomainEvent {
  final String accountId;
  final double amount;

  TransactionCreatedEvent({
    required this.accountId,
    required this.amount,
  });
}

class TransactionDeletedEvent extends DomainEvent {
  final String accountId;
  final double amount;

  TransactionDeletedEvent({
    required this.accountId,
    required this.amount,
  });
}
