import 'package:flutter/material.dart';
import 'package:contacts_app/contact.dart';
import 'package:contacts_app/contact_input_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? contactsJson = prefs.getStringList('contacts');
    if (contactsJson != null) {
      setState(() {
        contacts = contactsJson
            .map((contactJson) => Contact.fromJson(jsonDecode(contactJson)))
            .toList();
      });
    }
  }

  Future<void> saveContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contactsJson =
        contacts.map((contact) => jsonEncode(contact.toJson())).toList();
    await prefs.setStringList('contacts', contactsJson);
  }

  void navigateToContactInput({int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactInputPage(
          index: index,
          contact: index != null ? contacts[index] : null,
        ),
      ),
    );

    if (result == true) {
      await loadContacts();
    }
  }

  void updateContact(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactInputPage(
          index: index,
          contact: contacts[index],
        ),
      ),
    );

    if (result == true) {
      await loadContacts();
    }
  }

  void deleteContact(int index) async {
    setState(() {
      contacts.removeAt(index);
      saveContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contacts List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: contacts.isEmpty
                  ? const Text(
                      'Tidak Ada Kontak...',
                      style: TextStyle(fontSize: 22),
                    )
                  : ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) => getRow(index),
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToContactInput(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getRow(int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: index % 2 == 0 ? Colors.deepPurpleAccent : Colors.purple,
          foregroundColor: Colors.white,
          child: Text(
            contacts[index].name[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contacts[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(contacts[index].contact),
          ],
        ),
        trailing: SizedBox(
          width: 70,
          child: Row(
            children: [
              InkWell(
                onTap: () => updateContact(index),
                child: const Icon(Icons.edit),
              ),
              InkWell(
                onTap: () => deleteContact(index),
                child: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
