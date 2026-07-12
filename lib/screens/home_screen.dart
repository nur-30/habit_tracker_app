import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_habit_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditHabitScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Habit Baru'),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          if (!provider.isReady) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = provider.habits;

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: _SummaryBanner(
                    total: habits.length,
                    doneToday: provider.completedTodayCount,
                  ),
                ),
                Expanded(
                  child: habits.isEmpty
                      ? const EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            return HabitCard(
                              habit: habit,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HabitDetailScreen(habit: habit),
                                  ),
                                );
                              },
                              onToggleToday: () =>
                                  provider.toggleToday(habit),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final int total;
  final int doneToday;

  const _SummaryBanner({required this.total, required this.doneToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              total == 0
                  ? 'Yuk mulai habit pertamamu hari ini!'
                  : 'Hari ini: $doneToday dari $total habit selesai',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
