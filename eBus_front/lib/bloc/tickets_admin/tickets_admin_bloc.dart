import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/tickets_admin/tickets_admin_event.dart';
import 'package:smart_bus/bloc/tickets_admin/tickets_admin_state.dart';
import 'package:smart_bus/services/ticket_service.dart';

class TicketsAdminBloc extends Bloc<TicketsAdminEvent, TicketsAdminState> {
  final TicketService ticketService;

  TicketsAdminBloc({required this.ticketService}) : super(TicketsAdminInitial()) {
    on<FetchTicketsAdminData>((event, emit) async {
      emit(TicketsAdminLoading());
      try {
        final tickets = await ticketService.getTickets();
        final abonnements = await ticketService.getTypeAbonnements();
        emit(TicketsAdminLoaded(tickets: tickets, abonnements: abonnements));
      } catch (e) {
        emit(TicketsAdminError(e.toString()));
      }
    });
  }
}
