import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teacher_provider.dart';
import '../models/teacher_model.dart';
import '../utils/theme.dart';

class AccountBlockingScreen extends StatefulWidget {
  const AccountBlockingScreen({super.key});

  @override
  State<AccountBlockingScreen> createState() => _AccountBlockingScreenState();
}

class _AccountBlockingScreenState extends State<AccountBlockingScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedPlatform = 'Instagram';
  String _selectedBlockType = 'session_based';
  DateTime _blockedUntilDate = DateTime.now().add(const Duration(hours: 2));

  final List<String> _platforms = [
    'Instagram',
    'Facebook',
    'YouTube',
    'Twitter',
    'TikTok',
    'Snapchat',
    'Reddit',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _platformToKey(String platform) => platform.toLowerCase();

  String _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram': return '📷';
      case 'facebook': return '👤';
      case 'youtube': return '▶️';
      case 'twitter': return '🐦';
      case 'tiktok': return '🎵';
      case 'snapchat': return '👻';
      case 'reddit': return '🤖';
      default: return '🌐';
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram': return const Color(0xFFE4405F);
      case 'facebook': return const Color(0xFF1877F2);
      case 'youtube': return const Color(0xFFFF0000);
      case 'twitter': return const Color(0xFF1DA1F2);
      case 'tiktok': return const Color(0xFFEE1D52);
      case 'snapchat': return const Color(0xFFFFFC00);
      case 'reddit': return const Color(0xFFFF4500);
      default: return AppColors.primary;
    }
  }

  void _blockAccount() {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }

    final provider = context.read<TeacherProvider>();
    provider.addBlockedAccount(
      _platformToKey(_selectedPlatform),
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _selectedBlockType,
      _blockedUntilDate,
    );

    _usernameController.clear();
    _emailController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedPlatform} account blocked successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _blockedUntilDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _blockedUntilDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<TeacherProvider>();
    final blockedAccounts = teacherProvider.blockedAccounts;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Blocking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Account-Level Blocking',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Block your social media accounts across all devices during study sessions. This prevents you from logging in anywhere.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Add Account Form
            _buildAddAccountForm(),

            const SizedBox(height: 28),

            // Blocked Accounts List
            if (blockedAccounts.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Blocked Accounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${blockedAccounts.length} blocked',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...blockedAccounts.map((account) => _buildBlockedAccountCard(account, teacherProvider)),
            ],

            const SizedBox(height: 24),

            // Warning Card
            _buildWarningCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Account to Block',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Platform Dropdown
          DropdownButtonFormField<String>(
            value: _selectedPlatform,
            dropdownColor: AppColors.card,
            decoration: InputDecoration(
              labelText: 'Platform',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _getPlatformIcon(_selectedPlatform),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              filled: true,
              fillColor: AppColors.dark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
            items: _platforms.map((p) => DropdownMenuItem(
              value: p,
              child: Row(
                children: [
                  Text(_getPlatformIcon(p), style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Text(p, style: const TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            )).toList(),
            onChanged: (val) => setState(() => _selectedPlatform = val!),
          ),
          const SizedBox(height: 14),

          // Username Field
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: '@username',
              prefixIcon: const Icon(Icons.alternate_email, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.dark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Email Field
          TextField(
            controller: _emailController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Email (optional)',
              hintText: 'account@email.com',
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.dark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Block Type
          const Text(
            'Block Type',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBlockTypeChip('session_based', 'Session-based', Icons.timer_outlined),
              _buildBlockTypeChip('time_based', 'Time-based', Icons.calendar_today_outlined),
              _buildBlockTypeChip('until_exam', 'Until Exam', Icons.school_outlined),
            ],
          ),

          // Date picker for time-based or until exam
          if (_selectedBlockType != 'session_based') ...[
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Block until: ${_blockedUntilDate.day}/${_blockedUntilDate.month}/${_blockedUntilDate.year}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Block Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _blockAccount,
              icon: const Icon(Icons.block, size: 20),
              label: const Text(
                'Block This Account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedBlockType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedBlockType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedAccountCard(BlockedAccount account, TeacherProvider provider) {
    final isActive = account.isCurrentlyBlocked;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          // Platform icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getPlatformColor(account.platform).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                account.platformIcon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${account.username}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Active' : 'Expired',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? AppColors.accent : AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Until ${account.blockedUntil.day}/${account.blockedUntil.month}/${account.blockedUntil.year}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Toggle
          Switch(
            value: account.isActive,
            onChanged: (_) => provider.toggleBlockedAccount(account.id),
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withOpacity(0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surface,
          ),

          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
            onPressed: () => provider.removeBlockedAccount(account.id),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cross-Device Warning',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This will attempt to block access from ALL your devices. For best results, enable this on each device you own.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
