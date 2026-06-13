import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
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
    return isar.localEmails.where().watch(fireImmediately: true);
  }
}
