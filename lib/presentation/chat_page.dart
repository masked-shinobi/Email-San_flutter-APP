import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/domain/local_email.dart';
import 'package:myapp/presentation/inbox_page.dart'; // to read the stream provider

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatPageState extends StateNotifier<List<ChatMessage>> {
  ChatPageState()
      : super([
          ChatMessage(
            text: 'Hello! I am your Mail-san Chief of Staff. How can I help triage your inbox today?',
            isUser: false,
            timestamp: DateTime.now(),
          )
        ]);

  void addMessage(String text, bool isUser) {
    state = [...state, ChatMessage(text: text, isUser: isUser, timestamp: DateTime.now())];
  }

  void respondWithLocalAI(String query, List<LocalEmail> emails) async {
    addMessage(query, true);

    // Simulate thinking delay
    await Future.delayed(const Duration(milliseconds: 600));

    final normalized = query.toLowerCase();
    String responseText = '';

    if (normalized.contains('exam') || normalized.contains('academic') || normalized.contains('test')) {
      final academicEmails = emails.where((e) => e.category == EmailCategory.academic).toList();
      if (academicEmails.isEmpty) {
        responseText = 'I checked your inbox, but I couldn\'t find any academic or exam-related emails.';
      } else {
        responseText = 'Here are the upcoming academic/exam updates in your inbox:\n\n';
        for (var e in academicEmails) {
          responseText += '• *${e.subject}* (from: ${e.from})\n  AI Summary: ${e.summary}\n\n';
        }
      }
    } else if (normalized.contains('placement') || normalized.contains('job') || normalized.contains('career') || normalized.contains('microsoft') || normalized.contains('google')) {
      final placementEmails = emails.where((e) => e.category == EmailCategory.placement).toList();
      if (placementEmails.isEmpty) {
        responseText = 'There are currently no placement drive updates or job offers in your inbox.';
      } else {
        responseText = 'Here are your placement drive updates:\n\n';
        for (var e in placementEmails) {
          final priorityText = e.importanceScore >= 9.0 ? '🚨 HIGH PRIORITY' : '⭐';
          responseText += '$priorityText *${e.subject}*\n  Deadline/Alert: ${e.summary}\n\n';
        }
      }
    } else if (normalized.contains('priority') || normalized.contains('urgent') || normalized.contains('important')) {
      final importantEmails = emails.where((e) => e.importanceScore >= 8.0).toList();
      if (importantEmails.isEmpty) {
        responseText = 'Awesome! No high-priority or urgent action items found in your inbox.';
      } else {
        responseText = 'I found ${importantEmails.length} high-importance emails requiring attention:\n\n';
        for (var e in importantEmails) {
          responseText += '• [Score: ${e.importanceScore.toStringAsFixed(1)}] *${e.subject}*\n  From: ${e.from}\n  Summary: ${e.summary}\n\n';
        }
      }
    } else if (normalized.contains('summary') || normalized.contains('summarize') || normalized.contains('what\'s new')) {
      responseText = 'Here is a quick digest of your inbox:\n\n'
          '• Placements: ${emails.where((e) => e.category == EmailCategory.placement).length} updates.\n'
          '• Academic: ${emails.where((e) => e.category == EmailCategory.academic).length} deadlines.\n'
          '• General Inbox: ${emails.where((e) => e.category == EmailCategory.general).length} messages.\n\n'
          'Let me know if you want me to list specific exams or placement details!';
    } else {
      responseText = 'I can help query your inbox offline. Try asking:\n'
          '• "What exams are coming up this week?"\n'
          '• "Sum up placement updates"\n'
          '• "Show my high-priority emails"';
    }

    state = [...state, ChatMessage(text: responseText, isUser: false, timestamp: DateTime.now())];
  }
}

final chatProvider = StateNotifierProvider<ChatPageState, List<ChatMessage>>((ref) {
  return ChatPageState();
});

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final emailsAsync = ref.watch(emailsProvider);
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161A),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFB39DDB)),
            const SizedBox(width: 8),
            Text(
              'Inbox Copilot',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Suggestions Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF16161A).withOpacity(0.5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _SuggestionChip(
                    text: '📅 Any exams coming up?',
                    onTap: () {
                      emailsAsync.whenData((emails) =>
                          ref.read(chatProvider.notifier).respondWithLocalAI('Any exams coming up?', emails));
                    },
                  ),
                  const SizedBox(width: 8),
                  _SuggestionChip(
                    text: '💼 Sum up placement details',
                    onTap: () {
                      emailsAsync.whenData((emails) =>
                          ref.read(chatProvider.notifier).respondWithLocalAI('Sum up placement details', emails));
                    },
                  ),
                  const SizedBox(width: 8),
                  _SuggestionChip(
                    text: '🚨 High priority actions',
                    onTap: () {
                      emailsAsync.whenData((emails) =>
                          ref.read(chatProvider.notifier).respondWithLocalAI('Show high priority actions', emails));
                    },
                  ),
                ],
              ),
            ),
          ),

          // Messages View
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: message.isUser ? const Color(0xFF673AB7) : const Color(0xFF16161A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                        bottomRight: Radius.circular(message.isUser ? 4 : 16),
                      ),
                      border: message.isUser
                          ? null
                          : Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Text(
                      message.text,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Chat Input Panel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF16161A),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F11),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextField(
                        controller: textController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ask about your inbox...',
                          hintStyle: const TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (query) {
                          if (query.trim().isEmpty) return;
                          emailsAsync.whenData((emails) {
                            ref.read(chatProvider.notifier).respondWithLocalAI(query.trim(), emails);
                            textController.clear();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF673AB7),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () {
                        final query = textController.text.trim();
                        if (query.isEmpty) return;
                        emailsAsync.whenData((emails) {
                          ref.read(chatProvider.notifier).respondWithLocalAI(query, emails);
                          textController.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: const Color(0xFF16161A),
      label: Text(
        text,
        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
      ),
      side: const BorderSide(color: Colors.white10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
