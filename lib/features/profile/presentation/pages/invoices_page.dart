import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/get_agent_entity.dart';
import '../widgets/invoices_section.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key, required this.invoices});

  final List<InvoiceEntity> invoices;

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
          'Invoices',
          style: AppTextStyles.textMediumfs18(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.headerTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorderColor),
          ),
          child: InvoicesSection(invoices: invoices),
        ),
      ),
    );
  }
}
