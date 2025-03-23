import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../service/global.dart';
import '../../utils/theme.dart';
import '../models/contact_model.dart';

class AddEmergencyContact extends StatefulWidget {
  final mapEdit;
  final Function(Contact) onEdit;

  const AddEmergencyContact(
      {Key? key, required this.mapEdit, required this.onEdit})
      : super(key: key);

  @override
  State<AddEmergencyContact> createState() => _AddEmergencyContactState();
}

class _AddEmergencyContactState extends State<AddEmergencyContact> {
  bool isEdit = false;
  final _formKey = GlobalKey<FormState>();

  String? id;
  String? fName = "";
  String? relation = "";
  String? contactNo = "";
  String? email = "";

  String uID = Global.instance.user!.uId!;

  Contact? contact;
  List<String> type = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Husband',
    'Wife',
    'Son',
    'Daughter',
    'Guardian',
    'Other'
  ];

  @override
  void initState() {
    if (widget.mapEdit != null) {
      isEdit = true;
      id = widget.mapEdit.id;
      fName = widget.mapEdit.fname;
      relation = widget.mapEdit.relation;
      contactNo = widget.mapEdit.contactNo;
      email = widget.mapEdit.email;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: Text(
        isEdit ? 'Edit Emergency Contact' : 'Add Emergency Contact',
        style: AppTheme.titleLarge.copyWith(color: AppTheme.textColor),
      ),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              getTextField(
                text: fName,
                label: 'Full Name',
                hint: 'Enter name of the person',
                icon: Icons.person_outline,
                valError: 'Please enter the name',
                onChanged: (value) {
                  fName = value;
                },
              ),
              const SizedBox(height: 16),
              isEdit ? selectEditRelationField() : selectRelationField(),
              const SizedBox(height: 16),
              getTextField(
                text: contactNo,
                label: 'Contact Number',
                hint: 'Enter contact no. of the person',
                icon: Icons.phone_outlined,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please enter the contact no.";
                  } else if (!RegExp(r"^(\d+)*$").hasMatch(val)) {
                    return "Enter a valid contact no.";
                  }
                  return null;
                },
                onChanged: (value) {
                  contactNo = value;
                },
              ),
              const SizedBox(height: 16),
              getTextField(
                text: email,
                label: 'Email Address',
                hint: 'Enter email address (optional)',
                icon: Icons.email_outlined,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val)) {
                      return "Enter a valid email address";
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
          ),
          child: Text('Cancel', style: AppTheme.bodyMedium),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            isEdit ? "Update" : "Add",
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (isEdit) {
                var contact =
                    Contact(id!, fName!, relation!, contactNo!, email);
                widget.onEdit(contact);
              } else {
                DatabaseReference contactRef = FirebaseDatabase.instance
                    .ref()
                    .child('contacts')
                    .child(uID);

                String contactID = contactRef.push().key!;

                contactRef.child(contactID).set({
                  'fname': fName,
                  'relation': relation,
                  'contactNo': contactNo,
                  'email': email,
                });

                Fluttertoast.showToast(
                  msg: 'Emergency contact added successfully',
                  backgroundColor: AppTheme.success,
                );
              }
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget getTextField({
    String? text,
    String? label,
    String? hint,
    IconData? icon,
    String? valError,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: TextFormField(
        initialValue: text,
        style: AppTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator ??
            (val) {
              if (val!.isEmpty) {
                return valError;
              }
              return null;
            },
        onChanged: onChanged,
      ),
    );
  }

  Widget selectRelationField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.family_restroom, color: AppTheme.primaryColor),
          border: InputBorder.none,
        ),
        hint: Text('Select Relation', style: AppTheme.bodyMedium),
        items: type.map((String items) {
          return DropdownMenuItem(
            value: items,
            child: Text(items, style: AppTheme.bodyMedium),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return "Please select the relation";
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            relation = newValue!;
          });
        },
      ),
    );
  }

  Widget selectEditRelationField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.family_restroom, color: AppTheme.primaryColor),
          border: InputBorder.none,
        ),
        value: relation,
        items: type.map((String items) {
          return DropdownMenuItem(
            value: items,
            child: Text(items, style: AppTheme.bodyMedium),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            relation = newValue!;
          });
        },
      ),
    );
  }
}
