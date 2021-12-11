import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';

class Contact {
  DocumentReference? reference;
  String? name;
  String? phone;
  List<DocumentReference?> sells;
  List<DocumentReference?> products;

  Contact(
      {this.reference,
      String? name,
      this.phone,
      this.products = const [],
      this.sells = const []}) {
    this.name = "${name?[0].toUpperCase()}${name?.substring(1)}";
  }
  Map<String, Object> toMap() {
    return {
      if (name != null && name!.isNotEmpty) 'name': name!,
      if (phone != null && phone!.isNotEmpty) 'phone': phone!,
      if (sells.isNotEmpty) 'sells': sells,
      if (products.isNotEmpty) 'products': products,
    };
  }
}

class Contacts {
  final _contacts = FirebaseFirestore.instance.collection('contacts');

  Future<DocumentReference?> addContact(Contact contact) async {
    try {
      return await _contacts.add(contact.toMap());
    } catch (err) {
      print(err);
      return null;
    }
  }

  Stream<List<Contact>>? get contacts {
    try {
      return _contacts.snapshots().map(_contactFromSnapshot);
    } catch (err) {
      print(err);
      return null;
    }
  }

  Stream<List<Contact>>? contactsOrderedBy(String field) {
    try {
      return _contacts
          .orderBy(field, descending: false)
          .snapshots()
          .map(_contactFromSnapshot);
    } catch (err) {
      print(err);
      return null;
    }
  }

  List<Contact> _contactFromSnapshot(QuerySnapshot query) {
    try {
      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Contact(
            reference: doc.reference,
            name: data['name'],
            phone: data['phone'],
            sells: data['sells'] ?? [],
            products: data['products'] ?? []);
      }).toList();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<Contact> getFromReference(DocumentReference contactReference) async {
    final result = await contactReference.get();
    final contactData = result.data() as Map;
    return Contact(
      reference: contactReference,
      name: contactData['name'],
      phone: contactData['phone'],
      products: contactData['products'] ?? [],
      sells: contactData['sells'] ?? [],
    );
  }

  addRadom() {
    addContact(
        Contact(name: faker.person.name(), phone: faker.phoneNumber.us()));
  }
}
