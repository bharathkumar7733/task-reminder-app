import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_reminder_app/main.dart';

void main() {
  testWidgets('Home screen shows "No tasks yet" initially',
      (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const TaskReminderApp());

    // Verify that the home screen shows "No tasks yet"
    expect(find.text('No tasks yet'), findsOneWidget);
  });

  testWidgets('Tapping FAB navigates to Add Task screen',
      (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const TaskReminderApp());

    // Tap the FloatingActionButton (FAB)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify that AddTaskScreen is displayed by checking for "Add Task" button
    expect(find.text('Add Task'), findsOneWidget);

    // Verify that the Time Picker button exists
    expect(find.textContaining('Pick Time:'), findsOneWidget);
  });

  testWidgets('Adding a task shows it in Home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TaskReminderApp());

    // Navigate to Add Task screen
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter a task title
    await tester.enterText(find.byType(TextField), 'Test Task');

    // Tap Add Task button
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    // Verify that the task appears in HomeScreen
    expect(find.text('Test Task'), findsOneWidget);
  });
}
