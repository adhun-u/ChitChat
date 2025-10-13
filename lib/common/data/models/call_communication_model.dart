class CallCommunicationModel {
  final int callerId;
  final int calleeId;
  final String type;
  final String data;
  final String callType;
  final String callerName;

  CallCommunicationModel({
    required this.callerId,
    required this.calleeId,
    required this.type,
    required this.data,
    required this.callerName,
    required this.callType,
  });
}
