import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myapp/domain/local_email.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [LocalEmailSchema],
    directory: dir.path,
  );

  // Populate mock data if empty
  final count = await isar.localEmails.count();
  if (count == 0) {
    await isar.writeTxn(() async {
      final mockEmails = [
        LocalEmail(
          messageId: 'msg_001',
          accountId: 'personal@gmail.com',
          from: 'university-placements@institution.edu',
          subject: 'ALERT: Google Campus Drive - Deadline Tomorrow',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          body: 'Dear Students, Google is organizing a campus recruitment drive. Please register via the attached portal. The registration link closes tomorrow at 5:00 PM. High priority action is required.',
          category: EmailCategory.placement,
          importanceScore: 9.8,
          isPinned: true,
          summary: 'Google campus recruitment drive registration closes tomorrow at 5:00 PM. Action required immediately.',
        ),
        LocalEmail(
          messageId: 'msg_002',
          accountId: 'academic@institution.edu',
          from: 'registrar@institution.edu',
          subject: 'Final Exam Timetable for Semester 2',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          body: 'Hello all, the final semester examinations will commence on June 22nd. Please check the portal for your venue and time details. Hall tickets can be downloaded starting Monday.',
          category: EmailCategory.academic,
          importanceScore: 8.5,
          isPinned: false,
          summary: 'Semester 2 final exams start June 22nd. Venue details on portal, hall tickets download starts Monday.',
        ),
        LocalEmail(
          messageId: 'msg_003',
          accountId: 'personal@gmail.com',
          from: 'newsletters@techtrends.com',
          subject: 'Weekly Tech Insights: Llama 3.2 on Mobile',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          body: 'This week we discuss running LLMs on mobile devices. Local LLMs like Llama 3.2 are changing privacy-centric apps. Read on for the full analysis.',
          category: EmailCategory.general,
          importanceScore: 3.2,
          isPinned: false,
          summary: 'Weekly newsletter discussing local LLMs like Llama 3.2 on mobile devices and privacy benefits.',
        ),
        LocalEmail(
          messageId: 'msg_004',
          accountId: 'client@work.com',
          from: 'john.client@partner-agency.com',
          subject: 'Urgent: Revision required for project proposal',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          body: 'Hi, we reviewed the proposal. We need you to adjust the budget estimates for Phase 2. Please send the revised document by tonight so we can submit it to the board.',
          category: EmailCategory.general,
          importanceScore: 8.9,
          isPinned: false,
          summary: 'John requests urgent revision to project proposal budget estimates for Phase 2 by tonight.',
        ),
        LocalEmail(
          messageId: 'msg_005',
          accountId: 'personal@gmail.com',
          from: 'offers@shoppingdeal.com',
          subject: 'Get 50% off on all subscriptions - limited time!',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          body: 'Super summer deal! Upgrade your account today and save 50% on annual billing. Valid for the next 24 hours only.',
          category: EmailCategory.general,
          importanceScore: 1.2,
          isPinned: false,
          summary: 'Marketing spam offering 50% subscription discount.',
        ),
      ];
      await isar.localEmails.putAll(mockEmails);
    });
  }
  return isar;
});
