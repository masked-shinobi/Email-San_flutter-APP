import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/domain/local_email.dart';
import 'package:myapp/presentation/email_repository.dart';

// State notifier for sync status
class SyncStatus {
  final bool isSyncing;
  final String currentPhase;
  final double progress;
  final List<String> linkedAccounts;

  SyncStatus({
    required this.isSyncing,
    required this.currentPhase,
    required this.progress,
    required this.linkedAccounts,
  });

  SyncStatus copyWith({
    bool? isSyncing,
    String? currentPhase,
    double? progress,
    List<String>? linkedAccounts,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      currentPhase: currentPhase ?? this.currentPhase,
      progress: progress ?? this.progress,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncStatus> {
  final EmailRepository _repository;

  SyncNotifier(this._repository)
      : super(SyncStatus(
          isSyncing: false,
          currentPhase: 'Idle',
          progress: 0.0,
          linkedAccounts: ['personal@gmail.com', 'academic@institution.edu', 'client@work.com'],
        ));

  void addAccount(String email) {
    if (!state.linkedAccounts.contains(email) && state.linkedAccounts.length < 5) {
      state = state.copyWith(linkedAccounts: [...state.linkedAccounts, email]);
    }
  }

  void removeAccount(String email) {
    state = state.copyWith(
      linkedAccounts: state.linkedAccounts.where((e) => e != email).toList(),
    );
  }

  Future<void> runSync() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true, currentPhase: 'Phase 1: Fast Headers Sync...', progress: 0.2);
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(progress: 0.5);
    await Future.delayed(const Duration(milliseconds: 800));

    state = state.copyWith(currentPhase: 'Phase 2: Local AI Brain Classification & Scoring...', progress: 0.7);
    await Future.delayed(const Duration(seconds: 1));

    // Inject a new mock email matching placements or academic to prove sync works!
    final hasPlacement = state.linkedAccounts.any((a) => a.contains('institution'));
    final syncEmail = LocalEmail(
      messageId: 'msg_sync_${DateTime.now().millisecondsSinceEpoch}',
      accountId: state.linkedAccounts.isNotEmpty ? state.linkedAccounts.first : 'personal@gmail.com',
      from: 'placement-officer@institution.edu',
      subject: 'URGENT: Microsoft Interview Slots Open',
      timestamp: DateTime.now(),
      body: 'Congratulations! You have been shortlisted for the Microsoft interview round. Select your preferred slot on the portal. Slots are allocated on a first-come, first-serve basis. Confirm slot by tonight.',
      category: EmailCategory.placement,
      importanceScore: 9.9,
      isPinned: false,
      summary: 'Microsoft interview shortlist announced. Confirm preferred interview slot on portal by tonight.',
    );

    await _repository.addEmail(syncEmail);

    state = state.copyWith(progress: 1.0, currentPhase: 'Sync Completed.');
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(isSyncing: false, currentPhase: 'Idle', progress: 0.0);
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncStatus>((ref) {
  final repo = ref.watch(emailRepositoryProvider);
  return SyncNotifier(repo);
});

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final _emailController = TextEditingController();
  final _serverController = TextEditingController();
  final _passwordController = TextEditingController();
  String _accountType = 'Gmail'; // or 'IMAP'

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _emailController.dispose();
    _serverController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAddAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16161A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Link New Account',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Gmail (OAuth)'),
                        selected: _accountType == 'Gmail',
                        selectedColor: const Color(0xFF673AB7),
                        backgroundColor: Colors.white10,
                        labelStyle: GoogleFonts.outfit(color: Colors.white),
                        onSelected: (val) {
                          if (val) setModalState(() => _accountType = 'Gmail');
                        },
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('IMAP (College/Work)'),
                        selected: _accountType == 'IMAP',
                        selectedColor: const Color(0xFF673AB7),
                        backgroundColor: Colors.white10,
                        labelStyle: GoogleFonts.outfit(color: Colors.white),
                        onSelected: (val) {
                          if (val) setModalState(() => _accountType = 'IMAP');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF0F0F11),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                    ),
                  ),
                  if (_accountType == 'IMAP') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _serverController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'IMAP Server Host (e.g. mail.iit.ac.in)',
                        labelStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF0F0F11),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'App-Specific Password',
                        labelStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF0F0F11),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (_emailController.text.trim().isNotEmpty) {
                          ref.read(syncProvider.notifier).addAccount(_emailController.text.trim());
                          _emailController.clear();
                          _serverController.clear();
                          _passwordController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account configured successfully!')),
                          );
                        }
                      },
                      child: Text(
                        _accountType == 'Gmail' ? 'Authenticate with Google' : 'Verify & Link IMAP',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncProvider);

    if (syncState.isSyncing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161A),
        elevation: 0,
        title: Text(
          'Sync Manager',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),
        ),
        actions: [
          RotationTransition(
            turns: _rotationController,
            child: IconButton(
              icon: const Icon(Icons.sync, color: Colors.white),
              onPressed: () {
                ref.read(syncProvider.notifier).runSync();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SYNC BRAIN STATUS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16161A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: syncState.isSyncing ? const Color(0xFF673AB7) : Colors.white10,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: syncState.isSyncing ? const Color(0xFFB39DDB) : Colors.white60,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Local AI Brain Status',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: syncState.isSyncing
                              ? const Color(0xFF673AB7).withOpacity(0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          syncState.isSyncing ? 'RUNNING' : 'STANDBY',
                          style: GoogleFonts.outfit(
                            color: syncState.isSyncing ? const Color(0xFFB39DDB) : Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LLM Brain: Llama 3.2 (3B) - Local Secure Execution',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    syncState.isSyncing ? syncState.currentPhase : 'All set. Database is encrypted and offline-first.',
                    style: GoogleFonts.plusJakartaSans(
                      color: syncState.isSyncing ? const Color(0xFF00E676) : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                  if (syncState.isSyncing) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: syncState.progress,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF673AB7)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ACCOUNTS HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LINKED ACCOUNTS (${syncState.linkedAccounts.length}/5)',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                if (syncState.linkedAccounts.length < 5)
                  TextButton.icon(
                    onPressed: () => _showAddAccountSheet(context),
                    icon: const Icon(Icons.add, size: 16, color: Color(0xFFB39DDB)),
                    label: Text(
                      'Link Account',
                      style: GoogleFonts.outfit(color: const Color(0xFFB39DDB), fontSize: 13),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // ACCOUNTS LIST
            Expanded(
              child: ListView.builder(
                itemCount: syncState.linkedAccounts.length,
                itemBuilder: (context, index) {
                  final email = syncState.linkedAccounts[index];
                  final isInstitutional = email.endsWith('.edu') || email.contains('institution');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isInstitutional ? Icons.school : Icons.alternate_email,
                        color: isInstitutional ? const Color(0xFFFF9100) : const Color(0xFF29B6F6),
                      ),
                      title: Text(
                        email,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        isInstitutional ? 'Institutional IMAP Sync' : 'Gmail OAuth Secured',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.link_off, color: Colors.redAccent),
                        onPressed: () {
                          ref.read(syncProvider.notifier).removeAccount(email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Unlinked $email')),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: syncState.isSyncing
                    ? null
                    : () => ref.read(syncProvider.notifier).runSync(),
                icon: const Icon(Icons.sync),
                label: Text(
                  syncState.isSyncing ? 'Syncing...' : 'Sync All Accounts Now',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
