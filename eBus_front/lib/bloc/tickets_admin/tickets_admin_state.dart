import 'package:smart_bus/models/ticket.dart';
import 'package:smart_bus/models/type_abonnement.dart';

abstract class TicketsAdminState {}

class TicketsAdminInitial extends TicketsAdminState {}

class TicketsAdminLoading extends TicketsAdminState {}

class TicketsAdminLoaded extends TicketsAdminState {
  final List<Ticket> tickets;
  final List<TypeAbonnement> abonnements;

  TicketsAdminLoaded({required this.tickets, required this.abonnements});
}

class TicketsAdminError extends TicketsAdminState {
  final String message;
  TicketsAdminError(this.message);
}
