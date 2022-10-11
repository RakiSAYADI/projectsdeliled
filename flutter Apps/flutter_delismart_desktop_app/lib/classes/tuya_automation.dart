class AutomationClass {
  bool enabled = false;
  String automationId = '';
  String name = '';
  int matchType = 0;
  List<Map<String, dynamic>> actions = [];
  List<Map<String, dynamic>> conditions = [];
  List<Map<String, dynamic>> preconditions = [];

  AutomationClass({required this.enabled, required this.automationId, required this.name, required this.matchType, required this.actions, required this.conditions, required this.preconditions});
}
