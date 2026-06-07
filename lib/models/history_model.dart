class HistoryModel{
    final String id;
    final String deviceName;
    final String action;
    final String time;
    final String type;

    HistoryModel({required this.id, required this.deviceName, required this.action, required this.time, required this.type});

    Map<String, dynamic> toJson(){
        return{
            'id': id,
            'deviceName': deviceName,
            'action': action,
            'time': time,
            'type': type,
        };
    }

    factory HistoryModel.fromJson(Map<String, dynamic> json){
        return HistoryModel(
            id: json['id'] ?? '', 
            deviceName: json['deviceName'] ?? '', 
            action: json['action'] ?? '', 
            time: json['time'] ?? '', 
            type: json['type'] ?? '',
        );
    }
}