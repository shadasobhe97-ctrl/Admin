import 'complaint_model.dart';

class ComplaintActionResultModel {
  final bool status;
  final String message;
  final ComplaintModel? complaint;

  const ComplaintActionResultModel({
    required this.status,
    required this.message,
    this.complaint,
  });

  factory ComplaintActionResultModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] == true;
    final message = json['message']?.toString() ?? 'تمت العملية بنجاح.';
    final dataMap = json['data'] as Map<String, dynamic>?;

    return ComplaintActionResultModel(
      status: status,
      message: message,
      complaint: dataMap != null ? ComplaintModel.fromJson(dataMap) : null,
    );
  }
}
