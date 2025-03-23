import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../service/global.dart';
import '../../utils/custom_widgets.dart';
import '../../utils/theme.dart';
import '../components/add_contact_popup.dart';
import '../models/contact_model.dart';

class ManageEmergencyContact extends StatefulWidget {
  const ManageEmergencyContact({Key? key}) : super(key: key);

  @override
  State<ManageEmergencyContact> createState() => _ManageEmergencyContactState();
}

class _ManageEmergencyContactState extends State<ManageEmergencyContact> {
  List<Contact> contactList = [];
  bool haveContact = false;
  bool _isLoading = false;
  String uID = Global.instance.user!.uId!;

  Future<void> getContactList() async {
    setState(() => _isLoading = true);
    contactList.clear();
    try {
      final contactRef =
          FirebaseDatabase.instance.ref().child('contacts').child(uID);
      final event = await contactRef.once();

      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        data.forEach((key, value) {
          final contactData = json.decode(json.encode(value));
          contactList.add(Contact(
            key,
            contactData["fname"],
            contactData["relation"],
            contactData["contactNo"],
            contactData["email"],
          ));
        });
        setState(() => haveContact = true);
      }
    } catch (e) {
      print('Error getting contacts: $e');
      Fluttertoast.showToast(
        msg: 'Error loading contacts',
        backgroundColor: AppTheme.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getContactList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: customAppBar(title: "Emergency Contacts"),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : !haveContact
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contacts_outlined,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No emergency contacts added yet',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add contacts to receive emergency alerts',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => getContactFormPopUp(null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Contact'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: getContactList,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contactList.length,
                    itemBuilder: (context, index) {
                      final contact = contactList[index];
                      return Dismissible(
                        key: Key(contact.id!),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: AppTheme.error,
                          ),
                        ),
                        onDismissed: (direction) async {
                          try {
                            await FirebaseDatabase.instance
                                .ref()
                                .child('contacts')
                                .child(uID)
                                .child(contact.id!)
                                .remove();

                            setState(() {
                              contactList.removeAt(index);
                              if (contactList.isEmpty) {
                                haveContact = false;
                              }
                            });

                            Fluttertoast.showToast(
                              msg: 'Contact removed successfully',
                              backgroundColor: AppTheme.success,
                            );
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: 'Error removing contact',
                              backgroundColor: AppTheme.error,
                            );
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => getContactFormPopUp(contact),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_outline,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              contact.fname!,
                                              style: AppTheme.titleSmall,
                                            ),
                                            Text(
                                              contact.relation!,
                                              style:
                                                  AppTheme.bodySmall.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: AppTheme.primaryColor,
                                        ),
                                        onPressed: () =>
                                            getContactFormPopUp(contact),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        size: 20,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        contact.contactNo!,
                                        style: AppTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  if (contact.email != null &&
                                      contact.email!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email_outlined,
                                          size: 20,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          contact.email!,
                                          style: AppTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: haveContact
          ? FloatingActionButton(
              onPressed: () => getContactFormPopUp(null),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void getContactFormPopUp(Contact? contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEmergencyContact(
          mapEdit: contact,
          onEdit: (value) async {
            try {
              await FirebaseDatabase.instance
                  .ref()
                  .child('contacts')
                  .child(uID)
                  .child(value.id!)
                  .update({
                'fname': value.fname,
                'relation': value.relation,
                'contactNo': value.contactNo,
                'email': value.email,
              });

              Fluttertoast.showToast(
                msg: 'Contact updated successfully',
                backgroundColor: AppTheme.success,
              );
              getContactList();
            } catch (e) {
              Fluttertoast.showToast(
                msg: 'Error updating contact',
                backgroundColor: AppTheme.error,
              );
            }
          },
        );
      },
    );
  }
}
