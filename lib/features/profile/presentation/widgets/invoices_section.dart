import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/file_downloader.dart';
import '../../domain/entities/get_agent_entity.dart';

class InvoicesSection extends StatelessWidget {
  const InvoicesSection({super.key, required this.invoices});

  final List<InvoiceEntity> invoices;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No invoices yet',
      );
    }
    return Column(
      children: [
        for (var i = 0; i < invoices.length; i++) ...[
          _InvoiceTile(invoice: invoices[i]),
          if (i != invoices.length - 1)
            const Divider(height: 14, color: AppColors.lightBorderColor),
        ],
      ],
    );
  }
}

class _InvoiceTile extends StatefulWidget {
  const _InvoiceTile({required this.invoice});
  final InvoiceEntity invoice;

  @override
  State<_InvoiceTile> createState() => _InvoiceTileState();
}

class _InvoiceTileState extends State<_InvoiceTile> {
  bool _downloading = false;
  double _progress = 0;

  String _money() {
    final value = (widget.invoice.amount ?? 0).toDouble();
    final currency = widget.invoice.currency ?? 'INR';
    final symbol = currency == 'INR' ? '₹' : '$currency ';
    return '$symbol${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  Future<void> _download() async {
    final url = widget.invoice.pdfUrl ?? widget.invoice.downloadUrl;
    if (url == null || url.isEmpty) {
      AppAlerts.showErrorSnackBar(
        context: context,
        message: 'No download link available',
      );
      return;
    }

    setState(() {
      _downloading = true;
      _progress = 0;
    });

    final fileName =
        widget.invoice.receiptNumber ??
        'invoice_${DateTime.now().millisecondsSinceEpoch}';

    final result = await FileDownloader.downloadAndOpenPdf(
      url: url,
      fileName: fileName,
      onProgress: (received, total) {
        if (!mounted || total <= 0) return;
        setState(() => _progress = received / total);
      },
    );

    if (!mounted) return;
    setState(() {
      _downloading = false;
      _progress = 0;
    });

    if (result.success) {
      AppAlerts.showSuccessSnackBar(
        context: context,
        message: 'Saved to ${result.path ?? 'Downloads'}',
      );
    } else {
      AppAlerts.showErrorSnackBar(
        context: context,
        message: result.errorMessage ?? 'Download failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _downloading ? null : _download,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.invoice.receiptNumber ?? 'Receipt',
                        style: AppTextStyles.mediumTextStyle(context).copyWith(
                          color: AppColors.headerTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (widget.invoice.periodDate != null)
                            widget.invoice.periodDate!,
                          if (widget.invoice.paymentMode != null)
                            widget.invoice.paymentMode!,
                        ].join(' · '),
                        style: AppTextStyles.smallTextStyle(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(),
                      style: AppTextStyles.mediumTextStyle(context).copyWith(
                        color: AppColors.headerTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _downloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(
                            Icons.download_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                  ],
                ),
              ],
            ),
            if (_downloading) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress,
                  minHeight: 3,
                  backgroundColor: AppColors.lightBorderColor,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: AppColors.inactiveGreyColor, size: 28),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.smallTextStyle(context).copyWith(
                color: AppColors.greyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
