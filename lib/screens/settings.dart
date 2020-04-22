import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import './edit_email.dart';
import './edit_name.dart';
import '../providers/account.dart';
import '../providers/auth.dart';
import '../providers/base.dart';
import '../providers/expenses.dart';
import '../providers/groups.dart';
import '../providers/invites.dart';
import '../utils/constants.dart';
import '../widgets/avatar.dart';
import '../widgets/loading_dialog.dart';

enum MoreMenuOptions {
  edit,
  logout,
}

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final double _appBarHeight = 128;
  double _fabOffsetTop = 128; // initalize with equal value as _appBarHeight
  double _titlePadding = 16;
  bool _isFabVisible = true;
  ScrollController _scrollController;
  File _image;
  Future<PackageInfo> _loadPackageInfo;
  final String _platform = Platform.isAndroid
      ? 'Android'
      : Platform.isIOS ? 'iOS' : Platform.operatingSystem;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadPackageInfo = PackageInfo.fromPlatform();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final double offset = _scrollController.offset;
      final double delta = _appBarHeight - kToolbarHeight;
      bool thresholdReached = (_appBarHeight - offset) >
          kToolbarHeight + 48 * 0.3; // 48 -> size of FAB
      final double t = (offset / delta).clamp(0.0, 1.0);
      setState(() {
        _fabOffsetTop = _appBarHeight - offset;
        _titlePadding = Tween<double>(begin: 16, end: 64).transform(t);
        _isFabVisible = thresholdReached;
      });
    }
  }

  Future<void> _showBottomSheet() async {
    final ThemeData theme = Theme.of(context);
    bool hasAvatar =
        Provider.of<AccountProvider>(context, listen: false).hasAvatar;
    ImageSource source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(10.0),
            topRight: const Radius.circular(10.0),
          ),
        ),
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Upload from Gallery'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              if (hasAvatar)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: theme.errorColor),
                  title: Text(
                    'Remove photo',
                    style: TextStyle(color: theme.errorColor),
                  ),
                  onTap: _removeAvatar,
                ),
            ],
          );
        });

    if (source != null) {
      _pickImage(source);
    }
  }

  Future<void> _retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() => _image = response.file);
    } else {
      setState(() => _image = null);
      showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          title: const Text('Error'),
          content: const Text('Pick image error'),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            )
          ],
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    _image = await ImagePicker.pickImage(source: source);
    setState(() {});

    if (Platform.isAndroid) {
      await _retrieveLostData();
    }

    if (_image == null) {
      return;
    }

    ThemeData theme = Theme.of(context);
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: _image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarColor: theme.primaryColor,
        toolbarWidgetColor: Colors.white,
      ),
    );

    setState(() => _image = croppedImage);

    try {
      await Provider.of<AccountProvider>(context, listen: false)
          .uploadAvatar(croppedImage.path);
      // setState(() => _image = null);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _removeAvatar() async {
    await Provider.of<AccountProvider>(context, listen: false).removeAvatar();
    Navigator.pop(context);
  }

  void _reset() {
    Provider.of<AccountProvider>(context, listen: false).reset();
    Provider.of<ExpensesProvider>(context, listen: false).reset();
    Provider.of<GroupsProvider>(context, listen: false).reset();
    Provider.of<InvitesProvider>(context, listen: false).reset();
  }

  Future<void> _handleLogout() async {
    bool result = await showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (result) {
      await Provider.of<Auth>(context, listen: false).logout();
    }
  }

  Future<void> _handleDeleteAccount() async {
    bool result = await showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure that you want to delete your account? This will immediately log you out of your account and you will not be able to log in again.'),
        actions: <Widget>[
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            ios: (_) => CupertinoDialogActionData(isDestructiveAction: true),
          ),
        ],
      ),
    );

    if (result) {
      showPlatformDialog(
        androidBarrierDismissible: false,
        context: context,
        builder: (_) => LoadingDialog(),
      );
      try {
        await Provider.of<AccountProvider>(context, listen: false)
            .deleteAccount();
        _reset();
        await Provider.of<Auth>(context, listen: false).logout();
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      } catch (err) {
        Navigator.pop(context);
        showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Failed to delete account. Please check your Internet connection and try again'),
            actions: <Widget>[
              PlatformDialogAction(
                child: const Text('OK'),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              )
            ],
          ),
        );
      }
    }
  }

  _launchURL(String slug, {bool isEmail = false}) async {
    String url = isEmail ? slug : WEB_URL + slug;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          title: const Text('Error'),
          content: Text('Could not open $url'),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            actions: <Widget>[
              PopupMenuButton<MoreMenuOptions>(
                tooltip: 'More',
                onSelected: (MoreMenuOptions result) {
                  switch (result) {
                    case MoreMenuOptions.edit:
                      Navigator.of(context).pushNamed(EditNameScreen.routeName);
                      break;
                    case MoreMenuOptions.logout:
                      _handleLogout();
                      break;
                    default:
                      return null;
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MoreMenuOptions>>[
                  const PopupMenuItem<MoreMenuOptions>(
                    value: MoreMenuOptions.edit,
                    child: const ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit name'),
                    ),
                  ),
                  const PopupMenuItem<MoreMenuOptions>(
                    value: MoreMenuOptions.logout,
                    child: const ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
            expandedHeight: _appBarHeight,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding:
                  EdgeInsetsDirectional.only(start: _titlePadding, bottom: 0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Selector<
                            AccountProvider,
                            Tuple5<Status, String, String, String,
                                Future<void> Function(String)>>(
                        selector: (_, state) => Tuple5(
                              state.status,
                              state.account?.fullName ?? '',
                              state.account?.initials ?? '',
                              state.account?.avatar ?? '',
                              state.uploadAvatar,
                            ),
                        builder: (_, data, __) {
                          return Row(
                            children: <Widget>[
                              if (data.item1 != Status.IDLE &&
                                  data.item1 != Status.RESOLVED)
                                if (data.item1 == Status.REJECTED)
                                  GestureDetector(
                                    onTap: () => data.item5(_image?.path),
                                    child: CircleAvatar(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          ClipOval(
                                            child: Image.file(
                                              _image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Icon(
                                            Icons.warning,
                                            color: Theme.of(context).errorColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  CircleAvatar(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        ClipOval(
                                          child: Image.file(
                                            _image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        PlatformCircularProgressIndicator(),
                                      ],
                                    ),
                                  )
                              else
                                Avatar(
                                  initals: data.item3,
                                  avatar: data.item4,
                                ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                child: Text(
                                  data.item2,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    'Email',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
                Selector<AccountProvider, String>(
                  selector: (_, provider) => provider.account?.email ?? '',
                  builder: (_, email, __) => ListTile(
                    title: Text(email),
                    subtitle: const Text('Tap to change email'),
                    onTap: () => Navigator.of(context)
                        .pushNamed(EditEmailScreen.routeName),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    'Settings',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
                const ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: const Text('Notifications'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Passcode Lock'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    'Help',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Support'),
                  onTap: () => _launchURL(
                    'mailto:support@sliceitapp.com',
                    isEmail: true,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('FAQ'),
                  onTap: () => _launchURL('faq'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Acknowledgements'),
                  onTap: () => _launchURL('acknowledgements'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Privacy Policy'),
                  onTap: () => _launchURL('privacy'),
                ),
                const Divider(height: 1),
                FutureBuilder(
                  future: _loadPackageInfo,
                  builder: (_, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        snapshot.hasData
                            ? "${snapshot.data.appName} for $_platform v${snapshot.data.version} (${snapshot.data.buildNumber})"
                            : snapshot.hasError ? 'Error' : 'Loading...',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                PlatformButton(
                  onPressed: _handleDeleteAccount,
                  androidFlat: (_) => MaterialFlatButtonData(),
                  child: Text(
                    'Delete account',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: _fabOffsetTop,
            right: 0,
            child: Visibility(
              visible: _isFabVisible,
              child: FloatingActionButton(
                child: const Icon(Icons.photo_camera),
                onPressed: _showBottomSheet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
