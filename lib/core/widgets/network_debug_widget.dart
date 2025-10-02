import 'package:flutter/material.dart';
import '../services/debug_service.dart';
import '../services/network_test_service.dart';
import '../services/ip_test_service.dart';

class NetworkDebugWidget extends StatefulWidget {
  const NetworkDebugWidget({super.key});

  @override
  State<NetworkDebugWidget> createState() => _NetworkDebugWidgetState();
}

class _NetworkDebugWidgetState extends State<NetworkDebugWidget> {
  bool _isLoading = false;
  String _results = '';

  Future<void> _runNetworkTests() async {
    setState(() {
      _isLoading = true;
      _results = '';
    });

    try {
      print('Starting network tests...');
      await NetworkTestService.testConnection();
      await DebugService.debugLogin();
      await DebugService.testAllCredentials();
      
      setState(() {
        _results = 'Tests completed! Check the console for detailed results.';
      });
    } catch (e) {
      setState(() {
        _results = 'Test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAllIPs() async {
    setState(() {
      _isLoading = true;
      _results = '';
    });

    try {
      print('Testing all IP addresses...');
      await IpTestService.testAllIpAddresses();
      
      setState(() {
        _results = 'IP tests completed! Check the console for results.';
      });
    } catch (e) {
      setState(() {
        _results = 'IP test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Network Connectivity Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will test your API connectivity and authentication. Check the console for detailed logs.',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _runNetworkTests,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Run Network Tests'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAllIPs,
              child: const Text('Test All IP Addresses'),
            ),
            const SizedBox(height: 24),
            if (_results.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _results,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Common Solutions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Make sure your backend server is running\n'
              '2. Check if 172.17.0.1:8080 is accessible\n'
              '3. Try using 10.0.2.2:8080 for Android emulator\n'
              '4. Use correct email: petowner1@email.com\n'
              '5. Check firewall settings',
            ),
          ],
        ),
      ),
    );
  }
}
