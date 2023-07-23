class Result {
  late bool succeeded;
  late bool showedDialog;
  late int dataCount;

  Result({succeeded = false, showedDialog = false, dataCount = 0}) {
    this.succeeded = succeeded;
    this.showedDialog = showedDialog;
    this.dataCount = dataCount;
  }
}