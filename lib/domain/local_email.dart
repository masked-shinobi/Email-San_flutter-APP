import 'package:isar_community/isar.dart';

part 'local_email.g.dart';

@collection
class LocalEmail {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  final String messageId;

  final String from;
  final String subject;
  final DateTime timestamp;
  final String body;

  @Index(type: IndexType.value)
  final String accountId;

  @enumerated
  @Index(type: IndexType.value)
  final EmailCategory category;

  final double importanceScore;
  final bool isPinned;
  final String summary;

  LocalEmail({
    required this.messageId,
    required this.from,
    required this.subject,
    required this.timestamp,
    required this.body,
    required this.accountId,
    this.category = EmailCategory.general,
    this.importanceScore = 0.0,
    this.isPinned = false,
    this.summary = '',
  });
}

enum EmailCategory {
  placement,
  academic,
  general,
  trash,
}
