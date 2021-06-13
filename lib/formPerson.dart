import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

class CardFormPerson extends StatefulWidget {
  CardFormPerson({Key? key, required this.snapshot, required this.collection})
      : super(key: key);

  final DocumentSnapshot? snapshot;
  final CollectionReference collection;

  _CardFormPerson createState() =>
      _CardFormPerson(snapshot: this.snapshot, collection: this.collection);
}

class _CardFormPerson extends State<CardFormPerson>
    with SingleTickerProviderStateMixin {
  _CardFormPerson({required this.snapshot, required this.collection}) : super();

  final DocumentSnapshot? snapshot;
  final CollectionReference collection;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateContorller = TextEditingController();
  final MaskTextInputFormatter maskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  String? formErrorMessage;

  void _clearFields() {
    // Clear fields values
    this.nameController.text = '';
    this.emailController.text = '';
    this.birthDateContorller.text = '';
  }

  DateTime? _parseDate(String? inputDate, [String format = "MM/dd/yyyy"]) {
    try {
      if (inputDate == null) 
        return null;

      final DateFormat dateFormat = DateFormat(format);
      final DateTime? parsedDate = dateFormat.parse(inputDate);
      final String? stringDate = parsedDate != null ? dateFormat.format(parsedDate) : null;
      return stringDate == inputDate ? parsedDate : null;
    } catch (e) {
      return null;
    }
  }

  void _onCreateUpdate() async {
    // Save (create/update) form data
    final String? name = this.nameController.text;
    final String? email = this.emailController.text;
    final DateTime? birthDate = this._parseDate(this.birthDateContorller.text);

    formErrorMessage = null;
    if (name == null || email == null || birthDate == null) {
      // Show form error message
      formErrorMessage = 'Please fill all fields before save it';
      return;
    }

    // Prepare document data to persist
    final Map<String, Object?> _document = {
      "name": name,
      "email": email,
      "birthDate": Timestamp.fromDate(birthDate)
    };

    // Persist data
    if (snapshot == null) {
      // Create a new person document into firestore
      await collection.add(_document);
    } else {
      // Update person's document into firestore
      await collection.doc(snapshot!.id).update(_document);
    }

    // Hide bottom sheet
    Navigator.of(context).pop();
  }

  Widget _buildErrorBox(message) {
    if (message == null) {
      return Container();
    }

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(top: 30),
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.redAccent),
          child: Center(
            child: Text(
              message!,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    if (this.snapshot == null) {
      this._clearFields();
    } else {
      Timestamp timestamp = this.snapshot!['birthDate'];
      final dateFormat = new DateFormat("MM/dd/yyyy");
      String birthDate = dateFormat.format(timestamp.toDate());

      this.nameController.text = this.snapshot!['name'];
      this.emailController.text = this.snapshot!['email'];
      this.birthDateContorller.text = birthDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: this.nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: this.emailController,
              decoration: InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              keyboardType: TextInputType.datetime,
              controller: this.birthDateContorller,
              inputFormatters: [this.maskFormatter],
              decoration: InputDecoration(labelText: 'Birth Date (mm/dd/yyyy)'),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  this._onCreateUpdate();
                  setState(() {});
                }),
            _buildErrorBox(formErrorMessage),
          ],
        ),
      ),
    );
  }
}
