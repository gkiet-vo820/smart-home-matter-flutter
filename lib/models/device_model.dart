class DeviceModel {
  final String id;
  final String name;
  final String room;
  final String type;
  final String endpoint;
  final String cluster;

  bool isOn;
  bool isConnected;

  DeviceModel({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    required this.endpoint,
    required this.cluster,
    required this.isOn,
    required this.isConnected,
  });

  DeviceModel copyWith({String? id, String? name, String? room, String? type, String? endpoint,
    String? cluster, bool? isOn, bool? isConnected}){
    return DeviceModel(
        id: id ?? this.id,
        name: name ?? this.name,
        room: room ?? this.room,
        type: type ?? this.type,
        endpoint: endpoint ?? this.endpoint,
        cluster: cluster ?? this.cluster,
        isOn: isOn ?? this.isOn,
        isConnected: isConnected ?? this.isConnected,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'room': room,
      'type': type,
      'endpoint': endpoint,
      'cluster': cluster,
      'isOn': isOn,
      'isConnected': isConnected,
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json){
    return DeviceModel(
      id: json['id'] ?? '', 
      name: json['name'] ?? '',
      room: json['room'] ?? '', 
      type: json['type'] ?? '', 
      endpoint: json['endpoint'] ?? '', 
      cluster: json['cluster'] ?? '', 
      isOn: json['isOn'] ?? false, 
      isConnected: json['isConnected'] ?? false,
    );
  }
}