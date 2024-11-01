import 'package:flutter/material.dart';

class SleepStatisticsScreen extends StatelessWidget {
  final Map<String, double> sleepData;
  final DateTime selectedDate;
  final String Function(double) getSleepQuality;
  final Color Function(double) getSleepQualityColor;
  final double Function() getWeeklyAverage;
  final VoidCallback previousDay;
  final VoidCallback nextDay;
  final Map<String, List<Map<String, dynamic>>> sleepPhases;

  const SleepStatisticsScreen({
    Key? key,
    required this.sleepData,
    required this.selectedDate,
    required this.getSleepQuality,
    required this.getSleepQualityColor,
    required this.getWeeklyAverage,
    required this.previousDay,
    required this.nextDay,
    required this.sleepPhases,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dateKey =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
    double todaySleep = sleepData[dateKey] ?? 0;
    double weeklyAverage = getWeeklyAverage();
    List<Map<String, dynamic>> todayPhases = sleepPhases[dateKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Statistics'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Navigation
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: previousDay,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: nextDay,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Daily Sleep Stats
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Sleep Statistics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Hours Slept'),
                          trailing: Text(
                            '${todaySleep.toStringAsFixed(1)} hours',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListTile(
                          title: const Text('Sleep Quality'),
                          trailing: Text(
                            getSleepQuality(todaySleep),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: getSleepQualityColor(todaySleep),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sleep Phases
                if (todayPhases.isNotEmpty)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sleep Phases',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          ...todayPhases.map((phase) {
                            DateTime start = DateTime.parse(phase['start']);
                            DateTime end = DateTime.parse(phase['end']);
                            return ListTile(
                              title: Text(
                                '${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Duration: ${phase['duration'].toStringAsFixed(1)} hours',
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Weekly Average
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Overview',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Weekly Average'),
                          trailing: Text(
                            '${weeklyAverage.toStringAsFixed(1)} hours',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListTile(
                          title: const Text('Average Quality'),
                          trailing: Text(
                            getSleepQuality(weeklyAverage),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: getSleepQualityColor(weeklyAverage),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
