import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:myapp/data/isar_service.dart';
import 'package:myapp/domain/local_email.dart';

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return EmailRepository(isar);
});

class EmailRepository {
  final Isar isar;

  EmailRepository(this.isar);

  Stream<List<LocalEmail>> watchEmails() {
    return isar.localEmails.where().sortByTimestampDesc().watch(fireImmediately: true);
  }

  Future<void> togglePin(Id id) async {
    await isar.writeTxn(() async {
      final email = await isar.localEmails.get(id);
      if (email != null) {
        final updated = LocalEmail(
          messageId: email.messageId,
          from: email.from,
          subject: email.subject,
          timestamp: email.timestamp,
          body: email.body,
          accountId: email.accountId,
          category: email.category,
          importanceScore: email.importanceScore,
          isPinned: !email.isPinned,
          summary: email.summary,
        )..id = email.id;
        await isar.localEmails.put(updated);
      }
    });
  }

  Future<void> updateCategory(Id id, EmailCategory category) async {
    await isar.writeTxn(() async {
      final email = await isar.localEmails.get(id);
      if (email != null) {
        final updated = LocalEmail(
          messageId: email.messageId,
          from: email.from,
          subject: email.subject,
          timestamp: email.timestamp,
          body: email.body,
          accountId: email.accountId,
          category: category,
          importanceScore: email.importanceScore,
          isPinned: email.isPinned,
          summary: email.summary,
        )..id = email.id;
        await isar.localEmails.put(updated);
      }
    });
  }

  Future<void> deleteEmail(Id id) async {
    await isar.writeTxn(() async {
      await isar.localEmails.delete(id);
    });
  }

  Future<void> addEmail(LocalEmail email) async {
    await isar.writeTxn(() async {
      await isar.localEmails.put(email);
    });
  }
}
