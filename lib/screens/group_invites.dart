import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../providers/groups.dart';
import '../providers/invites.dart';
import '../services/api.dart';

class GroupInvitesScreen extends StatefulWidget {
  static const routeName = '/invites';
  final String groupId;

  const GroupInvitesScreen({Key key, this.groupId}) : super(key: key);

  @override
  _GroupInvitesScreenState createState() => _GroupInvitesScreenState();
}

class _GroupInvitesScreenState extends State<GroupInvitesScreen> {
  Future<void> _fetchInvitesFuture;
  TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _fetchInvites();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvites() async {
    _fetchInvitesFuture = Future.microtask(() => Provider.of<InvitesProvider>(
          context,
          listen: false,
        ).fetchGroupInvites(widget.groupId));
  }

  Future<void> _addInvite() async {
//    TODO: validation
    final String email = _emailController.text;
    try {
      bool created = await Provider.of<InvitesProvider>(context, listen: false)
          .createInvite(widget.groupId, email);
      _emailController.clear();
      if (!created) {
        _showMessage('Success',
            'This user already has an account and has been added to the group directly.');
        // Refetch group to get new members
        Provider.of<GroupsProvider>(context, listen: false)
            .fetchGroup(widget.groupId);
      }
    } on ApiError catch (e) {
      _showMessage('Error', e.message);
    } catch (e) {
      _showMessage('Error', 'Failed to create invite. Please try again');
    }
  }

  Future<void> _deleteInvite(String id) async {
    try {
      await Provider.of<InvitesProvider>(context, listen: false)
          .deleteGroupInvite(groupId: widget.groupId, inviteId: id);
    } on ApiError catch (e) {
      _showMessage('Error', e.message);
    } catch (e) {
      _showMessage('Error', 'Failed to create invite. Please try again');
    }
  }

  void _showMessage(String title, String message) async {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invites = Provider.of<InvitesProvider>(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Invites'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Column(
            children: <Widget>[
              Flexible(
                child: FutureBuilder(
                    future: _fetchInvitesFuture,
                    builder: (_, AsyncSnapshot<void> snapshot) {
                      if (snapshot.hasData) {
                        return invites.countByGroupId(widget.groupId) == 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.email,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No invites',
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .copyWith(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    child: Text(
                                      'Add an invite by entering an email and pressing the button below',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount:
                                    invites.countByGroupId(widget.groupId),
                                itemBuilder: (_, i) {
                                  final invite =
                                      invites.byGroupId(widget.groupId)[i];
                                  return ListTile(
                                    title: Text(
                                      invite.email,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Theme.of(context).errorColor,
                                      ),
                                      onPressed: () => _deleteInvite(
                                        invite.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error'),
                        );
                      }
                      return Center(
                        child: PlatformCircularProgressIndicator(),
                      );
                    }),
              ),
              const Divider(height: 1),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).platform == TargetPlatform.iOS
                      ? CupertinoTheme.of(context).scaffoldBackgroundColor
                      : Theme.of(context).cardColor,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: PlatformTextField(
                          autofocus: true,
                          autocorrect: false,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.send,
                          android: (_) => MaterialTextFieldData(
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Email',
                            ),
                          ),
                          ios: (_) => CupertinoTextFieldData(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            placeholder: 'Email',
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CupertinoDynamicColor.withBrightness(
                                  color: Color(0x33000000),
                                  darkColor: Color(0x33FFFFFF),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(200),
                            ),
                          ),
                          onSubmitted: (_) {
                            if (!invites.isFetching) {
                              _addInvite();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 1, width: 6),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          child: GestureDetector(
                            onTap: invites.isFetching ? null : _addInvite,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: PlatformWidget(
                                ios: (_) => const Icon(
                                  CupertinoIcons.up_arrow,
                                  color: Colors.white,
                                ),
                                android: (_) => const Icon(Icons.send),
                              ),
                            ),
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
    );
  }
}
