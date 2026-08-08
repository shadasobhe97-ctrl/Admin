import 'driver_document_model.dart';
import 'driver_model.dart';
import 'driver_vehicle_model.dart';

class DriverDetailsModel {
  final DriverModel driver;
  final List<DriverDocumentModel> documents;
  final DriverVehicleModel? vehicle;
  final Map<String, dynamic>? extraData;

  DriverDetailsModel({
    required this.driver,
    required this.documents,
    this.vehicle,
    this.extraData,
  });

  factory DriverDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> driverJson = json;
    if (json['driver'] is Map<String, dynamic>) {
      driverJson = json['driver'];
    } else if (json['data'] is Map<String, dynamic>) {
      driverJson = json['data'];
    }

    final driverObj = DriverModel.fromJson(driverJson);

    List<DriverDocumentModel> docsList = [];
    final docsRaw = driverJson['documents'] ?? json['documents'];
    if (docsRaw is List) {
      docsList = docsRaw.map((d) => DriverDocumentModel.fromJson(d as Map<String, dynamic>)).toList();
    }

    DriverVehicleModel? vehicleObj;
    final vehicleRaw = driverJson['vehicle'] ?? json['vehicle'];
    if (vehicleRaw is Map<String, dynamic>) {
      vehicleObj = DriverVehicleModel.fromJson(vehicleRaw);
    }

    return DriverDetailsModel(
      driver: driverObj,
      documents: docsList,
      vehicle: vehicleObj,
      extraData: json,
    );
  }
}
