import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SlideActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onSlideCompleted;
  final Color? color;
  final IconData? icon;
  final bool isEnabled;

  const SlideActionButton({
    super.key,
    required this.text,
    required this.onSlideCompleted,
    this.color,
    this.icon,
    this.isEnabled = true,
  });

  @override
  State<SlideActionButton> createState() => _SlideActionButtonState();
}

class _SlideActionButtonState extends State<SlideActionButton>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  final double _height = 56.0;
  final double _padding = 4.0;
  late double _maxWidth;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.color ?? AppColors.primary;
    final backgroundColor = widget.isEnabled
        ? primaryColor.withValues(alpha: 0.1)
        : Colors.grey.shade100;

    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;
        return Container(
          height: _height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_height / 2),
            border: Border.all(
              color: widget.isEnabled
                  ? primaryColor.withValues(alpha: 0.2)
                  : Colors.grey.shade300,
            ),
          ),
          child: Stack(
            children: [
              // Shimmer Text
              Center(
                child: Opacity(
                  opacity: 1 - (_dragValue / (_maxWidth - _height)),
                  child: Text(
                    widget.text,
                    style: AppTextStyles.textMediumfs16(context).copyWith(
                      color: widget.isEnabled
                          ? primaryColor
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Progress Bar (Background Fill)
              if (widget.isEnabled)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _dragValue + _height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(_height / 2),
                    ),
                  ),
                ),

              // Sliding Thumb
              Positioned(
                left: _dragValue,
                top: _padding,
                bottom: _padding,
                child: GestureDetector(
                  onHorizontalDragUpdate: widget.isEnabled
                      ? _onDragUpdate
                      : null,
                  onHorizontalDragEnd: widget.isEnabled ? _onDragEnd : null,
                  child: Container(
                    width: _height - (_padding * 2),
                    height: _height - (_padding * 2),
                    decoration: BoxDecoration(
                      color: widget.isEnabled ? primaryColor : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon ?? Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragValue = (_dragValue + details.delta.dx).clamp(
        0.0,
        _maxWidth - _height,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final threshold = _maxWidth - _height - _padding;
    if (_dragValue >= threshold) {
      widget.onSlideCompleted();
      // Snap back after completion (optional, or keep it there if loading)
      setState(() => _dragValue = 0);
    } else {
      // Animation to snap back
      setState(() => _dragValue = 0);
    }
  }
}
