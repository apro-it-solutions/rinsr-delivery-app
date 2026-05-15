import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../auth/presentation/auth_router.dart';
import '../../domain/entities/get_agent_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/ratings_bloc.dart';
import '../widgets/online_status_toggle.dart';
import '../widgets/payout_summary_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_nav_tile.dart';
import '../widgets/profile_section_card.dart';
import 'daily_history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhoto = false;
  String? _pendingPhotoPath;
  late final RatingsBloc _ratingsBloc;

  @override
  void initState() {
    super.initState();
    _ratingsBloc = sl<RatingsBloc>();
    final id = SharedPreferencesService.getString(AppConstants.kAgentId);
    if (id != null) {
      context.read<ProfileBloc>().add(GetAgentDetailsEvent(id));
      _ratingsBloc.add(FetchRatingsEvent(partnerId: id));
    }
  }

  @override
  void dispose() {
    _ratingsBloc.close();
    super.dispose();
  }

  void _refresh() {
    final id = SharedPreferencesService.getString(AppConstants.kAgentId);
    if (id != null) {
      context.read<ProfileBloc>().add(GetAgentDetailsEvent(id));
      _ratingsBloc.add(FetchRatingsEvent(partnerId: id));
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto) return;
    final source = await _showPhotoSourceSheet();
    if (source == null) return;
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return;
    setState(() {
      _pendingPhotoPath = picked.path;
      _isUploadingPhoto = true;
    });
    if (!mounted) return;
    context.read<ProfileBloc>().add(
      UpdateProfileImageEvent(filePath: picked.path),
    );
  }

  Future<ImageSource?> _showPhotoSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Text(
                        'Update profile photo',
                        style: AppTextStyles.textMediumfs16(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.headerTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  String _humanize(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    return raw
        .split(RegExp(r'[_\s]'))
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.lightBorderColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff374151)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.textMediumfs18(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.headerTextColor,
          ),
        ),
      ),
      body: BlocProvider<RatingsBloc>.value(
        value: _ratingsBloc,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) => current is ProfileActionState,
          buildWhen: (previous, current) => current is! ProfileActionState,
          listener: (context, state) {
            if (state is LogoutState) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AuthRouter.login,
                (route) => false,
              );
            } else if (state is ToggleActiveSuccessState) {
              AppAlerts.showSuccessSnackBar(
                context: context,
                message: state.message,
              );
            } else if (state is ToggleActiveErrorState) {
              AppAlerts.showErrorSnackBar(
                context: context,
                message: state.message,
              );
            } else if (state is UpdateProfileImageSuccessState) {
              setState(() {
                _isUploadingPhoto = false;
                _pendingPhotoPath = null;
              });
              AppAlerts.showSuccessSnackBar(
                context: context,
                message: state.message,
              );
            } else if (state is UpdateProfileImageErrorState) {
              setState(() {
                _isUploadingPhoto = false;
                _pendingPhotoPath = null;
              });
              AppAlerts.showErrorSnackBar(
                context: context,
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileErrorState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 36,
                        color: AppColors.inactiveGreyColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mediumTextStyle(
                          context,
                        ).copyWith(color: AppColors.greyTextColor),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is ProfileDetailsLoadedState) {
              final data = state.agentEntity.data;
              if (data == null) {
                return const Center(child: Text('No data'));
              }
              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (data.basicInfo != null)
                        BlocBuilder<RatingsBloc, RatingsState>(
                          builder: (context, ratingsState) {
                            num? avg;
                            int? count;
                            final isLoading =
                                ratingsState is RatingsLoadingState ||
                                ratingsState is RatingsInitial;
                            if (ratingsState is RatingsLoadedState) {
                              final partner =
                                  ratingsState.ratings.deliveryPartner;
                              avg = partner?.avgRating;
                              count =
                                  partner?.ratingCount ??
                                  ratingsState.ratings.total ??
                                  ratingsState.ratings.ratings.length;
                            }
                            return ProfileHeader(
                              basicInfo: data.basicInfo!,
                              onEditPhoto: _pickAndUploadPhoto,
                              isUploadingPhoto: _isUploadingPhoto,
                              pendingPhotoPath: _pendingPhotoPath,
                              avgRating: avg,
                              ratingCount: count,
                              isLoadingRating: isLoading,
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      OnlineStatusToggle(
                        isActive: data.basicInfo?.isActive ?? false,
                      ),
                      const SizedBox(height: 16),
                      if (data.payoutDetails != null)
                        PayoutSummarySection(payout: data.payoutDetails!),
                      const SizedBox(height: 16),
                      if (data.basicInfo != null)
                        _buildBasicInfoCard(data.basicInfo!),
                      const SizedBox(height: 16),
                      if (data.basicInfo?.vehicleDetails != null)
                        _buildVehicleCard(
                          data.basicInfo!.vehicleDetails!,
                          data.basicInfo!.vehicleType,
                        ),
                      const SizedBox(height: 16),
                      if (data.payoutDetails?.bankDetails != null)
                        _buildBankCard(data.payoutDetails!.bankDetails!),
                      const SizedBox(height: 16),
                      ProfileNavTile(
                        title: 'Daily History',
                        icon: Icons.history,
                        subtitle:
                            '${(data.dailyHistory ?? const []).length} day(s)',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DailyHistoryPage(
                              history: data.dailyHistory ?? const [],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildLogoutTile(context),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('No data'));
          },
        ),
      ),
    );

  }

  Widget _buildBasicInfoCard(BasicInfoEntity info) {
    return ProfileSectionCard(
      title: 'Basic Information',
      icon: Icons.person_outline,
      child: Column(
        children: [
          InfoRow(label: 'Full name', value: info.fullName ?? '—'),
          InfoRow(label: 'Phone', value: info.phoneNumber ?? '—'),
          InfoRow(label: 'Address', value: info.currentAddress ?? '—'),
          InfoRow(label: 'Availability', value: _humanize(info.availability)),
          InfoRow(
            label: 'Zone',
            value: (info.preferredZones == null || info.preferredZones!.isEmpty)
                ? '—'
                : info.preferredZones!.join(', '),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleDetailsEntity vehicle, String? type) {
    final make = vehicle.make ?? '';
    final model = vehicle.model ?? '';
    final fullName = [make, model].where((s) => s.isNotEmpty).join(' ');
    return ProfileSectionCard(
      title: 'Vehicle Details',
      icon: Icons.two_wheeler_outlined,
      child: Column(
        children: [
          InfoRow(label: 'Vehicle', value: fullName.isEmpty ? '—' : fullName),
          InfoRow(label: 'Type', value: _humanize(type)),
          InfoRow(
            label: 'Registration',
            value: vehicle.registrationNumber ?? '—',
          ),
          InfoRow(label: 'Year', value: vehicle.year ?? '—'),
        ],
      ),
    );
  }

  Widget _buildBankCard(BankDetailsEntity bank) {
    final masked = bank.accountLast4 == null
        ? '—'
        : '•••• •••• ${bank.accountLast4}';
    return ProfileSectionCard(
      title: 'Bank Details',
      icon: Icons.account_balance_outlined,
      child: Column(
        children: [
          InfoRow(label: 'Account holder', value: bank.accountName ?? '—'),
          InfoRow(label: 'Bank', value: bank.bankName ?? '—'),
          InfoRow(label: 'IFSC', value: bank.ifscCode ?? '—'),
          InfoRow(label: 'Account no.', value: masked),
        ],
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppAlerts.showWarningDialog(
          context: context,
          message: 'Are you sure you want to logout?',
          onConfirm: () {
            SharedPreferencesService.remove(AppConstants.kToken);
            SharedPreferencesService.remove(AppConstants.kAgentId);
            context.read<ProfileBloc>().add(LogoutEvent());
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
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
    );
  }
}
