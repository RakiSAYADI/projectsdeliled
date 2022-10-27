class DeviceClass {
  int activeTime = 0;
  int bizType = 0;
  String category = '';
  int createTime = 0;
  String imageUrl = '';
  String id = '';
  String ip = '';
  String lat = '';
  String localKey = '';
  String lon = '';
  String model = '';
  String name = '';
  bool online = false;
  String ownerId = '';
  String productId = '';
  String productName = '';
  List<Map<String, dynamic>> functions = [];
  bool sub = false;
  String timeZone = '';
  String uid = '';
  int updateTime = 0;
  String uuid = '';

  DeviceClass({
    required this.activeTime,
    required this.bizType,
    required this.category,
    required this.createTime,
    required this.imageUrl,
    required this.id,
    required this.ip,
    required this.lat,
    this.localKey = '',
    required this.lon,
    required this.model,
    required this.name,
    required this.online,
    required this.ownerId,
    required this.productId,
    required this.productName,
    required this.sub,
    required this.timeZone,
    required this.uid,
    required this.updateTime,
    required this.uuid,
    required this.functions
  });
}
