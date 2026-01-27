import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../home/presentation/home_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthVerified) {
              // Navigate to home or next screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeRouter.home,
                (route) => false,
              );
            } else if (state is AuthError) {
              AppAlerts.showErrorSnackBar(
                context: context,
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            int timerValue = 0;
            if (state is AuthOtpSent) {
              timerValue = state.timerValue;
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h(context)),
                    Text(
                      'Verification Code',
                      style: AppTextStyles.textLargefs20(context).copyWith(
                        fontSize: 24.w(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h(context)),
                    Text.rich(
                      TextSpan(
                        text: 'We have sent the verification code to\n',
                        style: AppTextStyles.mediumTextStyle(
                          context,
                        ).copyWith(color: AppColors.greyText),
                        children: [
                          TextSpan(
                            text: widget.phoneNumber,
                            style: AppTextStyles.textMediumfs16(context)
                                .copyWith(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h(context)),
                    PinCodeTextField(
                      enabled: timerValue > 0,
                      autoDisposeControllers: false,
                      appContext: context,
                      length: 6,
                      obscureText: false,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 50.w(context),
                        fieldWidth: 45.w(context),
                        activeFillColor: AppColors.lightSurface,
                        inactiveFillColor: AppColors.lightSurface,
                        selectedFillColor: AppColors.lightSurface,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primaryBorderColor,
                        selectedColor: AppColors.primary,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      backgroundColor: Colors.transparent,
                      enableActiveFill: true,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      onCompleted: (v) {
                        context.read<AuthBloc>().add(
                          AuthVerifyOtp(
                            otp: v,
                            phoneNumber: widget.phoneNumber,
                          ),
                        );
                      },
                      onChanged: (value) {},
                      beforeTextPaste: (text) {
                        return true;
                      },
                    ),
                    SizedBox(height: 20.h(context)),
                    Center(
                      child: TextButton(
                        onPressed: timerValue <= 0
                            ? () {
                                context.read<AuthBloc>().add(
                                  AuthResendOtp(widget.phoneNumber),
                                );
                              }
                            : null,
                        child: Text(
                          timerValue > 0
                              ? 'Resend Code in ${_formatTimer(timerValue)}'
                              : 'Resend Code',
                          style: AppTextStyles.textMediumfs16(context).copyWith(
                            color: timerValue > 0
                                ? AppColors.greyText
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
