class SceneClass {
  bool enabled = false;
  String sceneId = '';
  String name = '';
  String background = '';
  List<Map<String, dynamic>> actions = [];

  SceneClass({required this.enabled, required this.sceneId, required this.name, required this.background, required this.actions});
}
