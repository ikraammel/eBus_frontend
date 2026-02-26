import 'package:equatable/equatable.dart';

abstract class LigneEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class LoadLignes extends LigneEvent {}

class SearchLignes extends LigneEvent{
  final String query;
  SearchLignes(this.query);

  @override
  List<Object?> get props => [query];
}

