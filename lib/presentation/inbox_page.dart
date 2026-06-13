import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/domain/local_email.dart';
import 'package:myapp/presentation/email_repository.dart';
import 'package:myapp/presentation/details_page.dart';
import 'package:myapp/presentation/sync_page.dart';
import 'package:myapp/presentation/chat_page.dart';

final emailsProvider = StreamProvider<List<LocalEmail>>((ref) {
  final repository = ref.watch(emailRepositoryProvider);
  return repository.watchEmails();
});

// Providers for UI State
final currentTabProvider = StateProvider<int>((ref) => 0);
final selectedCategoryFilterProvider = StateProvider<EmailCategory?>((ref) => null);
final filterPinnedOnlyProvider = StateProvider<bool>((ref) => false);
final searchQueryProvider = StateProvider<String>((ref) => '');

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFFFF3D00); // Urgent red-orange
    if (score >= 5.0) return const Color(0xFFFFC400); // Medium yellow
    return Colors.white38;
  }

  Color _getCategoryColor(EmailCategory category) {
    switch (category) {
      case EmailCategory.placement:
        return const Color(0xFF00E676);
      case EmailCategory.academic:
        return const Color(0xFFFF9100);
      case EmailCategory.general:
        return const Color(0xFF29B6F6);
      case EmailCategory.trash:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: IndexedStack(
        index: currentTab,
        children: [
          _buildFeedTab(context, ref),
          const SyncPage(),
          const ChatPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        backgroundColor: const Color(0xFF16161A),
        selectedItemColor: const Color(0xFF673AB7),
        unselectedItemColor: Colors.white30,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
        onTap: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            activeIcon: Icon(Icons.inbox, color: Color(0xFF673AB7)),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync_alt),
            activeIcon: Icon(Icons.sync_alt, color: Color(0xFF673AB7)),
            label: 'Sync Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            activeIcon: Icon(Icons.auto_awesome, color: Color(0xFF673AB7)),
            label: 'AI Copilot',
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTab(BuildContext context, WidgetRef ref) {
    final emailsAsync = ref.watch(emailsProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final pinnedOnly = ref.watch(filterPinnedOnlyProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final repository = ref.read(emailRepositoryProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER PANEL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mail-san',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'AI-POWERED TRIAGE',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF673AB7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                // Quick info badge
                emailsAsync.when(
                  data: (list) {
                    final urgentCount = list.where((e) => e.importanceScore >= 8.0).length;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: urgentCount > 0
                            ? const Color(0xFFFF3D00).withOpacity(0.15)
                            : Colors.white05,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: urgentCount > 0
                              ? const Color(0xFFFF3D00).withOpacity(0.3)
                              : Colors.white12,
                        ),
                      ),
                      child: Text(
                        '$urgentCount URGENT',
                        style: GoogleFonts.outfit(
                          color: urgentCount > 0 ? const Color(0xFFFF9E80) : Colors.white30,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF16161A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search sender, subject, summary...',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.white30, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white30, size: 16),
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).state = val;
                },
              ),
            ),
          ),

          // FILTER CHIPS
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // ALL FILTER
                  FilterChip(
                    label: Text(
                      'ALL',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    selected: selectedCategory == null && !pinnedOnly,
                    selectedColor: const Color(0xFF673AB7),
                    backgroundColor: const Color(0xFF16161A),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: (selectedCategory == null && !pinnedOnly) ? Colors.white : Colors.white60,
                    ),
                    side: const BorderSide(color: Colors.white10),
                    onSelected: (_) {
                      ref.read(selectedCategoryFilterProvider.notifier).state = null;
                      ref.read(filterPinnedOnlyProvider.notifier).state = false;
                    },
                  ),
                  const SizedBox(width: 8),

                  // PINNED FILTER
                  FilterChip(
                    label: Text(
                      'STAY (PINNED)',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    selected: pinnedOnly,
                    selectedColor: const Color(0xFF00E676),
                    backgroundColor: const Color(0xFF16161A),
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: pinnedOnly ? Colors.black : Colors.white60,
                    ),
                    side: const BorderSide(color: Colors.white10),
                    onSelected: (val) {
                      ref.read(filterPinnedOnlyProvider.notifier).state = val;
                      if (val) {
                        ref.read(selectedCategoryFilterProvider.notifier).state = null;
                      }
                    },
                  ),
                  const SizedBox(width: 8),

                  // PLACEMENTS FILTER
                  FilterChip(
                    label: Text(
                      'PLACEMENTS',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    selected: selectedCategory == EmailCategory.placement,
                    selectedColor: const Color(0xFF00E676),
                    backgroundColor: const Color(0xFF16161A),
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: selectedCategory == EmailCategory.placement ? Colors.black : Colors.white60,
                    ),
                    side: const BorderSide(color: Colors.white10),
                    onSelected: (val) {
                      ref.read(selectedCategoryFilterProvider.notifier).state = val ? EmailCategory.placement : null;
                      ref.read(filterPinnedOnlyProvider.notifier).state = false;
                    },
                  ),
                  const SizedBox(width: 8),

                  // ACADEMICS FILTER
                  FilterChip(
                    label: Text(
                      'ACADEMICS',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    selected: selectedCategory == EmailCategory.academic,
                    selectedColor: const Color(0xFFFF9100),
                    backgroundColor: const Color(0xFF16161A),
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: selectedCategory == EmailCategory.academic ? Colors.black : Colors.white60,
                    ),
                    side: const BorderSide(color: Colors.white10),
                    onSelected: (val) {
                      ref.read(selectedCategoryFilterProvider.notifier).state = val ? EmailCategory.academic : null;
                      ref.read(filterPinnedOnlyProvider.notifier).state = false;
                    },
                  ),
                  const SizedBox(width: 8),

                  // GENERAL FILTER
                  FilterChip(
                    label: Text(
                      'GENERAL',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    selected: selectedCategory == EmailCategory.general,
                    selectedColor: const Color(0xFF29B6F6),
                    backgroundColor: const Color(0xFF16161A),
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: selectedCategory == EmailCategory.general ? Colors.black : Colors.white60,
                    ),
                    side: const BorderSide(color: Colors.white10),
                    onSelected: (val) {
                      ref.read(selectedCategoryFilterProvider.notifier).state = val ? EmailCategory.general : null;
                      ref.read(filterPinnedOnlyProvider.notifier).state = false;
                    },
                  ),
                ],
              ),
            ),
          ),

          // EMAILS LISTING
          Expanded(
            child: emailsAsync.when(
              data: (emailList) {
                // Apply filters
                var filtered = emailList;

                if (pinnedOnly) {
                  filtered = filtered.where((e) => e.isPinned).toList();
                } else if (selectedCategory != null) {
                  filtered = filtered.where((e) => e.category == selectedCategory).toList();
                }

                if (searchQuery.isNotEmpty) {
                  final q = searchQuery.toLowerCase();
                  filtered = filtered.where((e) {
                    return e.subject.toLowerCase().contains(q) ||
                        e.from.toLowerCase().contains(q) ||
                        e.summary.toLowerCase().contains(q) ||
                        e.body.toLowerCase().contains(q);
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No emails matched your criteria.',
                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final email = filtered[index];
                    final dateStr = DateFormat('hh:mm a').format(email.timestamp);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Dismissible(
                          key: Key(email.id.toString()),
                          // Swipe Right: PIN/Stay
                          background: Container(
                            color: const Color(0xFF00E676),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerLeft,
                            child: const Icon(Icons.push_pin, color: Colors.black, size: 28),
                          ),
                          // Swipe Left: Delete
                          secondaryBackground: Container(
                            color: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete, color: Colors.white, size: 28),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDismissibleDirection.startToEnd) {
                              // Pin/Unpin
                              await repository.togglePin(email.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(email.isPinned ? 'Stay removed' : 'Pinned permanently'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              return false; // Don't remove widget from tree, just state change
                            } else {
                              // Delete
                              await repository.deleteEmail(email.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email Deleted'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              return true;
                            }
                          },
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DetailsPage(email: email)),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              color: const Color(0xFF16161A),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Priority circle badge
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _getScoreColor(email.importanceScore),
                                        width: 1.5,
                                      ),
                                      color: _getScoreColor(email.importanceScore).withOpacity(0.08),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      email.importanceScore.toStringAsFixed(0),
                                      style: GoogleFonts.outfit(
                                        color: email.importanceScore >= 5.0
                                            ? _getScoreColor(email.importanceScore)
                                            : Colors.white60,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Core content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                email.from.split('@').first,
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              dateStr,
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.white30,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          email.subject,
                                          style: GoogleFonts.outfit(
                                            color: Colors.whiteE6,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),

                                        // Summary block
                                        if (email.summary.isNotEmpty)
                                          Text(
                                            email.summary,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white54,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 10),

                                        // Badges row
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(email.category).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                email.category.name.toUpperCase(),
                                                style: GoogleFonts.outfit(
                                                  color: _getCategoryColor(email.category),
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            if (email.isPinned) ...[
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.push_pin,
                                                color: Color(0xFF00E676),
                                                size: 12,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading database: $error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
