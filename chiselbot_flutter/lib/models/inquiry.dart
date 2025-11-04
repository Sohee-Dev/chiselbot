enum InquiryStatus { WAITING, ANSWERED, CLOSED }

InquiryStatus statusFromString(String? s) {
  switch (s) {
    case 'WAITING':
      return InquiryStatus.WAITING;
    case 'ANSWERED':
      return InquiryStatus.ANSWERED;
    case 'CLOSED':
      return InquiryStatus.CLOSED;
    default:
      return InquiryStatus.WAITING;
  }
}

String statusToString(InquiryStatus st) {
  switch (st) {
    case InquiryStatus.WAITING:
      return 'WAITING';
    case InquiryStatus.ANSWERED:
      return 'ANSWERED';
    case InquiryStatus.CLOSED:
      return 'CLOSED';
  }
}

class Inquiry {
  final int inquiryId;
  final int? userId;
  final int? adminId;
  final String title;
  final String content;
  final String? answerContent;
  final InquiryStatus status;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final DateTime? updatedAt;

  Inquiry({
    required this.inquiryId,
    required this.userId,
    required this.adminId,
    required this.title,
    required this.content,
    required this.answerContent,
    required this.status,
    required this.createdAt,
    required this.answeredAt,
    required this.updatedAt,
  });

  static DateTime? _parseDT(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    // Timestamp를 직렬화해서 내려올 수 있으므로 문자열 변환 기대
    return DateTime.tryParse(v.toString());
  }

  factory Inquiry.fromJson(Map<String, dynamic> j) {
    final id = j['inquiryId'] ?? j['id'];
    return Inquiry(
      inquiryId: (id is int) ? id : int.parse(id.toString()),
      userId: j['userId'] == null ? null : int.tryParse(j['userId'].toString()),
      adminId:
          j['adminId'] == null ? null : int.tryParse(j['adminId'].toString()),
      title: j['title'] ?? '',
      content: j['content'] ?? '',
      answerContent: j['answerContent'],
      status: statusFromString(j['status']?.toString()),
      createdAt: _parseDT(j['createdAt']) ?? DateTime.now(),
      answeredAt: _parseDT(j['answeredAt']),
      updatedAt: _parseDT(j['updatedAt']),
    );
  }
}
