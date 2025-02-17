import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mcumgr_flutter_example/src/firmware_list.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mcumgr_flutter_example/src/utils/set_ext.dart';
import 'package:mcumgr_flutter_example/src/utils/string_ext.dart';

class DeviceList extends StatelessWidget {
  final flutterBluePlus = FlutterBluePlus.instance;

  DeviceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    flutterBluePlus.startScan(timeout: Duration(seconds: 2));
    return StreamBuilder(
        stream: flutterBluePlus.scanResults.scan<Set<ScanResult>>((accumulated, value, index) => ((accumulated) ?? Set()).concat(value.toSet()), Set()),
        builder: (c, s) {
          if ((s.connectionState == ConnectionState.active || s.connectionState == ConnectionState.done) && s.hasData) {
            return _buildListView((s.data as Set<ScanResult>).toList());
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  ListView _buildListView(List<ScanResult> scanResults) {
    return ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (c, i) {
          final sr = scanResults[i];
          return _buildListTile(sr, c);
        });
  }

  GestureDetector _buildListTile(ScanResult sr, BuildContext c) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            c,
            MaterialPageRoute(
                builder: (c) => FirmwareList(
                      deviceId: sr.device.id.id,
                    )));
      },
      child: ListTile(
        title: Text(sr.advertisementData.localName.replaceIfEmpty('n/a')),
        trailing: Text(
          sr.rssi.toString() + ' dB',
          style: Theme.of(c).textTheme.titleMedium,
        ),
      ),
    );
  }
}
