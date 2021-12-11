import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class MyVarriables {
  final varriables = FirebaseFirestore.instance.collection('my_variables');
  static const Map<String, List<String>> villes = {
    'Kenitra': [
      "Ain Sebaa",
      "Al Alama",
      "Al Baladya",
      "Al Maghrib Al Arabi",
      "Assam",
      "Autre secteur",
      "Bab Fès",
      "Bir Anzarane",
      "Mimosas",
      "Ouled M'Barek",
      "Ouled Oujih",
      "PAM",
      "Quartier Al Fath",
      "Quartier Nahda",
      "Seyad",
      "Taïbia",
      "Val Fleury",
      "Village",
      "El Haouzia",
      "El Ismailia",
      "El Menzah",
      "Fouarate",
      "Inara",
      "Khabazat",
      "La Base",
      "La Cigogne",
      "La Cité",
      "La Ville Haute",
      "Bir Rami",
      "Bir Rami Est",
      "Bir Rami Industriel",
      "Bir Rami Ouest",
      "Centre",
      "Corcica",
      "Diour 10000",
      "Diour Sniak",
      "El Assam",
      "El Haddada",
      "Maamora",
      "Mellah"
    ],
    'Mehdia': [],
  };
  static const typesDeBien = [
    'Appartements',
    'Maisons et Villas',
    'Bureaux et Plateaux',
    'Magasins, Commerces et Locaux industriels',
    'Terrains et Fermes',
    'Autre Immobilier',
  ];
  Future<int> get counter async {
    try {
      return (await varriables.doc('products_var').get()).data()?['counter'];
    } catch (err) {
      print(err);
      return 0;
    }
  }

  Future<void> setCounter(int cnt) async {
    try {
      return await varriables.doc('products_var').update({'counter': cnt});
    } catch (err) {
      print(err);
      return;
    }
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('142.250.98.139');
      print('Connected');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      print('Not connected');
      return false;
    }
  }
  // Future get initialise async {
  //   villes = (await varriables.doc('products_var').get()).data()?['villes'];
  // }

  // Future setVilles() async {
  //   try {
  //     await varriables.doc('products_var').update({
  //       'villes': {
  //         'Kenitra': [
  //           "Ain Sebaa",
  //           "Al Alama",
  //           "Al Baladya",
  //           "Al Maghrib Al Arabi",
  //           "Assam",
  //           "Autre secteur",
  //           "Bab Fès",
  //           "Bir Anzarane",
  //           "Mimosas",
  //           "Ouled M'Barek",
  //           "Ouled Oujih",
  //           "PAM",
  //           "Quartier Al Fath",
  //           "Quartier Nahda",
  //           "Seyad",
  //           "Taïbia",
  //           "Val Fleury",
  //           "Village",
  //           "El Haouzia",
  //           "El Ismailia",
  //           "El Menzah",
  //           "Fouarate",
  //           "Inara",
  //           "Khabazat",
  //           "La Base",
  //           "La Cigogne",
  //           "La Cité",
  //           "La Ville Haute",
  //           "Bir Rami",
  //           "Bir Rami Est",
  //           "Bir Rami Industriel",
  //           "Bir Rami Ouest",
  //           "Centre",
  //           "Corcica",
  //           "Diour 10000",
  //           "Diour Sniak",
  //           "El Assam",
  //           "El Haddada",
  //           "Maamora",
  //           "Mellah"
  //         ],
  //         'Mehdia': [],
  //       }
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  //   ;
  // }
}
