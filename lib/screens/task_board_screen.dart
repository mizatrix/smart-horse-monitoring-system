
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class TaskBoardScreen extends StatefulWidget {
  const TaskBoardScreen({super.key});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  int _selectedColumn = 0;

  List<Map<String, String>> _getColumns(String lang) => [
    {'title': AppStrings.get('to_do', lang)},
    {'title': AppStrings.get('in_progress', lang)},
    {'title': AppStrings.get('done', lang)},
  ];

  final List<List<Map<String, dynamic>>> _tasks = [
    // To Do
    [
      {'title': 'Vaccinate Spirit 3', 'staff': 'Dr. Sarah', 'priority': 'High', 'category': '💉 Medical', 'est': '30 min'},
      {'title': 'Order hay bales', 'staff': 'Ahmed', 'priority': 'Medium', 'category': '📦 Inventory', 'est': '15 min'},
      {'title': 'Fix paddock gate B', 'staff': 'Omar', 'priority': 'High', 'category': '🔧 Maintenance', 'est': '2 hrs'},
      {'title': 'Schedule farrier visit', 'staff': 'Fatima', 'priority': 'Low', 'category': '📅 Admin', 'est': '10 min'},
    ],
    // In Progress
    [
      {'title': 'Groom all horses', 'staff': 'Fatima', 'priority': 'Medium', 'category': '✨ Grooming', 'est': '3 hrs'},
      {'title': 'Vitals check — Stall Row A', 'staff': 'Dr. Ahmed', 'priority': 'High', 'category': '❤️ Health', 'est': '45 min'},
    ],
    // Done
    [
      {'title': 'Morning feed — all stalls', 'staff': 'Ahmed', 'priority': 'High', 'category': '🌾 Feeding', 'est': '45 min'},
      {'title': 'Water trough check', 'staff': 'Omar', 'priority': 'High', 'category': '💧 Water', 'est': '15 min'},
      {'title': 'Stall mucking — Row B', 'staff': 'Omar', 'priority': 'Medium', 'category': '🧹 Cleaning', 'est': '90 min'},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.05);
    final tabBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

    final columns = _getColumns(lang);
    final columnColors = [Colors.blue, Colors.orange, Colors.green];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppStrings.get('task_board', lang), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Column tabs
            Container(
              decoration: BoxDecoration(color: tabBg, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: columns.asMap().entries.map((entry) {
                  bool isSelected = _selectedColumn == entry.key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedColumn = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? columnColors[entry.key] : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(children: [
                          Text(entry.value['title']!, style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : subtextColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          )),
                          Text('${_tasks[entry.key].length}', style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white70 : subtextColor,
                            fontSize: 10,
                          )),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Tasks
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _tasks[_selectedColumn].length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _tasks[_selectedColumn].removeAt(oldIndex);
                    _tasks[_selectedColumn].insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final task = _tasks[_selectedColumn][index];
                  Color priorityColor = task['priority'] == 'High' ? Colors.red : (task['priority'] == 'Medium' ? Colors.orange : Colors.green);
                  String priorityText = task['priority'] == 'High' ? AppStrings.get('high', lang)
                      : task['priority'] == 'Medium' ? AppStrings.get('medium', lang)
                      : AppStrings.get('low', lang);
                  bool isDone = _selectedColumn == 2;

                  return Container(
                    key: ValueKey('${_selectedColumn}_$index'),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
                      border: isDone ? Border.all(color: Colors.green.withOpacity(0.15)) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4, height: 40,
                          decoration: BoxDecoration(color: columnColors[_selectedColumn], borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Flexible(child: Text(task['title'], style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 13, color: textColor,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ))),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text(priorityText, style: GoogleFonts.poppins(fontSize: 8, color: priorityColor, fontWeight: FontWeight.bold)),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Row(children: [
                                Text(task['category'], style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                                Text(' • ', style: GoogleFonts.poppins(color: subtextColor)),
                                Icon(Icons.person_outline, size: 12, color: subtextColor),
                                const SizedBox(width: 2),
                                Text(task['staff'], style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                                Text(' • ', style: GoogleFonts.poppins(color: subtextColor)),
                                Icon(Icons.timer_outlined, size: 12, color: subtextColor),
                                const SizedBox(width: 2),
                                Text(task['est'], style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                              ]),
                            ],
                          ),
                        ),
                        if (!isDone)
                          PopupMenuButton<int>(
                            icon: Icon(Icons.more_vert, color: subtextColor, size: 18),
                            color: cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (val) {
                              setState(() {
                                final item = _tasks[_selectedColumn].removeAt(index);
                                _tasks[val].add(item);
                              });
                            },
                            itemBuilder: (context) {
                              return columns.asMap().entries
                                  .where((e) => e.key != _selectedColumn)
                                  .map((e) => PopupMenuItem<int>(value: e.key, child: Text(e.value['title']!, style: GoogleFonts.poppins(fontSize: 13, color: textColor))))
                                  .toList();
                            },
                          )
                        else
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
