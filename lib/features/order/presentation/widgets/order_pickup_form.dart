import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../home/domain/entities/get_orders_entity.dart';
import '../bloc/order_bloc.dart';
import '../pages/barcode_scanner_screen.dart';
import 'order_itemized_list.dart';

class OrderPickupForm extends StatefulWidget {
  final OrderDetailsEntity order;
  final void Function(String photoPath, String weight, String barcode)
  onSubmitted;

  const OrderPickupForm({
    super.key,
    required this.order,
    required this.onSubmitted,
  });

  @override
  State<OrderPickupForm> createState() => _OrderPickupFormState();
}

class _OrderPickupFormState extends State<OrderPickupForm> {
  final ImagePicker picker = ImagePicker();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _pieceCountController = TextEditingController();
  XFile? photo;
  String? _pieceCountError;

  bool get _isPerPiece => widget.order.isPerPiece;

  @override
  void dispose() {
    _weightController.dispose();
    _pieceCountController.dispose();
    if (!_isPerPiece) {
      context.read<OrderBloc>().add(StopWeightReading());
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!_isPerPiece) {
      context.read<OrderBloc>().add(StartWeightReading());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Photo Section
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
          child: photo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
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
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Retake',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to open camera',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 24),

        // 2. Pricing-specific verification section.
        if (_isPerPiece) _buildPieceCountSection(context),
        if (!_isPerPiece) _buildWeightSection(context),

        const SizedBox(height: 24),

        // 3. Scan & Submit Button
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (photo == null) {
                AppAlerts.showErrorSnackBar(
                  context: context,
                  message: 'Please take a photo of the clothes',
                );
                return;
              }

              final String submitValue;
              if (_isPerPiece) {
                final countText = _pieceCountController.text.trim();
                final error = _validatePieceCount(countText);
                if (error != null) {
                  setState(() => _pieceCountError = error);
                  AppAlerts.showErrorSnackBar(
                    context: context,
                    message: error,
                  );
                  return;
                }
                submitValue = countText;
              } else {
                final weightText = _weightController.text.trim();
                if (weightText.isEmpty) {
                  AppAlerts.showErrorSnackBar(
                    context: context,
                    message: 'Please enter weight',
                  );
                  return;
                }
                submitValue = weightText;
              }

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerScreen(),
                ),
              );

              if (result != null) {
                widget.onSubmitted(photo!.path, submitValue, result.toString());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner, size: 24),
            label: const Text(
              'Scan QR Code & Finish',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  String? _validatePieceCount(String input) {
    if (input.isEmpty) return 'Please enter the total piece count';
    final parsed = int.tryParse(input);
    if (parsed == null) return 'Piece count must be a whole number';
    if (parsed <= 0) return 'Piece count must be greater than zero';
    return null;
  }

  Widget _buildPieceCountSection(BuildContext context) {
    final expectedPieces = widget.order.aggregatePieceCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderItemizedList(
          services: widget.order.services,
          fallbackItems: widget.order.selectedClothingItems,
          collapsible: true,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.checkroom_outlined,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Confirm piece count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  expectedPieces > 0
                      ? 'Expected: $expectedPieces. Count the bag and enter the actual number of pieces received.'
                      : 'Count the bag and enter the actual number of pieces received.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.smallTextStyle(
                    context,
                  ).copyWith(color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pieceCountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    if (_pieceCountError != null) {
                      setState(() => _pieceCountError = null);
                    }
                  },
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Total pieces',
                    labelStyle: const TextStyle(color: AppColors.primary),
                    hintText: '0',
                    errorText: _pieceCountError,
                    prefixIcon: const Icon(Icons.format_list_numbered),
                    suffixText: 'pcs',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightSection(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded &&
            state.weight != null &&
            !state.isWeightLocked) {
          _weightController.text = state.weight!.toStringAsFixed(2);
        }
      },
      builder: (context, state) {
        final isLocked = state is OrderLoaded && state.isWeightLocked;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.scale_outlined,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Weight Verification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the weight of the laundry bag before scanning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _weightController,
                  readOnly: isLocked,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    labelStyle: const TextStyle(color: AppColors.primary),
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLocked)
                          IconButton(
                            onPressed: () {
                              context.read<OrderBloc>().add(
                                UnlockWeightReading(),
                              );
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.orange,
                            ),
                            tooltip: 'Retry',
                          ),
                        IconButton(
                          onPressed: () {
                            if (!isLocked) {
                              context.read<OrderBloc>().add(
                                LockWeightReading(),
                              );
                            }
                          },
                          icon: Icon(
                            isLocked ? Icons.lock : Icons.lock_open,
                            color: isLocked ? Colors.green : Colors.grey,
                          ),
                          tooltip: isLocked ? 'Locked' : 'Lock Weight',
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0, left: 4),
                          child: Text(
                            'kg',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
