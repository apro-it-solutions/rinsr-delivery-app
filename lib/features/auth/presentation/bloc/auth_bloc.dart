import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/usecases/authenticate_with_backend.dart';
import '../../domain/usecases/login_with_phone.dart';
import '../../domain/usecases/verify_phone_otp.dart';
import 'auth_event.dart';
import 'auth_external_services.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  StreamSubscription<int>? _tickerSubscription;
  static const int _duration = 60;
  final LoginWithPhone loginWithPhone;
  final VerifyPhoneOtp verifyPhoneOtp;
  final AuthenticateWithBackend authenticateWithBackend;
  final AuthExternalServices externalServices;
  String? _verificationId;

  int _currentTimerValue = _duration;

  AuthBloc({
    required this.externalServices,
    required this.loginWithPhone,
    required this.verifyPhoneOtp,
    required this.authenticateWithBackend,
  }) : super(AuthInitial()) {
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthResendOtp>(_onResendOtp);
    on<AuthTimerTicked>(_onTimerTicked);
    on<NavigatedOtpScreenEvent>(_onNavigatedOtpScreenEvent);
    on<AuthErrorEvent>(_onAuthErrorEvent);
    on<AuthCodeSentEvent>(_onAuthCodeSentEvent);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginWithPhone(
      phoneNumber: event.phoneNumber,
      codeSent: (verificationId, resendToken) {
        add(
          AuthCodeSentEvent(
            verificationId: verificationId,
            resendToken: resendToken,
            phoneNumber: event.phoneNumber,
          ),
        );
      },
      verificationFailed: (message) {
        add(AuthErrorEvent(message));
      },
    );
    result.fold(
      (failure) {
        emit(ErrorSnackBarState(failure.message));
        emit(AuthError(failure.message));
      },
      (success) {
        // Wait for callbacks
      },
    );
  }

  FutureOr<void> _onAuthErrorEvent(
    AuthErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(ErrorSnackBarState(event.message));
    emit(AuthError(event.message));
  }

  FutureOr<void> _onAuthCodeSentEvent(
    AuthCodeSentEvent event,
    Emitter<AuthState> emit,
  ) {
    _verificationId = event.verificationId;
    _currentTimerValue = _duration;

    emit(NavigateOtpScreenState(phoneNumber: event.phoneNumber));
    emit(AuthOtpSent(timerValue: _duration, phoneNumber: event.phoneNumber));
    _startTimer();
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    if (_verificationId == null) {
      emit(
        const ErrorSnackBarState('Verification ID missing. Please resend OTP.'),
      );
      return;
    }

    emit(AuthLoading());
    final result = await verifyPhoneOtp(
      verificationId: _verificationId!,
      smsCode: event.otp,
    );
    await result.fold(
      (failure) {
        emit(ErrorSnackBarState(failure.message));
        emit(
          AuthOtpSent(
            timerValue: _currentTimerValue,
            phoneNumber: event.phoneNumber,
            errorMessage: failure.message,
          ),
        );
      },
      (success) async {
        final user = success.user;
        if (user == null) {
          emit(const ErrorSnackBarState('User not found'));
          return;
        }
        final idToken = await user.getIdToken();
        if (idToken == null) {
          emit(const ErrorSnackBarState('Failed to get ID Token'));
          return;
        }

        final backendResult = await authenticateWithBackend(idToken: idToken);
        await backendResult.fold(
          (failure) {
            emit(ErrorSnackBarState(failure.message));
            emit(
              AuthOtpSent(
                timerValue: _currentTimerValue,
                phoneNumber: event.phoneNumber,
                errorMessage: failure.message,
              ),
            );
          },
          (backendSuccess) async {
            if (backendSuccess.token?.isNotEmpty ?? false) {
              await externalServices.setString(
                AppConstants.kToken,
                backendSuccess.token!,
              );
            }
            await externalServices.setString(
              AppConstants.kAgentId,
              backendSuccess.deliveryPartner?.id ?? '',
            );
            await externalServices.registerVendor(
              backendSuccess.deliveryPartner?.id ?? '',
            );
            emit(AuthVerified(backendSuccess.message ?? ''));
            await _tickerSubscription?.cancel();
          },
        );
      },
    );
  }

  Future<void> _onResendOtp(
    AuthResendOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginWithPhone(
      phoneNumber: event.phoneNumber,
      codeSent: (verificationId, resendToken) {
        add(
          AuthCodeSentEvent(
            verificationId: verificationId,
            resendToken: resendToken,
            phoneNumber: event.phoneNumber,
          ),
        );
      },
      verificationFailed: (message) {
        add(AuthErrorEvent(message));
      },
    );
    result.fold(
      (failure) {
        emit(ErrorSnackBarState(failure.message));
        emit(AuthError(failure.message));
      },
      (success) {
        // Wait for callbacks
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
