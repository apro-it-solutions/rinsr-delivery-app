import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/widgets/continue_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      buildWhen: (previous, current) => current is! AuthActionState,
      listenWhen: (previous, current) => current is AuthActionState,
      listener: (context, state) {
        if (state is NavigateOtpScreenState) {
          Navigator.pushNamed(
            context,
            AuthRouter.otp,
            arguments: state.phoneNumber,
          );
        } else if (state is ErrorSnackBarState) {
          AppAlerts.showErrorSnackBar(context: context, message: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h(context)),
                    Center(
                      child: Container(
                        width: 80.w(context),
                        height: 80.w(context),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_shipping_outlined,
                          size: 40.w(context),
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h(context)),
                    Text(
                      'Welcome!',
                      style: AppTextStyles.textLargefs20(context).copyWith(
                        fontSize: 24.w(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      'Login to continue managing your deliveries',
                      style: AppTextStyles.mediumTextStyle(
                        context,
                      ).copyWith(color: AppColors.greyText),
                    ),
                    SizedBox(height: 32.h(context)),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      prefixIcon: Icons.phone_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    ContinueButton(
                      text: state is AuthLoading ? 'Sending...' : 'Send OTP',
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  AuthSendOtp(_phoneController.text),
                                );
                              }
                            },
                    ),
                    SizedBox(height: 20.h(context)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
