import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/widgets/continue_button.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';

class OrderPickupForm extends StatefulWidget {
  final VoidCallback onSubmitted;

  const OrderPickupForm({super.key, required this.onSubmitted});

  @override
  State<OrderPickupForm> createState() => _OrderPickupFormState();
}

class _OrderPickupFormState extends State<OrderPickupForm> {
  final ImagePicker picker = ImagePicker();
  XFile? photo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Details',
          style: AppTextStyles.mediumTextStyle(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            if (photo == null) {
              final XFile? image = await picker.pickImage(
                source: ImageSource.camera,
              );
              if (image != null) {
                setState(() {
                  photo = image;
                });
              }
            } else {
              // If a photo exists, tapping the main area views it
              // We'll add a specific retake button inside the image display
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog.fullscreen(
                    backgroundColor: Colors.black,
                    child: Stack(
                      children: [
                        Center(
                          child: Image.file(
                            File(photo!.path),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 16,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
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
                            child: InkWell(
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
                              borderRadius: BorderRadius.circular(20),
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
                                      style:
                                          AppTextStyles.smallTextStyle(
                                            context,
                                          ).copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
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
                            'Take Photo of Clothes',
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
        ContinueButton(
          text: 'Submit Details',
          onPressed: () {
            if (photo != null) {
              context.read<OrderBloc>().add(
                SubmitPickupDetails(photoPath: photo!.path),
              );
              widget.onSubmitted();
            } else {
              AppAlerts.showErrorSnackBar(
                context: context,
                message: 'Please enter weight and take a photo',
              );
            }
          },
        ),
      ],
    );
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
