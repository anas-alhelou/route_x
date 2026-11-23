import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';

class OtpBloc extends Bloc<dynamic, dynamic> {
  final AuthRepository repository;
  OtpBloc(this.repository) : super(null);
}