import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/request/register_request.dart';

abstract class RegisterActions extends Equatable{
  RegisterActions();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterActions{
  final RegisterRequest request;
  final XFile image;
  final XFile carteScolaire;
  final XFile cin;

  RegisterSubmitted({
    required this.request,
    required this.image,
    required this.carteScolaire,
    required this.cin,
  });

  @override
  List<Object?> get props => [request,image,carteScolaire,cin];

}