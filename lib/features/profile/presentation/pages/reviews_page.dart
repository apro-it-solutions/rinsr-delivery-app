import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/ratings_bloc.dart';
import '../widgets/review_widgets.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key, required this.partnerId});

  final String partnerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RatingsBloc>(
      create: (_) =>
          sl<RatingsBloc>()..add(FetchRatingsEvent(partnerId: partnerId)),
      child: _ReviewsView(partnerId: partnerId),
    );
  }
}

class _ReviewsView extends StatelessWidget {
  const _ReviewsView({required this.partnerId});

  final String partnerId;

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
          'Reviews',
          style: AppTextStyles.textMediumfs18(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.headerTextColor,
          ),
        ),
      ),
      body: BlocBuilder<RatingsBloc, RatingsState>(
        builder: (context, state) {
          if (state is RatingsLoadingState || state is RatingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RatingsErrorState) {
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
                      style: AppTextStyles.mediumTextStyle(context).copyWith(
                        color: AppColors.greyTextColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<RatingsBloc>()
                          .add(FetchRatingsEvent(partnerId: partnerId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is RatingsLoadedState) {
            final ratings = state.ratings;
            final partner = ratings.deliveryPartner;
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<RatingsBloc>()
                  .add(FetchRatingsEvent(partnerId: partnerId)),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (partner?.fullName != null &&
                        partner!.fullName!.isNotEmpty) ...[
                      Text(
                        partner.fullName!,
                        style: AppTextStyles.textMediumfs18(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.headerTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    RatingSummaryCard(
                      avgRating: partner?.avgRating,
                      total: partner?.ratingCount ??
                          ratings.total ??
                          ratings.ratings.length,
                    ),
                    const SizedBox(height: 16),
                    if (ratings.ratings.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'All reviews',
                          style: AppTextStyles.textMediumfs16(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headerTextColor,
                          ),
                        ),
                      ),
                    ],
                    if (ratings.ratings.isEmpty)
                      const EmptyReviews()
                    else
                      for (var i = 0; i < ratings.ratings.length; i++) ...[
                        ReviewTile(item: ratings.ratings[i]),
                        if (i != ratings.ratings.length - 1)
                          const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
