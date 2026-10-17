import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/user_data_repository.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../widgets/toast_notification.dart';
import '../reader/reader_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final UserDataRepository _repository = UserDataRepository();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await _repository.getReadingHistory();
    if (mounted) {
      setState(() {
        _history = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('വായനാ ചരിത്രം'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear history',
              onPressed: () async {
                await _repository.clearHistory();
                setState(() => _history = []);
                if (context.mounted) {
                  ToastNotification.show(context, 'വായനാ ചരിത്രം മായ്ച്ചു');
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 54, color: mutedColor.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'വായനാ ചരിത്രം ലഭ്യമല്ല.',
                        style: TextStyle(fontSize: 16, color: mutedColor),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: lineColor),
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final bookName = item['book_name'] as String? ?? item['book_code'] as String;
                    final chapter = item['chapter'] as int;
                    final timestamp = item['timestamp'] as int? ?? 0;
                    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                    final dateStr = '${date.day}/${date.month}/${date.year}';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Icon(Icons.menu_book, color: accentColor, size: 22),
                      title: Text(
                        '$bookName $chapter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        dateStr,
                        style: TextStyle(fontSize: 12, color: mutedColor),
                      ),
                      trailing: Icon(Icons.chevron_right, size: 18, color: mutedColor),
                      onTap: () async {
                        final nav = context.read<BibleNavigationProvider>();
                        nav.navigateTo(item['book_code'] as String, chapter);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReaderScreen()),
                        );
                        if (mounted) {
                          _loadHistory();
                        }
                      },
                    );
                  },
                ),
    );
  }
}
