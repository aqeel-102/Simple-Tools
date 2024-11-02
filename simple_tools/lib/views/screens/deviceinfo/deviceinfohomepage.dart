import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:system_info2/system_info2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DeviceInfoHomePage extends StatefulWidget {
  const DeviceInfoHomePage({super.key});

  @override
  State<DeviceInfoHomePage> createState() => _DeviceInfoHomePageState();
}

class _DeviceInfoHomePageState extends State<DeviceInfoHomePage>
    with SingleTickerProviderStateMixin {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  late final TabController _tabController;

  // Data maps for different sections
  final Map<String, dynamic> _deviceData = {};
  final Map<String, dynamic> _systemData = {};
  final Map<String, dynamic> _storageData = {};
  final Map<String, dynamic> _sensorData = {};
  final Map<String, dynamic> _batteryData = {};

  // Subscriptions and timers
  Timer? _refreshTimer;
  StreamSubscription? _batterySubscription;
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;

  static const _updateInterval = Duration(seconds: 2);
  static const _progressBarWidth = 100.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeDataStreams();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 5, vsync: this);
    _refreshTimer =
        Timer.periodic(_updateInterval, (_) => _updateSystemStats());
  }

  void _initializeDataStreams() async {
    await _initializeDeviceInfo();
    await _updateSystemStats();
    await _getStorageInfo();
    _initializeSensors();
    _initializeBattery();
  }

  void _initializeSensors() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (!mounted) return;
      setState(() {
        _sensorData['Accelerometer'] = {
          'X-Axis': event.x.toStringAsFixed(2),
          'Y-Axis': event.y.toStringAsFixed(2),
          'Z-Axis': event.z.toStringAsFixed(2),
        };
      });
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      if (!mounted) return;
      setState(() {
        _sensorData['Gyroscope'] = {
          'X-Axis': event.x.toStringAsFixed(2),
          'Y-Axis': event.y.toStringAsFixed(2),
          'Z-Axis': event.z.toStringAsFixed(2),
        };
      });
    });
  }

  void _initializeBattery() {
    _batterySubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) async {
      if (!mounted) return;

      final level = await _battery.batteryLevel;
      final isInPowerSaveMode = await _battery.isInBatterySaveMode;

      setState(() {
        _batteryData.addAll({
          'Battery Level': '$level%',
          'Charging Status': _getBatteryStateString(state),
          'Power Save Mode': isInPowerSaveMode ? 'Enabled' : 'Disabled',
        });
      });
    });
  }

  String _getBatteryStateString(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      default:
        return 'Unknown';
    }
  }

  Future<void> _updateSystemStats() async {
    if (!mounted) return;

    setState(() {
      _systemData.addAll({
        'CPU Cores': SysInfo.cores.length,
        'CPU Architecture': SysInfo.kernelArchitecture,
        'Total RAM': _formatBytes(SysInfo.getTotalPhysicalMemory()),
        'Free RAM': _formatBytes(SysInfo.getFreePhysicalMemory()),
        'RAM Usage': _calculateRamUsage(),
      });
    });
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${bytes.toStringAsFixed(2)} B';
  }

  String _calculateRamUsage() {
    final total = SysInfo.getTotalPhysicalMemory();
    final free = SysInfo.getFreePhysicalMemory();
    final usagePercentage = ((total - free) / total * 100).toStringAsFixed(1);
    return '$usagePercentage%';
  }

  String _formatBytesToGBorMB(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  Future<void> _getStorageInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = directory.statSync();
      final total = directory.parent.parent.parent.statSync();

      final totalBytes = total.size;
      final usedBytes = stat.size;
      final freeBytes = totalBytes - usedBytes;
      final usagePercentage = (usedBytes / totalBytes * 100).toStringAsFixed(1);

      setState(() {
        _storageData.addAll({
          'Total Storage': _formatBytesToGBorMB(totalBytes),
          'Used Storage': _formatBytesToGBorMB(usedBytes),
          'Free Storage': _formatBytesToGBorMB(freeBytes),
          'Storage Usage': '$usagePercentage%',
        });
      });
    } catch (e) {
      setState(() {
        _storageData['Error'] = 'Storage information unavailable';
      });
    }
  }

  Future<void> _initializeDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceData.addAll(_getAndroidDeviceInfo(androidInfo));
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceData.addAll(_getIOSDeviceInfo(iosInfo));
      }
      setState(() {});
    } on PlatformException catch (e) {
      setState(() {
        _deviceData['Error'] = 'Failed to get device information: ${e.message}';
      });
    }
  }

  Map<String, String> _getAndroidDeviceInfo(AndroidDeviceInfo info) {
    return {
      'Device Model': info.model,
      'Manufacturer': info.manufacturer,
      'Android Version': '${info.version.release} (SDK ${info.version.sdkInt})',
      'Security Patch': info.version.securityPatch ?? 'Unknown',
      'Hardware': info.hardware,
      'Brand': info.brand,
      'Device Type': info.isPhysicalDevice ? 'Physical Device' : 'Emulator',
    };
  }

  Map<String, String> _getIOSDeviceInfo(IosDeviceInfo info) {
    return {
      'Device Model': info.model,
      'System Name': info.systemName,
      'System Version': info.systemVersion,
      'Device Name': info.name,
      'Device Type': info.isPhysicalDevice ? 'Physical Device' : 'Simulator',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.hardware), text: 'Hardware'),
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.storage), text: 'Storage'),
            Tab(icon: Icon(Icons.sensors), text: 'Sensors'),
            Tab(icon: Icon(Icons.battery_full), text: 'Battery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoList(_deviceData),
          _buildInfoList(_systemData, progressKey: 'RAM Usage'),
          _buildInfoList(_storageData, progressKey: 'Storage Usage'),
          _buildSensorsTab(),
          _buildInfoList(_batteryData, progressKey: 'Battery Level'),
        ],
      ),
    );
  }

  Widget _buildInfoList(Map<String, dynamic> data, {String? progressKey}) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final entry = data.entries.elementAt(index);
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              entry.value?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
            trailing: progressKey != null && entry.key == progressKey
                ? SizedBox(
                    width: _progressBarWidth,
                    child: LinearProgressIndicator(
                      value: double.parse(
                              entry.value.toString().replaceAll('%', '')) /
                          100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildSensorsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _sensorData.length,
      itemBuilder: (context, index) {
        final entry = _sensorData.entries.elementAt(index);
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    _batterySubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }
}
