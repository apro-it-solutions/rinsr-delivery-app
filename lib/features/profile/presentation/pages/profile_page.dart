import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../../../auth/presentation/auth_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alerts.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/personal_info_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final id = SharedPreferencesService.getString(AppConstants.kAgentId);
    if (id != null) {
      context.read<ProfileBloc>().add(GetAgentDetailsEvent(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceController = TextEditingController();
    final companyNameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneNumberController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.lightBorderColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff374151)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.textMediumfs18(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.headerTextColor,
          ),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) => current is ProfileActionState,
        buildWhen: (previous, current) => current is! ProfileActionState,
        listener: (context, state) {
          if (state is LogoutState) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AuthRouter.login,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileErrorState) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileDetailsLoadedState) {
            final userDetails = state.agentEntity;

            // Only update controllers if they're empty or if we have new data
            if (companyNameController.text.isEmpty) {
              companyNameController.text =
                  userDetails.deliveryPartner?.companyName ?? '';
            }
            if (serviceController.text.isEmpty) {
              serviceController.text =
                  userDetails.deliveryPartner?.services?.join(', ') ?? '';
            }
            if (addressController.text.isEmpty) {
              addressController.text =
                  userDetails.deliveryPartner?.location ?? '';
            }
            if (phoneNumberController.text.isEmpty) {
              phoneNumberController.text =
                  userDetails.deliveryPartner?.phoneNumber ?? '';
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    PersonalInfoSection(
                      serviceController: serviceController,
                      companyNameController: companyNameController,
                      addressController: addressController,
                      phoneNumberController: phoneNumberController,
                    ),
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: () {
                        AppAlerts.showWarningDialog(
                          context: context,
                          message: 'Are you sure you want to logout?',
                          onConfirm: () {
                            SharedPreferencesService.remove(
                              AppConstants.kToken,
                            );
                            SharedPreferencesService.remove(
                              AppConstants.kAgentId,
                            );
                            context.read<ProfileBloc>().add(LogoutEvent());
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [AppDecoration.commonShadow],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBorderColor),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppIcons.logoutIcon),
                            const SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: AppTextStyles.mediumTextStyle(
                                context,
                              ).copyWith(color: const Color(0xffF80000)),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.inactiveGreyColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}
