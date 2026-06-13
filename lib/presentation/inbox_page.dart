import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/local_email.dart';
import 'package:myapp/presentation/email_repository.dart';

final emailsProvider = StreamProvider<List<LocalEmail>>((ref) {
  final repository = ref.watch(emailRepositoryProvider);
  return repository.watchEmails();
});

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emails = ref.watch(emailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: emails.when(
        data: (emailList) {
          if (emailList.isEmpty) {
            return const Center(
              child: Text('No emails found.'),
            );
          }
          return ListView.builder(
            itemCount: emailList.length,
            itemBuilder: (context, index) {
              final email = emailList[index];
              return ListTile(
                title: Text(email.subject),
                subtitle: Text(email.from),
                onTap: () {
                  // Navigate to email detail page
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
