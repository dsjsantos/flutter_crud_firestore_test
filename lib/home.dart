import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';
import 'formPerson.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference _persons =
      FirebaseFirestore.instance.collection('persons');

	Future<void> _createOrUpdatePerson([DocumentSnapshot? snapshot]) async {
    await showModalBottomSheet(
			enableDrag: true,
			isDismissible: true,
			isScrollControlled: true,
      context: context,
      builder: (_) => CardFormPerson(
        snapshot: snapshot,
        collection: _persons,
      ),
    );
  }

  // Deleting person by id
  Future<void> _deletePerson(String personId) async {
    await _persons.doc(personId).delete();

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Person was excluded with success')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      // Use StreamBuilder to display all persons from database in real-time
      body: StreamBuilder(
        stream: _persons.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      snapshot.data!.docs[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(documentSnapshot['name']),
                      subtitle: Text(documentSnapshot['email']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _createOrUpdatePerson(documentSnapshot),
														),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  _deletePerson(documentSnapshot.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

      // Add new person
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _createOrUpdatePerson(),
      ),
    );
  }
}
