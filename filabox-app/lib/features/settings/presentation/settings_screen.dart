import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('跟随系统'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (_) {},
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('语言 / Language'),
            subtitle: Text('中文'),
          ),
          const ListTile(
            leading: Icon(Icons.sync),
            title: Text('数据同步'),
            subtitle: Text('未连接'),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('关于 FilaBox'),
            subtitle: Text('v0.1.0'),
          ),
        ],
      ),
    );
  }
}
