import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import 'package:routex_mobile/core/services/local/media/image_picker_service.dart';
import 'package:routex_mobile/features/auth/domain/entities/register_params.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/usecases/pick_profile_image_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/validate_signup_step1_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/validate_signup_step3_usecase.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';

class _Repo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Picker implements ImagePickerService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Answers each registration call with the next scripted result.
class _ScriptedRegister extends RegisterUseCase {
  _ScriptedRegister(this._results) : super(repository: _Repo());

  final List<Either<Failure, void>> _results;

  @override
  Future<Either<Failure, void>> call(RegisterParams params) async =>
      _results.removeAt(0);
}

const _exists = ServerFailure('User with this email or phone number already exists.');

SignupBloc _bloc(List<Either<Failure, void>> results) {
  final bloc = SignupBloc(
    validateStep1UseCase: ValidateSignupStep1UseCase(repository: _Repo()),
    pickProfileImageUseCase: PickProfileImageUseCase(
      imagePickerService: _Picker(),
    ),
    validateStep3UseCase: const ValidateSignupStep3UseCase(),
    registerUseCase: _ScriptedRegister(results),
  );
  // ignore: invalid_use_of_protected_member
  bloc.emit(
    SignupState.initial().copyWith(
      firstName: 'Test',
      lastName: 'Driver',
      email: 'qa@example.com',
      phone: '+970591234567',
      phoneCountryIsoCode: 'PS',
      countryName: 'Palestine',
    ),
  );
  return bloc;
}

Future<SignupState> _submit(SignupBloc bloc) {
  final done = bloc.stream.firstWhere(
    (s) =>
        s.status == SignupStatus.registered ||
        s.status == SignupStatus.failure,
  );
  bloc.add(const SignupStep2Submitted(password: 'Passw0rd!'));
  return done;
}

void main() {
  test('"already exists" right after a timeout continues to the code screen', () async {
    final bloc = _bloc([
      const Left(NetworkFailure(ExceptionMapper.requestTimeoutKey)),
      const Left(_exists),
    ]);

    expect((await _submit(bloc)).status, SignupStatus.failure);
    expect((await _submit(bloc)).status, SignupStatus.registered);
    await bloc.close();
  });

  test('"already exists" without a prior timeout stays an error', () async {
    final bloc = _bloc([const Left(_exists)]);

    final state = await _submit(bloc);
    expect(state.status, SignupStatus.failure);
    expect(state.errorMessage, contains('already exists'));
    await bloc.close();
  });

  test('a timeout for one email does not excuse another', () async {
    final bloc = _bloc([
      const Left(NetworkFailure(ExceptionMapper.requestTimeoutKey)),
      const Left(_exists),
    ]);

    await _submit(bloc);
    // ignore: invalid_use_of_protected_member
    bloc.emit(bloc.state.copyWith(email: 'other@example.com'));
    expect((await _submit(bloc)).status, SignupStatus.failure);
    await bloc.close();
  });
}
