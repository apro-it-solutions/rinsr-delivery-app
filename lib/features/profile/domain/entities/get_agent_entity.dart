import 'package:equatable/equatable.dart';

class GetAgentEntity extends Equatable {
  final bool? success;
  final ProfileDataEntity? data;

  const GetAgentEntity({this.success, this.data});

  @override
  List<Object?> get props => [success, data];
}

class ProfileDataEntity extends Equatable {
  final BasicInfoEntity? basicInfo;
  final PayoutDetailsEntity? payoutDetails;
  final List<DailyHistoryEntity>? dailyHistory;
  final List<InvoiceEntity>? invoices;

  const ProfileDataEntity({
    this.basicInfo,
    this.payoutDetails,
    this.dailyHistory,
    this.invoices,
  });

  @override
  List<Object?> get props => [basicInfo, payoutDetails, dailyHistory, invoices];
}

class BasicInfoEntity extends Equatable {
  final String? id;
  final String? fullName;
  final String? phoneNumber;
  final String? photo;
  final String? currentAddress;
  final String? vehicleType;
  final VehicleDetailsEntity? vehicleDetails;
  final String? availability;
  final List<String>? preferredZones;
  final String? status;
  final bool? isActive;
  final DateTime? memberSince;

  const BasicInfoEntity({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.photo,
    this.currentAddress,
    this.vehicleType,
    this.vehicleDetails,
    this.availability,
    this.preferredZones,
    this.status,
    this.isActive,
    this.memberSince,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    phoneNumber,
    photo,
    currentAddress,
    vehicleType,
    vehicleDetails,
    availability,
    preferredZones,
    status,
    isActive,
    memberSince,
  ];
}

class VehicleDetailsEntity extends Equatable {
  final String? make;
  final String? model;
  final String? registrationNumber;
  final String? year;

  const VehicleDetailsEntity({
    this.make,
    this.model,
    this.registrationNumber,
    this.year,
  });

  @override
  List<Object?> get props => [make, model, registrationNumber, year];
}

class PayoutDetailsEntity extends Equatable {
  final num? pricePerKilometre;
  final int? totalCompletedOrders;
  final TodayPayoutEntity? today;
  final PayoutSummaryEntity? summary;
  final BankDetailsEntity? bankDetails;

  const PayoutDetailsEntity({
    this.pricePerKilometre,
    this.totalCompletedOrders,
    this.today,
    this.summary,
    this.bankDetails,
  });

  @override
  List<Object?> get props => [
    pricePerKilometre,
    totalCompletedOrders,
    today,
    summary,
    bankDetails,
  ];
}

class TodayPayoutEntity extends Equatable {
  final String? date;
  final num? distanceKm;
  final num? amount;
  final String? paymentStatus;

  const TodayPayoutEntity({
    this.date,
    this.distanceKm,
    this.amount,
    this.paymentStatus,
  });

  @override
  List<Object?> get props => [date, distanceKm, amount, paymentStatus];
}

class PayoutSummaryEntity extends Equatable {
  final num? totalEarned;
  final num? totalPaid;
  final num? totalPending;
  final num? totalDistanceKm;
  final int? daysWorked;

  const PayoutSummaryEntity({
    this.totalEarned,
    this.totalPaid,
    this.totalPending,
    this.totalDistanceKm,
    this.daysWorked,
  });

  @override
  List<Object?> get props => [
    totalEarned,
    totalPaid,
    totalPending,
    totalDistanceKm,
    daysWorked,
  ];
}

class BankDetailsEntity extends Equatable {
  final String? accountName;
  final String? bankName;
  final String? ifscCode;
  final String? accountLast4;

  const BankDetailsEntity({
    this.accountName,
    this.bankName,
    this.ifscCode,
    this.accountLast4,
  });

  @override
  List<Object?> get props => [accountName, bankName, ifscCode, accountLast4];
}

class DailyHistoryEntity extends Equatable {
  final String? date;
  final num? distanceKm;
  final num? amount;
  final String? paymentStatus;

  const DailyHistoryEntity({
    this.date,
    this.distanceKm,
    this.amount,
    this.paymentStatus,
  });

  @override
  List<Object?> get props => [date, distanceKm, amount, paymentStatus];
}

class InvoiceEntity extends Equatable {
  final String? receiptId;
  final String? receiptNumber;
  final String? periodDate;
  final num? amount;
  final String? currency;
  final num? distanceKm;
  final DateTime? issuedAt;
  final String? paymentMode;
  final String? downloadUrl;
  final String? pdfUrl;

  const InvoiceEntity({
    this.receiptId,
    this.receiptNumber,
    this.periodDate,
    this.amount,
    this.currency,
    this.distanceKm,
    this.issuedAt,
    this.paymentMode,
    this.downloadUrl,
    this.pdfUrl,
  });

  @override
  List<Object?> get props => [
    receiptId,
    receiptNumber,
    periodDate,
    amount,
    currency,
    distanceKm,
    issuedAt,
    paymentMode,
    downloadUrl,
    pdfUrl,
  ];
}
