import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/resend_otp/resend_otp_request_entity.dart';
import '../../domain/entities/send_otp/send_otp_request_entity.dart';
import '../../domain/entities/verify_user/verify_user_request_entity.dart';
import '../../domain/usecases/resend_otp.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_event.dart';
import 'auth_external_services.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  StreamSubscription<int>? _tickerSubscription;
  static const int _duration = 60;
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final ResendOtp resendOtp;
  final AuthExternalServices externalServices;

  int _currentTimerValue = _duration;

  AuthBloc({
    required this.externalServices,
    required this.sendOtp,
    required this.verifyOtp,
    required this.resendOtp,
  }) : super(AuthInitial()) {
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthResendOtp>(_onResendOtp);
    on<AuthTimerTicked>(_onTimerTicked);
    on<NavigatedOtpScreenEvent>(_onNavigatedOtpScreenEvent);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await sendOtp(
      SendOtpRequestEntity(phone: event.phoneNumber),
    );
    result.fold(
      (failure) {
        emit(ErrorSnackBarState(failure.message));
        emit(AuthError(failure.message));
      },
      (success) {
        emit(NavigateOtpScreenState(phoneNumber: event.phoneNumber));
        _currentTimerValue = _duration;
        emit(
          AuthOtpSent(timerValue: _duration, phoneNumber: event.phoneNumber),
        );
        _startTimer();
      },
    );
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyOtp(
      VerifyOtpRequestEntity(phone: event.phoneNumber, otp: event.otp),
    );
    await result.fold(
      (failure) {
        emit(ErrorSnackBarState(failure.message));
        // Emit AuthOtpSent with error message to preserve UI state
        emit(
          AuthOtpSent(
            timerValue: _currentTimerValue,
            phoneNumber: event.phoneNumber,
            errorMessage: failure.message,
          ),
        );
      },
      (success) async {
        // Now do async work while still inside the handler
        if (success.token != null) {
          await externalServices.setString(AppConstants.kToken, success.token!);
        }

        await externalServices.setString(
          AppConstants.kAgentId,
          success.deliveryPartner?.id ?? '',
        );

        await externalServices.registerVendor(
          success.deliveryPartner?.id ?? '',
        );

        emit(AuthVerified(success.message ?? 'OTP Verified Successfully!'));
        await _tickerSubscription?.cancel();
      },
    );
  }

  Future<void> _onResendOtp(
    AuthResendOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resendOtp(
      ResendOtpRequestEntity(phone: event.phoneNumber),
    );
    result.fold(
      (failure) {
        emit(ErrorSnackBarState(failure.message));
        emit(AuthError(failure.message));
      },
      (success) {
        _currentTimerValue = _duration;
        emit(
          AuthOtpSent(timerValue: _duration, phoneNumber: event.phoneNumber),
        );
        _startTimer();
      },
    );
  }

  void _onTimerTicked(AuthTimerTicked event, Emitter<AuthState> emit) {
    _currentTimerValue = event.duration;
    if (state is AuthOtpSent) {
      final currentState = state as AuthOtpSent;
      emit(
        AuthOtpSent(
          timerValue: event.duration,
          phoneNumber: currentState.phoneNumber,
          errorMessage: null,
        ),
      );
    } else if (state is AuthLoading) {
      // If loading, we update _currentTimerValue but don't emit state yet
      // to avoid interrupting the loading indicator.
    }
  }

  void _startTimer() {
    _tickerSubscription?.cancel();
    _tickerSubscription =
        Stream.periodic(
          const Duration(seconds: 1),
          (x) => _duration - x - 1,
        ).take(_duration + 1).listen((duration) {
          add(AuthTimerTicked(duration));
        });
  }

  FutureOr<void> _onNavigatedOtpScreenEvent(
    NavigatedOtpScreenEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(NavigateOtpScreenState(phoneNumber: event.phoneNumber));
  }
}
