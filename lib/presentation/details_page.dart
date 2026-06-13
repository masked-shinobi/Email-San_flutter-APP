import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/domain/local_email.dart';
import 'package:myapp/presentation/email_repository.dart';

class DetailsPage extends ConsumerWidget {
  final LocalEmail email;

  const DetailsPage({super.key, required this.email});

  Color _getCategoryColor(EmailCategory category) {
    switch (category) {
      case EmailCategory.placement:
        return const Color(0xFF00E676); // High-contrast neon green
      case EmailCategory.academic:
        return const Color(0xFFFF9100); // Academic orange/yellow
      case EmailCategory.general:
        return const Color(0xFF29B6F6); // General light blue
      case EmailCategory.trash:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(email.timestamp);
    final repository = ref.read(emailRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161A),
        elevation: 0,
        title: Text(
          'Email Details',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              email.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: email.isPinned ? const Color(0xFF00E676) : Colors.white70,
            ),
            onPressed: () async {
              await repository.togglePin(email.id);
              // Simple feedback and close
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(email.isPinned ? 'Email Unpinned (Stay removed)' : 'Email Pinned (Saved from Auto-cleanup)'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                Navigator.pop(context); // Pop back to refresh list correctly
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              await repository.deleteEmail(email.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email Deleted'), duration: Duration(seconds: 1)),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getCategoryColor(email.category).withOpacity(0.15),
                  child: Text(
                    email.from.isNotEmpty ? email.from[0].toUpperCase() : 'M',
                    style: GoogleFonts.outfit(
                      color: _getCategoryColor(email.category),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email.from,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'to me (${email.accountId})',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(email.category).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getCategoryColor(email.category).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    email.category.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: _getCategoryColor(email.category),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Subject Line
            Text(
              email.subject,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Timestamp and Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white30,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Priority: ${email.importanceScore.toStringAsFixed(1)}/10',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 32),

            // AI SUMMARY CARD
            if (email.summary.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF673AB7).withOpacity(0.12),
                      const Color(0xFF3F51B5).withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF673AB7).withOpacity(0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFB39DDB),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI-POWERED SUMMARY',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFB39DDB),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email.summary,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.whiteD9,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // FULL EMAIL BODY
            Text(
              'EMAIL BODY',
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16161A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                email.body,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Triage Category Selector
            Text(
              'MANUAL RE-CLASSIFICATION',
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: EmailCategory.values.map((cat) {
                final isSelected = email.category == cat;
                return ChoiceChip(
                  label: Text(
                    cat.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : _getCategoryColor(cat),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: _getCategoryColor(cat),
                  backgroundColor: _getCategoryColor(cat).withOpacity(0.1),
                  side: BorderSide(
                    color: _getCategoryColor(cat).withOpacity(0.4),
                  ),
                  onSelected: (bool selected) async {
                    if (selected) {
                      await repository.updateCategory(email.id, cat);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reclassified as ${cat.name}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
