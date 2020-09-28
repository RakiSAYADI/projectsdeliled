class UvcLight {
  String machineName;
  String machineMac;

  String company;
  String operatorName;
  String roomName;
  String infectionTime;
  String activationTime;

  UvcLight(
      {this.machineName,
      this.machineMac,
      this.company,
      this.operatorName,
      this.roomName,
      this.infectionTime,
      this.activationTime});

  int getInfectionTime() {
    return int.parse(this.infectionTime.substring(0, 3));
  }

  int getActivationTime() {
    return int.parse(this.activationTime.substring(0, 3));
  }

  String getInfectionTimeOnString() {
    return this.infectionTime;
  }

  String getActivationTimeOnString() {
    return this.activationTime;
  }

  String getCompanyName() {
    return this.company;
  }

  String getOperatorName() {
    return this.operatorName;
  }

  String getRoomName() {
    return this.roomName;
  }

  String getMachineName() {
    return this.machineName;
  }

  String getMachineMac() {
    return this.machineMac;
  }

  void setCompanyName(String newCompanyName) {
    this.company = newCompanyName;
  }

  void setMachineMac(String newMachineMac) {
    this.machineMac = newMachineMac;
  }

  void setMachineName(String newMachineName) {
    this.machineName = newMachineName;
  }

  void setOperatorName(String newOperatorName) {
    this.operatorName = newOperatorName;
  }

  void setRoomName(String newRoomName) {
    this.roomName = newRoomName;
  }

  void setActivationTime(String newActivationTime) {
    this.activationTime = newActivationTime;
  }

  void setInfectionTime(String newInfectionTime) {
    this.infectionTime = newInfectionTime;
  }
}
