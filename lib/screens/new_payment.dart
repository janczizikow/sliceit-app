import 'package:flutter/material.dart';

import '../widgets/platform_scaffold.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_text_field.dart';

class NewPaymentScreen extends StatefulWidget {
  static const routeName = '/new-payment';

  @override
  _NewPaymentScreenState createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends State<NewPaymentScreen> {
  void _handleAddPayment() {}

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        actions: <Widget>[
          FlatButton(
            child: Text('SAVE'),
            onPressed: _handleAddPayment,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
