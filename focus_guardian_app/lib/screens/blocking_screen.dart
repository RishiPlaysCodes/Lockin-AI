import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class BlockingScreen extends StatefulWidget {
  const BlockingScreen({super.key});

  @override
  State<BlockingScreen> createState() => _BlockingScreenState();
}

class _BlockingScreenState extends State<BlockingScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  final List<Map<String, String>> _presets = [
    {'name': 'Instagram', 'url': 'instagram.com', 'category': 'social_media'},
    {'name': 'YouTube', 'url': 'youtube.com', 'category': 'entertainment'},
    {'name': 'Twitter', 'url': 'twitter.com', 'category': 'social_media'},
    {'name': 'TikTok', 'url': 'tiktok.com', 'category': 'social_media'},
    {'name': 'Reddit', 'url': 'reddit.com', 'category': 'social_media'},
    {'name': 'Netflix', 'url': 'netflix.com', 'category': 'entertainment'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _addSite() {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (name.isEmpty || url.isEmpty) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.addBlockedSite(name, url, 'custom');
    _nameController.clear();
    _urlController.clear();
    FocusScope.of(context).unfocus();
  }

  void _addPreset(Map<String, String> preset) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    // Check if already exists
    final exists = appProvider.blockedSites.any(
      (s) => s.url.toLowerCase() == preset['url']!.toLowerCase(),
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${preset['name']} is already in your list'),
          backgroundColor: AppColors.card,
        ),
      );
      return;
    }
    appProvider.addBlockedSite(preset['name']!, preset['url']!, preset['category']!);
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final sites = appProvider.blockedSites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Blocking'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Site to Block',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Site name (e.g. Facebook)',
                      prefixIcon: Icon(Icons.label_outline, color: AppColors.textMuted),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'URL (e.g. facebook.com)',
                      prefixIcon: Icon(Icons.link, color: AppColors.textMuted),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addSite,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Site'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick presets
            const Text(
              'Quick Add',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                return GestureDetector(
                  onTap: () => _addPreset(preset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          preset['name']!,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Blocked sites list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Blocked Sites',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${sites.where((s) => s.isActive).length} active',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (sites.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.block, size: 36, color: AppColors.textMuted),
                    SizedBox(height: 10),
                    Text(
                      'No blocked sites yet',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add sites to block during focus sessions',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...sites.map((site) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: site.isActive
                              ? AppColors.accent.withOpacity(0.12)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.block,
                          color: site.isActive ? AppColors.accent : AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              site.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              site.url,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: site.isActive,
                        onChanged: (_) => appProvider.toggleBlockedSite(site.id),
                        activeColor: AppColors.primary,
                      ),
                      GestureDetector(
                        onTap: () => appProvider.removeBlockedSite(site.id),
                        child: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
