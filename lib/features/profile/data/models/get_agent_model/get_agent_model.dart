import '../../../domain/entities/get_agent_entity.dart';

class GetAgentModel extends GetAgentEntity {
  const GetAgentModel({super.success, super.data});

  factory GetAgentModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    return GetAgentModel(
      success: json['success'] as bool?,
      data: dataJson is Map<String, dynamic>
          ? ProfileDataModel.fromJson(dataJson)
          : null,
    );
  }
}

class ProfileDataModel extends ProfileDataEntity {
  const ProfileDataModel({
    super.basicInfo,
    super.payoutDetails,
    super.dailyHistory,
    super.invoices,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    final basic = json['basic_info'];
    final payout = json['payout_details'];
    final history = json['daily_history'];
    final invoiceList = json['invoices'];

    return ProfileDataModel(
      basicInfo: basic is Map<String, dynamic>
          ? BasicInfoModel.fromJson(basic)
          : null,
      payoutDetails: payout is Map<String, dynamic>
          ? PayoutDetailsModel.fromJson(payout)
          : null,
      dailyHistory: history is List
          ? history
                .whereType<Map<String, dynamic>>()
                .map(DailyHistoryModel.fromJson)
                .toList()
          : null,
      invoices: invoiceList is List
          ? invoiceList
                .whereType<Map<String, dynamic>>()
                .map(InvoiceModel.fromJson)
                .toList()
          : null,
    );
  }
}

class BasicInfoModel extends BasicInfoEntity {
  const BasicInfoModel({
    super.id,
    super.fullName,
    super.phoneNumber,
    super.photo,
    super.currentAddress,
    super.vehicleType,
    super.vehicleDetails,
    super.availability,
    super.preferredZones,
    super.status,
    super.isActive,
    super.memberSince,
  });

  factory BasicInfoModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle_details'];
    final zones = json['preferred_zones'];
    final memberSinceRaw = json['member_since'];
    return BasicInfoModel(
      id: json['id'] as String?,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      photo: json['photo'] as String?,
      currentAddress: json['current_address'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleDetails: vehicle is Map<String, dynamic>
          ? VehicleDetailsModel.fromJson(vehicle)
          : null,
      availability: json['availability'] as String?,
      preferredZones: zones is List
          ? zones.map((e) => e.toString()).toList()
          : null,
      status: json['status'] as String?,
      isActive: json['is_active'] as bool?,
      memberSince: memberSinceRaw is String
          ? DateTime.tryParse(memberSinceRaw)
          : null,
    );
  }
}

class VehicleDetailsModel extends VehicleDetailsEntity {
  const VehicleDetailsModel({
    super.make,
    super.model,
    super.registrationNumber,
    super.year,
  });

  factory VehicleDetailsModel.fromJson(Map<String, dynamic> json) {
    return VehicleDetailsModel(
      make: json['make'] as String?,
      model: json['model'] as String?,
      registrationNumber: json['registration_number'] as String?,
      year: json['year']?.toString(),
    );
  }
}

class PayoutDetailsModel extends PayoutDetailsEntity {
  const PayoutDetailsModel({
    super.pricePerKilometre,
    super.totalCompletedOrders,
    super.today,
    super.summary,
    super.bankDetails,
  });

  factory PayoutDetailsModel.fromJson(Map<String, dynamic> json) {
    final today = json['today'];
    final summary = json['summary'];
    final bank = json['bank_details'];
    return PayoutDetailsModel(
      pricePerKilometre: json['price_per_kilometre'] as num?,
      totalCompletedOrders: (json['total_completed_orders'] as num?)?.toInt(),
      today: today is Map<String, dynamic>
          ? TodayPayoutModel.fromJson(today)
          : null,
      summary: summary is Map<String, dynamic>
          ? PayoutSummaryModel.fromJson(summary)
          : null,
      bankDetails: bank is Map<String, dynamic>
          ? BankDetailsModel.fromJson(bank)
          : null,
    );
  }
}

class TodayPayoutModel extends TodayPayoutEntity {
  const TodayPayoutModel({
    super.date,
    super.distanceKm,
    super.amount,
    super.paymentStatus,
  });

  factory TodayPayoutModel.fromJson(Map<String, dynamic> json) {
    return TodayPayoutModel(
      date: json['date'] as String?,
      distanceKm: json['distance_km'] as num?,
      amount: json['amount'] as num?,
      paymentStatus: json['payment_status'] as String?,
    );
  }
}

class PayoutSummaryModel extends PayoutSummaryEntity {
  const PayoutSummaryModel({
    super.totalEarned,
    super.totalPaid,
    super.totalPending,
    super.totalDistanceKm,
    super.daysWorked,
  });

  factory PayoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return PayoutSummaryModel(
      totalEarned: json['total_earned'] as num?,
      totalPaid: json['total_paid'] as num?,
      totalPending: json['total_pending'] as num?,
      totalDistanceKm: json['total_distance_km'] as num?,
      daysWorked: (json['days_worked'] as num?)?.toInt(),
    );
  }
}

class BankDetailsModel extends BankDetailsEntity {
  const BankDetailsModel({
    super.accountName,
    super.bankName,
    super.ifscCode,
    super.accountLast4,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      accountName: json['account_name'] as String?,
      bankName: json['bank_name'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      accountLast4: json['account_last4'] as String?,
    );
  }
}

class DailyHistoryModel extends DailyHistoryEntity {
  const DailyHistoryModel({
    super.date,
    super.distanceKm,
    super.amount,
    super.paymentStatus,
  });

  factory DailyHistoryModel.fromJson(Map<String, dynamic> json) {
    return DailyHistoryModel(
      date: json['date'] as String?,
      distanceKm: json['distance_km'] as num?,
      amount: json['amount'] as num?,
      paymentStatus: json['payment_status'] as String?,
    );
  }
}

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    super.receiptId,
    super.receiptNumber,
    super.periodDate,
    super.amount,
    super.currency,
    super.distanceKm,
    super.issuedAt,
    super.paymentMode,
    super.downloadUrl,
    super.pdfUrl,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final issuedRaw = json['issued_at'];
    return InvoiceModel(
      receiptId: json['receipt_id'] as String?,
      receiptNumber: json['receipt_number'] as String?,
      periodDate: json['period_date'] as String?,
      amount: json['amount'] as num?,
      currency: json['currency'] as String?,
      distanceKm: json['distance_km'] as num?,
      issuedAt: issuedRaw is String ? DateTime.tryParse(issuedRaw) : null,
      paymentMode: json['payment_mode'] as String?,
      downloadUrl: json['download_url'] as String?,
      pdfUrl: json['pdf_url'] as String?,
    );
  }
}
