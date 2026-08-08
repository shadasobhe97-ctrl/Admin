class DriverChangeDetailsModel {
  final int id;
  final int? driverId;
  final String? changeType;
  final String? status;
  final Map<String, dynamic> currentData;
  final Map<String, dynamic> proposedData;

  DriverChangeDetailsModel({
    required this.id,
    this.driverId,
    this.changeType,
    this.status,
    required this.currentData,
    required this.proposedData,
  });

  factory DriverChangeDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> dataObj = json;
    if (json['data'] is Map<String, dynamic>) {
      dataObj = json['data'];
    }

    int parsedId = 0;
    if (dataObj['id'] != null) {
      parsedId = dataObj['id'] is int ? dataObj['id'] : (int.tryParse(dataObj['id'].toString()) ?? 0);
    }

    Map<String, dynamic> currentMap = {};
    if (dataObj['current_data'] is Map<String, dynamic>) {
      currentMap = dataObj['current_data'];
    }

    Map<String, dynamic> proposedMap = {};
    if (dataObj['proposed_data'] is Map<String, dynamic>) {
      proposedMap = dataObj['proposed_data'];
    }

    return DriverChangeDetailsModel(
      id: parsedId,
      driverId: dataObj['driver_id'] is int ? dataObj['driver_id'] : int.tryParse(dataObj['driver_id']?.toString() ?? ''),
      changeType: dataObj['change_type']?.toString(),
      status: dataObj['status']?.toString(),
      currentData: currentMap,
      proposedData: proposedMap,
    );
  }
}
