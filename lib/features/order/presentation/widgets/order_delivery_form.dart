import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/widgets/continue_button.dart';
import '../../../home/domain/entities/get_orders_entity.dart';
import '../../../home/presentation/bloc/home_bloc.dart'; // Added
import '../../../../core/constants/constants.dart'; // Added
import '../../../../core/services/shared_preferences_service.dart'; // Added
import '../bloc/order_bloc.dart';
import 'order_info_card.dart';
import 'order_itemized_list.dart';

class OrderDeliveryForm extends StatefulWidget {
  final OrderDetailsEntity order;
  final VoidCallback onActionTap;

  const OrderDeliveryForm({
    super.key,
    required this.order,
    required this.onActionTap,
  });

  @override
  State<OrderDeliveryForm> createState() => _OrderDeliveryFormState();
}

class _OrderDeliveryFormState extends State<OrderDeliveryForm> {
  final ImagePicker picker = ImagePicker();
  XFile? photo;
  Timer? _paymentPollTimer;

  bool get _isPaid => widget.order.paymentStatus == 'paid';

  @override
  void initState() {
    super.initState();
    if (!_isPaid) {
      if (widget.order.isPayOnDelivery) {
        context.read<OrderBloc>().add(const LoadPaymentQr());
      }
      // Poll so the Confirm Delivery gate opens on its own once the customer
      // pays — the agent shouldn't have to keep tapping "Check Payment Status".
      _paymentPollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        if (!mounted || _isPaid) {
          _paymentPollTimer?.cancel();
          return;
        }
        if (!_isCheckingPayment) _checkPaymentStatus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant OrderDeliveryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isPaid) _paymentPollTimer?.cancel();
  }

  @override
  void dispose() {
    _paymentPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderInfoCard(
          title: 'Deliver To',
          content: widget.order.userAddress,
          icon: Icons.person_pin_circle,
          onActionTap: widget.onActionTap,
        ),
        if (widget.order.isPerPiece) ...[
          const SizedBox(height: 16),
          OrderItemizedList(
            services: widget.order.services,
            fallbackItems: widget.order.selectedClothingItems,
            collapsible: true,
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Proof of Delivery',
          style: AppTextStyles.mediumTextStyle(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final XFile? image = await picker.pickImage(
              source: ImageSource.camera,
            );
            if (image != null) {
              setState(() {
                photo = image;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: _DashedRectPainter(
              color: AppColors.primaryGreyColor,
              strokeWidth: 1.5,
              gap: 4,
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              child: photo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(photo!.path), fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Retake',
                                    style: AppTextStyles.smallTextStyle(context)
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Take Photo at Doorstep',
                            style: AppTextStyles.mediumTextStyle(context)
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greyTextColor,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to open camera',
                            style: AppTextStyles.smallTextStyle(context),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (widget.order.paymentStatus != 'paid') ...[
          if (widget.order.isPayOnDelivery) ...[
            _buildPaymentQrCard(context),
            const SizedBox(height: 16),
          ],
          Center(
            child: TextButton.icon(
              onPressed: _isCheckingPayment ? null : _checkPaymentStatus,
              icon: _isCheckingPayment
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                _isCheckingPayment
                    ? 'Checking Status...'
                    : 'Check Payment Status',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _confirmMarkCashReceived(context),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Mark Cash Payment Received'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Confirm Delivery unlocks once payment is received',
                style: AppTextStyles.smallTextStyle(
                  context,
                ).copyWith(color: AppColors.greyTextColor),
              ),
            ),
          ),
        ],
        ContinueButton(
          text: 'Confirm Delivery',
          // Gate hard on payment (client issue #21): the button stays disabled
          // until payment_status flips to 'paid' (auto-polled above).
          onPressed: _isPaid
              ? () {
                  if (photo != null) {
                    context.read<OrderBloc>().add(
                      SubmitProofOfDelivery(photoPath: photo!.path),
                    );
                  } else {
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: _errorMessage('photo'),
                    );
                  }
                }
              : null,
        ),
      ],
    );
  }

  bool _isCheckingPayment = false;

  /// Pay-On-Delivery QR (client issue #9): the customer scans this to pay;
  /// the poll in [initState] flips the Confirm Delivery gate once paid.
  Widget _buildPaymentQrCard(BuildContext context) {
    final amount =
        widget.order.estimateTotalPrice ?? widget.order.totalPrice ?? 0;
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous is! OrderLoaded ||
          current is! OrderLoaded ||
          previous.paymentQr != current.paymentQr ||
          previous.isPaymentQrLoading != current.isPaymentQrLoading ||
          previous.paymentQrError != current.paymentQrError,
      builder: (context, state) {
        final loaded = state is OrderLoaded ? state : null;
        final qr = loaded?.paymentQr;
        final displayAmount = qr?.amount ?? amount;

        Widget body;
        if (loaded?.isPaymentQrLoading ?? false) {
          body = const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (qr != null && qr.qrString != null) {
          body = Center(
            child: QrImageView(
              data: qr.qrString!,
              size: 200,
              backgroundColor: Colors.white,
            ),
          );
        } else if (qr != null && qr.qrImageUrl != null) {
          body = Center(
            child: Image.network(
              qr.qrImageUrl!,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  _qrErrorBody(context),
            ),
          );
        } else {
          body = _qrErrorBody(
            context,
            message: loaded?.paymentQrError,
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(
                'Collect Payment • ₹$displayAmount',
                style: AppTextStyles.mediumTextStyle(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Ask the customer to scan & pay. Status updates automatically.',
                textAlign: TextAlign.center,
                style: AppTextStyles.smallTextStyle(context),
              ),
              const SizedBox(height: 12),
              body,
            ],
          ),
        );
      },
    );
  }

  Widget _qrErrorBody(BuildContext context, {String? message}) {
    return Column(
      children: [
        const Icon(Icons.qr_code_2, size: 48, color: AppColors.greyTextColor),
        const SizedBox(height: 8),
        Text(
          message ?? 'Payment QR unavailable. Retry, or collect cash.',
          textAlign: TextAlign.center,
          style: AppTextStyles.smallTextStyle(context),
        ),
        TextButton.icon(
          onPressed: () => context.read<OrderBloc>().add(
            const LoadPaymentQr(forceRefresh: true),
          ),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
        ),
      ],
    );
  }

  Future<void> _confirmMarkCashReceived(BuildContext context) async {
    final amount =
        widget.order.estimateTotalPrice ?? widget.order.totalPrice ?? 0;
    final orderBloc = context.read<OrderBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark Payment Received?'),
        content: Text(
          'Confirm that you collected ₹$amount in cash from the customer. '
          'This will mark the order as paid.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      orderBloc.add(MarkCashPaymentReceived());
    }
  }

  Future<void> _checkPaymentStatus() async {
    setState(() {
      _isCheckingPayment = true;
    });

    try {
      final agentId = SharedPreferencesService.getString(AppConstants.kAgentId);
      final homeBloc = context.read<HomeBloc>();

      // Trigger refresh
      homeBloc.add(GetOrdersEvent(agentId: agentId));

      // Wait for result
      final state = await homeBloc.stream.firstWhere(
        (element) => element is HomeError || element is HomeLoaded,
      );

      if (state is HomeLoaded && mounted) {
        try {
          final updatedOrder = state.allOrders.firstWhere(
            (element) => element.orderId == widget.order.orderId,
          );

          if (updatedOrder.paymentStatus == 'paid') {
            AppAlerts.showSuccessSnackBar(
              context: context,
              message: 'Payment verified successfully!',
            );
          }

          // Update OrderBloc
          context.read<OrderBloc>().add(OrderLoadEvent(order: updatedOrder));
        } catch (e) {
          // Order not found in list logic
        }
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPayment = false;
        });
      }
    }
  }

  String _errorMessage(String type) {
    switch (type) {
      case 'photo':
        return 'Please take a proof of delivery photo';
      case 'payment':
        return 'Please verify user payment for order';
      default:
        return 'please try again';
    }
  }
}

class _DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;

  _DashedRectPainter({
    this.strokeWidth = 1.0,
    this.color = Colors.black,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path topPath = getDashedPath(
      a: const Point(0, 0),
      b: Point(x, 0),
      gap: gap,
    );

    Path rightPath = getDashedPath(a: Point(x, 0), b: Point(x, y), gap: gap);

    Path bottomPath = getDashedPath(a: Point(0, y), b: Point(x, y), gap: gap);

    Path leftPath = getDashedPath(
      a: const Point(0, 0),
      b: Point(0, y),
      gap: gap,
    );

    canvas.drawPath(topPath, dashedPaint);
    canvas.drawPath(rightPath, dashedPaint);
    canvas.drawPath(bottomPath, dashedPaint);
    canvas.drawPath(leftPath, dashedPaint);
  }

  Path getDashedPath({
    required Point<double> a,
    required Point<double> b,
    required double gap,
  }) {
    Size size = Size(b.x - a.x, b.y - a.y);
    Path path = Path();
    path.moveTo(a.x, a.y);
    bool shouldDraw = true;
    Point<double> currentPoint = Point(a.x, a.y);

    num radians = atan2(b.y - a.y, b.x - a.x);
    num magnitude = sqrt(pow(size.width, 2) + pow(size.height, 2));

    double magnitudeCount = 0;

    while (magnitudeCount < magnitude) {
      if (shouldDraw) {
        path.lineTo(currentPoint.x, currentPoint.y);
      } else {
        path.moveTo(currentPoint.x, currentPoint.y);
      }
      shouldDraw = !shouldDraw;
      currentPoint = Point(
        currentPoint.x + cos(radians) * gap,
        currentPoint.y + sin(radians) * gap,
      );
      magnitudeCount += gap;
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
