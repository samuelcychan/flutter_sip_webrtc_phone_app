import "package:flutter/material.dart";
import "package:flutter/widgets.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _serverAddrController;
  late TextEditingController _accountNameController;
  late TextEditingController _accountPasswordController;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            const Text("server addr:"),
            TextField(
              controller: _serverAddrController,
            ),
            // format / length
          ],
        )),
        Expanded(
            child: Row(
          children: [
            const Text("user account:"),
            TextField(
              controller: _accountNameController,
            ),
            // format / length
          ],
        )),
        Expanded(
            child: Row(
          children: [
            const Text("user password:"),
            TextField(
              controller: _accountPasswordController,
            ),
            // format / length
          ],
        )),
      ],
    );
  }
}
