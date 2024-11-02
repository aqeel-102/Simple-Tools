import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:device_apps/device_apps.dart';

class UsageHomeScreen extends StatefulWidget {
  const UsageHomeScreen({super.key});

  @override
  State<UsageHomeScreen> createState() => _UsageHomeScreenState();
}

class _UsageHomeScreenState extends State<UsageHomeScreen>
    with SingleTickerProviderStateMixin {
  final _appState = AppState();
  late final UIBuilder _uiBuilder;
  final _appDataManager = AppDataManager();
  late TabController _tabController;
  int _totalScreenTime = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _uiBuilder = UIBuilder(context);
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    var granted = await UsageStats.checkUsagePermission() ?? false;

    if (!granted) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Permission Required',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'This app needs usage stats permission to track app usage. Please enable it in settings.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  UsageStats.grantUsagePermission();
                  Navigator.pop(context);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    await _appDataManager.initialize();
    var usageData = await _appDataManager.getAppUsageData();
    _totalScreenTime = usageData.fold(
        0, (sum, app) => sum + int.parse(app.totalTimeInForeground ?? '0'));
    setState(() => _appState.isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_appState.isLoading) {
      return _uiBuilder.buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppConstants.deviceUsage,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'All Apps'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAllAppsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalScreenTimeCard(),
          const SizedBox(height: 20),
          _buildUsageChart(),
          const SizedBox(height: 20),
          _buildMostUsedApps(),
        ],
      ),
    );
  }

  Widget _buildTotalScreenTimeCard() {
    final hours = _totalScreenTime ~/ (1000 * 60 * 60);
    final minutes = (_totalScreenTime ~/ (1000 * 60)) % 60;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'App Usage Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 400,
              child: FutureBuilder<List<UsageInfo>>(
                future: _appDataManager.getAppUsageData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final usageData = snapshot.data!;
                  usageData.sort((a, b) =>
                      int.parse(b.totalTimeInForeground ?? '0').compareTo(
                          int.parse(a.totalTimeInForeground ?? '0')));
                  final topApps = usageData.take(5).toList();

                  final totalTime = topApps.fold<double>(
                    0,
                    (sum, app) =>
                        sum + double.parse(app.totalTimeInForeground ?? '0'),
                  );

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: List.generate(topApps.length, (index) {
                                final appUsage = double.parse(
                                    topApps[index].totalTimeInForeground ??
                                        '0');
                                final percentage = (appUsage / totalTime) * 100;

                                return PieChartSectionData(
                                  color: Color.fromARGB(
                                    255,
                                    (index * 50 + 100) % 255,
                                    (index * 70 + 150) % 255,
                                    (index * 90 + 200) % 255,
                                  ),
                                  value: percentage,
                                  title: '',
                                  radius: 100,
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Today\'s Screen Time',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$hours h $minutes m',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          children: List.generate(topApps.length, (index) {
                            final appUsage = double.parse(
                                topApps[index].totalTimeInForeground ?? '0');
                            final percentage = (appUsage / totalTime) * 100;
                            final packageName =
                                topApps[index].packageName ?? '';
                            final appName = packageName.split('.').last;
                            final hours = appUsage ~/ (1000 * 60 * 60);
                            final minutes = (appUsage ~/ (1000 * 60)) % 60;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(
                                        255,
                                        (index * 50 + 100) % 255,
                                        (index * 70 + 150) % 255,
                                        (index * 90 + 200) % 255,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      appName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${hours}h ${minutes}m',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
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

  Widget _buildUsageChart() {
    return Container();
  }

  Widget _buildMostUsedApps() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Used Apps',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<UsageInfo>>(
              future: _appDataManager.getAppUsageData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final topApps = (snapshot.data ?? []).take(3).map((app) async {
                  final appInfo =
                      await DeviceApps.getApp(app.packageName ?? '');
                  return AppListItem(
                    packageName: app.packageName ?? '',
                    appName: appInfo?.appName ?? app.packageName ?? '',
                    usageTime: int.parse(app.totalTimeInForeground ?? '0'),
                    onSetLimit: () => _appDataManager.setAppLimit(
                        context, app.packageName ?? ''),
                  );
                }).toList();

                return FutureBuilder<List<Widget>>(
                  future: Future.wait(topApps),
                  builder: (context, appsSnapshot) {
                    if (!appsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(children: appsSnapshot.data!);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAppsTab() {
    return FutureBuilder<List<UsageInfo>>(
      future: _appDataManager.getAppUsageData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final usageData = snapshot.data ?? [];

        if (usageData.isEmpty) {
          return const Center(
            child: Text(
              'No usage data available.\nPlease ensure usage access is granted.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: usageData.length,
          itemBuilder: (context, index) {
            final appUsage = usageData[index];
            return FutureBuilder<Application?>(
              future: DeviceApps.getApp(appUsage.packageName ?? ''),
              builder: (context, appSnapshot) {
                if (!appSnapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final appInfo = appSnapshot.data!;
                return AppListItem(
                  packageName: appUsage.packageName ?? '',
                  appName: appInfo.appName,
                  usageTime: int.parse(appUsage.totalTimeInForeground ?? '0'),
                  onSetLimit: () => _appDataManager.setAppLimit(
                      context, appUsage.packageName ?? ''),
                  appIcon: appInfo is ApplicationWithIcon
                      ? Image.memory(appInfo.icon, width: 40, height: 40)
                      : const Icon(Icons.android, size: 40),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class AppState {
  bool isLoading = true;
}

class UIBuilder {
  final BuildContext context;

  UIBuilder(this.context);

  Widget buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDataManager {
  Map<String, int> appLimits = {};
  Map<String, AppInfo> appInfo = {};

  Future<void> initialize() async {
    await _loadAppLimits();
  }

  Future<void> _loadAppLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final limits = prefs.getStringList('appLimits') ?? [];

    appLimits = Map.fromEntries(limits.map((limit) {
      final parts = limit.split(':');
      return parts.length == 2 ? MapEntry(parts[0], int.parse(parts[1])) : null;
    }).whereType<MapEntry<String, int>>());
  }

  Future<List<UsageInfo>> getAppUsageData() async {
    final startDate = DateTime.now().subtract(const Duration(days: 1));
    final endDate = DateTime.now();

    try {
      bool? isPermissionGranted = await UsageStats.checkUsagePermission();
      if (isPermissionGranted != true) {
        throw Exception('Usage access not granted');
      }

      List<Application> installedApps =
          await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeSystemApps: false,
      );

      Set<String> installedPackages =
          installedApps.map((app) => app.packageName).toSet();

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      return usageStats
          .where((stats) =>
              stats.packageName != null &&
              stats.totalTimeInForeground != null &&
              int.parse(stats.totalTimeInForeground!) > 0 &&
              installedPackages.contains(stats.packageName))
          .toList();
    } catch (e) {
      print("Error fetching usage stats: $e");
      rethrow;
    }
  }

  Future<void> setAppLimit(BuildContext context, String packageName) async {
    final TextEditingController limitController =
        TextEditingController(text: appLimits[packageName]?.toString());

    await showDialog(
      context: context,
      builder: (context) => LimitDialog(
        packageName: packageName,
        controller: limitController,
        onSetLimit: (value) async {
          appLimits[packageName] = value;
          await _saveAppLimits();
        },
      ),
    );
  }

  Future<void> _saveAppLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final limits = appLimits.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('appLimits', limits);
  }
}

class AppInfo {
  final String packageName;
  final String appName;
  final Uint8List? icon;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.icon,
  });
}

class AppListItem extends StatelessWidget {
  final String packageName;
  final String appName;
  final int usageTime;
  final VoidCallback onSetLimit;
  final Widget? appIcon;

  const AppListItem({
    super.key,
    required this.packageName,
    required this.appName,
    required this.usageTime,
    required this.onSetLimit,
    this.appIcon,
  });

  String _formatDuration(int milliseconds) {
    final hours = milliseconds ~/ (1000 * 60 * 60);
    final minutes = (milliseconds ~/ (1000 * 60)) % 60;

    if (hours > 0) {
      return '$hours h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: appIcon ?? const Icon(Icons.android, size: 40),
        ),
        title: Text(
          appName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "Usage Time: ${_formatDuration(usageTime)}",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.timer,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: onSetLimit,
        ),
      ),
    );
  }
}

class LimitDialog extends StatelessWidget {
  final String packageName;
  final TextEditingController controller;
  final Function(int) onSetLimit;

  const LimitDialog({
    super.key,
    required this.packageName,
    required this.controller,
    required this.onSetLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Daily Limit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              packageName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildLimitTextField(),
            const SizedBox(height: 24),
            _buildDialogActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitTextField() {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        hintText: 'Enter limit in minutes',
        prefixIcon: const Icon(Icons.timer),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildDialogActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onSetLimit(int.parse(controller.text) * 60 * 1000);
              Navigator.pop(context);
            }
          },
          child: const Text(
            'Set Limit',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
