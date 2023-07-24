enum ResultStatus { succeeded, cancelled, failed }

class Result {
  late ResultStatus status;
  late bool showedDialog;
  late int dataCount;

  Result({status = ResultStatus.failed, showedDialog = false, dataCount = 0}) {
    this.status = status;
    this.showedDialog = showedDialog;
    this.dataCount = dataCount;
  }
}