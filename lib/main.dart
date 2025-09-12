import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const TaskReminderApp());
}

/// 🌈 Color Palette
class AppColors {
  // Light Mode Colors (with dark accents)
  static const lightPrimary = Color(0xFF9A48D0); // Dark Purple
  static const lightSecondary = Color(0xFF63458A); // Deep Purple
  static const lightBg = Color(0xFFF5F5F5); // Light background
  static const lightSurface = Color(0xFFE0E0E0); // Darker card surface
  static const lightTextPrimary = Color(0xFF212121);
  static const lightTextSecondary = Color(0xFF424242);
  static const lightWarning = Color(0xFFD84315); // Dark orange
  static const lightSuccess = Color(0xFF2E7D32); // Dark green

  // Dark Mode Colors
  static const darkPrimary = Color(0xFFE4B7E5); // Light Lavender
  static const darkSecondary = Color(0xFFB288C0); // Light Purple
  static const darkBg = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkTextPrimary = Color(0xFFE0E0E0);
  static const darkTextSecondary = Color(0xFF9E9E9E);
  static const darkWarning = Color(0xFFFF7043);
  static const darkSuccess = Color(0xFF81C784);
}

/// Task model
class Task {
  String title;
  DateTime time;
  bool isCompleted;

  Task({required this.title, required this.time, this.isCompleted = false});
}

/// Main App
class TaskReminderApp extends StatefulWidget {
  const TaskReminderApp({super.key});

  @override
  State<TaskReminderApp> createState() => _TaskReminderAppState();
}

class _TaskReminderAppState extends State<TaskReminderApp> {
  bool _isDarkTheme = false;
  int _selectedIndex = 0;

  final List<Task> _tasks = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadTasks();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(settings);
  }

  Future<void> _scheduleNotification(Task task) async {
    await _notificationsPlugin.zonedSchedule(
      task.hashCode,
      'Task Reminder',
      task.title,
      tz.TZDateTime.from(task.time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          channelDescription: 'Reminder notifications for tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskStrings = _tasks
        .map((task) =>
            '${task.title}|${task.time.toIso8601String()}|${task.isCompleted}')
        .toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? taskStrings = prefs.getStringList('tasks');
    if (taskStrings != null) {
      setState(() {
        _tasks.clear();
        _tasks.addAll(taskStrings.map((str) {
          final parts = str.split('|');
          return Task(
            title: parts[0],
            time: DateTime.parse(parts[1]),
            isCompleted: parts[2] == 'true',
          );
        }).toList());
      });
    }
  }

  void _addTask(String title, DateTime time) {
    final newTask = Task(title: title, time: time);
    setState(() {
      _tasks.add(newTask);
      _selectedIndex = 0;
    });
    _scheduleNotification(newTask);
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    _saveTasks();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        key: const ValueKey('home'),
        tasks: _tasks,
        toggleTask: _toggleTaskCompletion,
        deleteTask: _deleteTask,
        isDark: _isDarkTheme,
      ),
      AddTaskScreen(
        key: const ValueKey('add'),
        addTask: _addTask,
        isDark: _isDarkTheme,
      ),
      SettingsScreen(
        key: const ValueKey('settings'),
        isDark: _isDarkTheme,
        onToggleTheme: () {
          setState(() {
            _isDarkTheme = !_isDarkTheme;
          });
        },
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppColors.darkBg,
              cardColor: AppColors.darkSurface,
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: AppColors.lightBg,
              cardColor: AppColors.lightSurface,
            ),
      home: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(Icons.home, 0),
                const SizedBox(width: 40),
                _buildNavIcon(Icons.settings, 2),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor:
              _isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,
          child: const Icon(Icons.add),
          onPressed: () => _onNavBarTap(1),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    Color color;
    if (_isDarkTheme) {
      color = isSelected ? AppColors.darkPrimary : Colors.grey;
    } else {
      color = isSelected ? AppColors.lightPrimary : Colors.grey;
    }
    return IconButton(
        icon: Icon(icon, color: color), onPressed: () => _onNavBarTap(index));
  }
}

/// ---------------- HOME SCREEN ----------------
class HomeScreen extends StatelessWidget {
  final List<Task> tasks;
  final Function(int) toggleTask;
  final Function(int) deleteTask;
  final bool isDark;

  const HomeScreen(
      {super.key,
      required this.tasks,
      required this.toggleTask,
      required this.deleteTask,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return tasks.isEmpty
        ? Center(
            child: Text(
              "No tasks yet",
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 18,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              Color statusColor;
              if (task.isCompleted) {
                statusColor =
                    isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
              } else if (task.time.isBefore(DateTime.now())) {
                statusColor =
                    isDark ? AppColors.darkWarning : AppColors.lightWarning;
              } else {
                statusColor =
                    isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                      left: BorderSide(width: 6, color: statusColor)),
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => toggleTask(index),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                  ),
                  subtitle: Text(
                      "Reminder: ${task.time.hour.toString().padLeft(2, '0')}:${task.time.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(color: statusColor)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteTask(index),
                  ),
                ),
              );
            });
  }
}

/// ---------------- ADD TASK SCREEN ----------------
class AddTaskScreen extends StatefulWidget {
  final Function(String, DateTime) addTask;
  final bool isDark;

  const AddTaskScreen({super.key, required this.addTask, required this.isDark});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  DateTime selectedTime = DateTime.now().add(const Duration(minutes: 1));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Task Title",
                labelStyle: TextStyle(
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                prefixIcon: Icon(Icons.task,
                    color: widget.isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary),
              onPressed: () async {
                final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedTime));
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        pickedTime.hour,
                        pickedTime.minute);
                  });
                }
              },
              icon: const Icon(Icons.access_time),
              label: Text(
                  "Pick Time: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDark
                      ? AppColors.darkSecondary
                      : AppColors.lightSecondary),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  widget.addTask(titleController.text, selectedTime);
                  titleController.clear();
                }
              },
              icon: const Icon(Icons.add_task),
              label: const Text("Add Task", style: TextStyle(color: Colors.white)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// ---------------- SETTINGS SCREEN ----------------
class SettingsScreen extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SettingsScreen({super.key, required this.isDark, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
        ),
        onPressed: onToggleTheme,
        icon: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: isDark ? Colors.black : Colors.white,
        ),
        label: Text(
          isDark ? "Switch to Light Theme" : "Switch to Dark Theme",
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
