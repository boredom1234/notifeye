import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crime/account/components/color.dart';
import 'package:crime/account/components/sos_setting_popup.dart';
import 'package:flutter/material.dart';
import '../../service/firebase.dart';
import '../../service/global.dart';
import '../../utils/bottom_navigation.dart';
import '../../utils/custom_widgets.dart';
import '../../utils/theme.dart';
import '../components/add_contact_popup.dart';
import '../components/notification.dart';
import '../components/send_email.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isSwitched = false;
  String? url;
  var val;

  @override
  void initState() {
    super.initState();
    if (Global.instance.user!.isLoggedIn) {
      url = Global.instance.user!.avatar!;
    }
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) {
        NotificationController.onActionReceivedMethod(receivedAction);
        return val;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Account', style: AppTheme.titleLarge),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 2,
        centerTitle: true,
        actions: Global.instance.user!.isLoggedIn
            ? [
                IconButton(
                  onPressed: () {
                    signOut();
                    setState(() {
                      Navigator.of(context).pushReplacementNamed("/home");
                    });
                  },
                  icon: Icon(Icons.logout, color: AppTheme.primaryColor),
                )
              ]
            : null,
      ),
      body: Global.instance.user!.isLoggedIn
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        getAvatar(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Global.instance.user!.fName!,
                                style: AppTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/editProfile');
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // General Section
                getSectionHeader("General"),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      getListTile(
                        "My Posts",
                        Icons.article_outlined,
                        () => Navigator.of(context).pushNamed('/myPost'),
                      ),
                      const Divider(height: 1),
                      getListTile(
                        "Send Feedback",
                        Icons.feedback_outlined,
                        getSendFeedbackPopUp,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SOS Section
                getSectionHeader("SOS Message"),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Enable SOS Menu Bar",
                              style: AppTheme.bodyLarge,
                            ),
                            Switch(
                              value: isSwitched,
                              onChanged: (value) {
                                setState(() {
                                  if (isSwitched) {
                                    NotificationController
                                        .dismissNotification();
                                    isSwitched = false;
                                  } else {
                                    NotificationController
                                        .createSOSNotification();
                                    isSwitched = true;
                                  }
                                });
                              },
                              activeColor: AppTheme.primaryColor,
                              activeTrackColor: AppTheme.primaryLight,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      getListTile(
                        "Edit SOS Message",
                        Icons.edit_note,
                        () => Navigator.of(context).pushNamed('/editSOS'),
                      ),
                      const Divider(height: 1),
                      getListTile(
                        "Additional Settings",
                        Icons.settings_outlined,
                        getSosSettingFormPopUp,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Emergency Contacts Section
                getSectionHeader("Emergency Contacts"),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      getListTile(
                        "Add Emergency Contact",
                        Icons.person_add_outlined,
                        getContactFormPopUp,
                      ),
                      const Divider(height: 1),
                      getListTile(
                        "Manage Contacts",
                        Icons.contacts_outlined,
                        () => Navigator.pushNamed(context, '/manageContact'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.all(32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Please Log In or Register to Continue",
                        style: AppTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          style: AppTheme.primaryButtonStyle,
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          style: AppTheme.secondaryButtonStyle,
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        defaultSelectedIndex: 4,
      ),
    );
  }

  Widget getSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: AppTheme.titleLarge.copyWith(
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget getListTile(String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(text, style: AppTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textLightColor),
      onTap: onTap,
    );
  }

  Widget getAvatar() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
        image: url != null && url!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(url!),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: url == null || url!.isEmpty
          ? Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: 40,
            )
          : null,
    );
  }

  void getSendFeedbackPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) => SendEmail(title: "Feedback"),
    );
  }

  void getContactFormPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddEmergencyContact(
        mapEdit: null,
        onEdit: (value) {},
      ),
    );
  }

  void getSosSettingFormPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SosSettingsPopUp(),
    );
  }
}
