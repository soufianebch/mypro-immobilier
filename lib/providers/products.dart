import 'dart:io';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mypro_immobilier/providers/google_drive.dart';
import 'package:mypro_immobilier/providers/uploaded_videos.dart';
import 'package:path_provider/path_provider.dart';

class Product {
  DocumentReference? reference;
  String? googleDriveFolderId;
  bool? changed;
  int? hashtag;
  String? typedebien;
  String? ville;
  String? secteur;
  String? address;
  int? nbrChambres;
  int? nbrSallesDeBain;
  int? nbrCuisine;
  int? nbrSalons;
  int? nbrEtage;
  int? nbrFacades;
  int? nbrBalcons;
  double? surfaceTotal;
  double? surfaceHabitable;
  String? ageDuBien;
  double? fraisDesSyndics;
  bool? ascensseur;
  bool? terrasse;
  bool? meuble;
  bool? climatisation;
  bool? chauffage;
  bool? cuisineEquipee;
  bool? concierge;
  bool? securite;
  bool? parking;
  bool? duplex;
  String? title;
  String? title_ar;
  String? description;
  String? description_ar;
  double? prix;
  String? miniature;
  List<dynamic>? images;
  // List<dynamic>? videos;
  String? mainVideo;
  String? introVideo;
  String? finalVideo;
  // List<dynamic>? voices;
  GeoPoint? location;
  int? inStock;
  Timestamp? createdTimeStamp;
  DocumentReference? contact;
  UploadedVideoFiles? uploadedVideoFiles;

  Product({
    this.reference,
    this.googleDriveFolderId,
    this.changed,
    this.hashtag,
    this.typedebien,
    this.ville,
    this.secteur,
    this.address,
    this.nbrChambres,
    this.nbrSallesDeBain,
    this.nbrCuisine,
    this.nbrSalons,
    this.nbrEtage,
    this.nbrFacades,
    this.nbrBalcons,
    this.surfaceTotal,
    this.surfaceHabitable,
    this.ageDuBien,
    this.fraisDesSyndics,
    this.ascensseur,
    this.terrasse,
    this.meuble,
    this.climatisation,
    this.chauffage,
    this.cuisineEquipee,
    this.concierge,
    this.securite,
    this.parking,
    this.duplex,
    this.title,
    this.title_ar,
    this.description,
    this.description_ar,
    this.prix,
    this.miniature,
    this.images,
    // this.videos,
    this.mainVideo,
    this.introVideo,
    this.finalVideo,
    // this.voices,
    this.inStock,
    this.contact,
    this.location,
    this.createdTimeStamp,
    this.uploadedVideoFiles,
  });

  generateTitle() {
    return '$typedebien ${surfaceTotal?.toStringAsFixed(0)}m² ${duplex == true ? ' duplex' : ''}${meuble == true ? ' meublé' : ''}${(nbrFacades ?? 0) > 1 ? ' $nbrFacades facades' : ''} ';
  }

  generateTitleAr() {
    return 'شقة ${surfaceTotal?.toStringAsFixed(0)}م² ${duplex == true ? ' ديبلكس' : ''}${meuble == true ? ' مفروشة' : ''}${(nbrFacades ?? 0) > 1 ? ' $nbrFacades واجهات' : ''} ';
  }

  generateDescriptionAr() {
    return '''
شقق جودة عالية بالقرب من جميع المرافق الضرورية

تتكون من:
${(nbrChambres ?? 0) > 0 ? '- $nbrChambres غرف\n' : ''}${(nbrSalons ?? 0) > 0 ? '- $nbrSalons صالون\n' : ''}${(nbrSallesDeBain ?? 0) > 0 ? '- $nbrSallesDeBain حمام\n' : ''}${(nbrCuisine ?? 0) > 0 ? '- $nbrCuisine مطبخ\n' : ''}${(nbrBalcons ?? 0) > 0 ? '- $nbrBalcons شرفة\n' : ''}${(nbrFacades ?? 0) > 1 ? '- $nbrFacades واجهات\n' : ''}

مميزات :
${ascensseur == true ? '> مصعد\n' : ''}${terrasse == true ? '> تيراص\n' : ''}${climatisation == true ? '> نظام تبريد\n' : ''}${chauffage == true ? '> نظام تدفئة\n' : ''}${cuisineEquipee == true ? '> مطبخ مجهز\n' : ''}${concierge == true ? '> بواب\n' : ''}${securite == true ? '> نظام مراقبة\n' : ''}${parking == true ? '> موقف سيارات\n' : ''}${meuble == true ? '> مفروشة\n' : ''}${duplex == true ? '> ديبلكس\n' : ''}

التمن: ${prix != null ? NumberFormat.currency(locale: 'eu', symbol: '', decimalDigits: 0).format(prix) : '0'}درهم
المساحة: ${surfaceTotal?.toStringAsFixed(0)}م²
الموقع: $ville, $secteur, $address

للمزيد من المعلومات لا تترددوا بالاتصال بنا !
''';
  }

  generateDescription() {
    return '''
$typedebien d'une bonne qualite avec une finition exceptionnelle proche de toutes commodite

Se composent de:
${(nbrChambres ?? 0) > 0 ? '- $nbrChambres Chambres\n' : ''}${(nbrSalons ?? 0) > 0 ? '- $nbrSalons Salons\n' : ''}${(nbrSallesDeBain ?? 0) > 0 ? '- $nbrSallesDeBain Salles de bain\n' : ''}${(nbrCuisine ?? 0) > 0 ? '- $nbrCuisine Cuisine\n' : ''}${(nbrBalcons ?? 0) > 0 ? '- $nbrBalcons Balcons\n' : ''}${(nbrFacades ?? 0) > 1 ? '- $nbrFacades Facades\n' : ''}

Caractéristiques du bien:
${ascensseur == true ? '> ascensseur\n' : ''}${terrasse == true ? '> terrasse\n' : ''}${climatisation == true ? '> climatisation\n' : ''}${chauffage == true ? '> chauffage\n' : ''}${cuisineEquipee == true ? '> cuisine equipee\n' : ''}${concierge == true ? '> concierge\n' : ''}${securite == true ? '> securite\n' : ''}${parking == true ? '> parking\n' : ''}${meuble == true ? '> meublé\n' : ''}${duplex == true ? '> duplex\n' : ''}

Prix: ${prix != null ? NumberFormat.currency(locale: 'eu', symbol: '', decimalDigits: 0).format(prix) : '0'}Dhs
Superficie: ${surfaceTotal?.toStringAsFixed(0)}m²
Quartier: $ville, $secteur, $address

Vous désirez plus d’informations ? N'hésitez pas à nous contacter !
''';
  }

  Product randomData() {
    changed = true;
    hashtag = Random().nextInt(200);
    typedebien = 'Appartement';
    ville = 'Kenitra';
    secteur = 'Lot Alliance Mehdia';
    address = 'Pres de MALL MEHDIA';
    nbrChambres = Random().nextInt(2) + 1;
    nbrSallesDeBain = Random().nextInt(1) + 1;
    nbrCuisine = Random().nextInt(1) + 1;
    nbrSalons = Random().nextInt(1) + 1;
    nbrEtage = Random().nextInt(4) + 2;
    nbrFacades = Random().nextInt(2) + 1;
    nbrBalcons = Random().nextInt(2) + 1;
    surfaceTotal = Random().nextDouble() * 100 + 50;
    surfaceHabitable = Random().nextDouble() * 100 + 50;
    ageDuBien = 'neuf';
    fraisDesSyndics = Random().nextDouble() * 100;
    ascensseur = Random().nextBool();
    terrasse = Random().nextBool();
    meuble = Random().nextBool();
    climatisation = Random().nextBool();
    chauffage = Random().nextBool();
    cuisineEquipee = Random().nextBool();
    concierge = Random().nextBool();
    securite = Random().nextBool();
    parking = Random().nextBool();
    duplex = Random().nextBool();
    title = Faker().lorem.sentence();
    title_ar = Faker().lorem.sentence();
    description = Faker().lorem.sentence();
    description_ar = Faker().lorem.sentence();
    prix = Random().nextDouble() * 1000000;
    miniature =
        faker.image.image(keywords: ['apartment', 'real estate'], random: true);
    images = () {
      List<String> imgs = [];
      for (var i = 0; i < Random().nextInt(8) + 1; i++) {
        imgs.add(
            faker.image.image(keywords: ['apartment', 'house'], random: true));
      }

      return imgs;
    }();
    // videos = [];
    // voices = [];
    inStock = [-1, 0, 1][Random().nextInt(2)];
    contact = null;
    location = null;
    createdTimeStamp = Timestamp.fromDate(Faker().date.dateTime());
    return this;
  }

  Product get clone {
    return Product(
      reference: this.reference,
      googleDriveFolderId: this.googleDriveFolderId,
      changed: this.changed,
      hashtag: this.hashtag,
      typedebien: this.typedebien,
      ville: this.ville,
      secteur: this.secteur,
      address: this.address,
      nbrChambres: this.nbrChambres,
      nbrSallesDeBain: this.nbrSallesDeBain,
      nbrCuisine: this.nbrCuisine,
      nbrSalons: this.nbrSalons,
      nbrEtage: this.nbrEtage,
      nbrFacades: this.nbrFacades,
      nbrBalcons: this.nbrBalcons,
      surfaceTotal: this.surfaceTotal,
      surfaceHabitable: this.surfaceHabitable,
      ageDuBien: this.ageDuBien,
      fraisDesSyndics: this.fraisDesSyndics,
      ascensseur: this.ascensseur,
      terrasse: this.terrasse,
      meuble: this.meuble,
      climatisation: this.climatisation,
      chauffage: this.chauffage,
      cuisineEquipee: this.cuisineEquipee,
      concierge: this.concierge,
      securite: this.securite,
      parking: this.parking,
      duplex: this.duplex,
      title: this.title,
      title_ar: this.title_ar,
      description: this.description,
      description_ar: this.description_ar,
      prix: this.prix,
      miniature: this.miniature,
      images: this.images,
      // videos: this.videos,
      mainVideo: this.mainVideo,
      introVideo: this.introVideo,
      finalVideo: this.finalVideo,
      // voices: this.voices,
      inStock: this.inStock,
      contact: this.contact,
      location: this.location,
      createdTimeStamp: this.createdTimeStamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (googleDriveFolderId != null)
        'googleDriveFolderId': googleDriveFolderId,
      if (changed != null) 'changed': changed,
      if (hashtag != null) 'hashtag': hashtag,
      if (typedebien != null) 'typedebien': typedebien,
      if (ville != null) 'ville': ville,
      if (secteur != null) 'secteur': secteur,
      if (address != null) 'address': address,
      if (nbrChambres != null) 'nbrChambres': nbrChambres,
      if (nbrSallesDeBain != null) 'nbrSallesDeBain': nbrSallesDeBain,
      if (nbrCuisine != null) 'nbrCuisine': nbrCuisine,
      if (nbrSalons != null) 'nbrSalons': nbrSalons,
      if (nbrEtage != null) 'nbrEtage': nbrEtage,
      if (nbrFacades != null) 'nbrFacades': nbrFacades,
      if (nbrBalcons != null) 'nbrBalcons': nbrBalcons,
      if (surfaceTotal != null) 'surfaceTotal': surfaceTotal,
      if (surfaceHabitable != null) 'surfaceHabitable': surfaceHabitable,
      if (ageDuBien != null) 'ageDuBien': ageDuBien,
      if (fraisDesSyndics != null) 'fraisDesSyndics': fraisDesSyndics,
      if (ascensseur != null) 'ascensseur': ascensseur,
      if (terrasse != null) 'terrasse': terrasse,
      if (meuble != null) 'meuble': meuble,
      if (climatisation != null) 'climatisation': climatisation,
      if (chauffage != null) 'chauffage': chauffage,
      if (cuisineEquipee != null) 'cuisineEquipee': cuisineEquipee,
      if (concierge != null) 'concierge': concierge,
      if (securite != null) 'securite': securite,
      if (parking != null) 'parking': parking,
      if (duplex != null) 'duplex': duplex,
      if (title != null) 'title': title,
      if (title_ar != null) 'title_ar': title_ar,
      if (description != null) 'description': description,
      if (description_ar != null) 'description_ar': description_ar,
      if (prix != null) 'prix': prix,
      if (miniature != null) 'miniature': miniature,
      if (images != null) 'images': images,
      // if (videos != null) 'videos': videos,
      if (mainVideo != null) 'mainVideo': mainVideo,
      if (introVideo != null) 'introVideo': introVideo,
      if (finalVideo != null) 'finalVideo': finalVideo,
      // if (voices != null) 'voices': voices,
      if (inStock != null) 'inStock': inStock,
      if (contact != null) 'contact': contact,
      if (location != null) 'location': location,
      if (createdTimeStamp != null) 'createdTimeStamp': createdTimeStamp,
    };
  }
}

class ProductsRecord {
  final _productsCollection = FirebaseFirestore.instance.collection('products');

  List<Product> _productsListFromSnapshot(QuerySnapshot query,
      bool Function(QueryDocumentSnapshot<Object?>)? condition) {
    final documents =
        condition != null ? query.docs.where(condition) : query.docs;
    return documents.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return Product(
        reference: doc.reference,
        googleDriveFolderId: data['googleDriveFolderId'],
        changed: data['changed'],
        hashtag: data['hashtag'],
        typedebien: data['typedebien'],
        ville: data['ville'],
        secteur: data['secteur'],
        address: data['address'],
        nbrChambres: data['nbrChambres'],
        nbrSallesDeBain: data['nbrSallesDeBain'],
        nbrCuisine: data['nbrCuisine'],
        nbrSalons: data['nbrSalons'],
        nbrEtage: data['nbrEtage'],
        nbrFacades: data['nbrFacades'],
        nbrBalcons: data['nbrBalcons'],
        surfaceTotal: data['surfaceTotal'],
        surfaceHabitable: data['surfaceHabitable'],
        ageDuBien: data['ageDuBien'],
        fraisDesSyndics: data['fraisDesSyndics'],
        ascensseur: data['ascensseur'],
        terrasse: data['terrasse'],
        meuble: data['meuble'],
        climatisation: data['climatisation'],
        chauffage: data['chauffage'],
        cuisineEquipee: data['cuisineEquipee'],
        concierge: data['concierge'],
        securite: data['securite'],
        parking: data['parking'],
        duplex: data['duplex'],
        title: data['title'],
        title_ar: data['title_ar'],
        description: data['description'],
        description_ar: data['description_ar'],
        prix: data['prix'],
        miniature: data['miniature'],
        images: data['images'],
        // videos: data['videos'],
        mainVideo: data['mainVideo'],
        introVideo: data['introVideo'],
        finalVideo: data['finalVideo'],
        // voices: data['voices'],
        inStock: data['inStock'],
        contact: data['contact'],
        location: data['location'],
        createdTimeStamp: data['createdTimeStamp'],
      );
    }).toList();
  }

  Stream<List<Product>> products(
      {bool Function(QueryDocumentSnapshot<Object?>)? condition}) {
    return _productsCollection
        .orderBy('createdTimeStamp', descending: true)
        .snapshots()
        .map((query) => _productsListFromSnapshot(query, condition));
  }

  List<Product> filterProductsList(
      List<Product> productsList, Map<String, dynamic> filters) {
    return productsList.where((product) {
      if (product.hashtag == (filters['hashtag'] ?? -1)) return true;
      if (filters['hashtag'] == null) if (product.changed ==
              (filters['changed'] ?? product.changed) &&
          product.typedebien == (filters['typedebien'] ?? product.typedebien) &&
          product.ville == (filters['ville'] ?? product.ville) &&
          product.secteur == (filters['secteur'] ?? product.secteur) &&
          product.nbrChambres ==
              (filters['nbrChambres'] ?? product.nbrChambres) &&
          product.nbrSallesDeBain ==
              (filters['nbrSallesDeBain'] ?? product.nbrSallesDeBain) &&
          product.nbrCuisine ==
              (filters['nbrCuisine'] ?? product.nbrCuisine) &&
          product.nbrSalons == (filters['nbrSalons'] ?? product.nbrSalons) &&
          product.nbrEtage == (filters['nbrEtage'] ?? product.nbrEtage) &&
          product.nbrFacades == (filters['nbrFacades'] ?? product.nbrFacades) &&
          product.nbrBalcons == (filters['nbrBalcons'] ?? product.nbrBalcons) &&
          product.ascensseur == (filters['ascensseur'] ?? product.ascensseur) &&
          product.terrasse == (filters['terrasse'] ?? product.terrasse) &&
          product.meuble == (filters['meuble'] ?? product.meuble) &&
          product.climatisation ==
              (filters['climatisation'] ?? product.climatisation) &&
          product.chauffage == (filters['chauffage'] ?? product.chauffage) &&
          product.cuisineEquipee ==
              (filters['cuisineEquipee'] ?? product.cuisineEquipee) &&
          product.concierge == (filters['concierge'] ?? product.concierge) &&
          product.securite == (filters['securite'] ?? product.securite) &&
          product.parking == (filters['parking'] ?? product.parking) &&
          product.duplex == (filters['duplex'] ?? product.duplex) &&
          (product.prix ?? 0.0) >=
              (filters['prixMin'] ?? product.prix ?? 0.0) &&
          (product.prix ?? 0.0) <=
              (filters['prixMax'] ?? product.prix ?? 0.0) &&
          (product.surfaceTotal ?? 0.0) >=
              (filters['surfaceTotalMin'] ?? product.surfaceTotal ?? 0.0) &&
          (product.surfaceTotal ?? 0.0) <=
              (filters['surfaceTotalMax'] ?? product.surfaceTotal ?? 0.0) &&
          (product.surfaceHabitable ?? 0.0) >=
              (filters['surfaceHabitable'] ??
                  product.surfaceHabitable ??
                  0.0) &&
          (product.surfaceHabitable ?? 0.0) <=
              (filters['surfaceHabitable'] ??
                  product.surfaceHabitable ??
                  0.0) &&
          product.inStock == (filters['inStock'] ?? product.inStock) &&
          product.contact == (filters['contact'] ?? product.contact)) {
        return true;
      }
      return false;
    }).toList();
  }

  Future<DocumentReference?> addProduct(Product product) async {
    try {
      if (product.reference != null &&
          (await product.reference?.get())?.id == product.reference?.id) {
            product.changed = true;
             product.changed = true;
        await product.reference!.update(product.toMap());
        return product.reference;
      } else
        return await _productsCollection.add(product.toMap());
    } catch (err) {
      print(err);
    }
  }

  Future<int> deleteVideos(Product product) async {
    final googleDrive = GoogleDrive();
    try {
      await googleDrive
          .deleteFileFromDrive(googleDrive.getIdfromLink(product.mainVideo));
      await googleDrive
          .deleteFileFromDrive(googleDrive.getIdfromLink(product.introVideo));
      await googleDrive
          .deleteFileFromDrive(googleDrive.getIdfromLink(product.finalVideo));
      product.mainVideo = null;
      product.introVideo = null;
      product.finalVideo = null;
      product.changed = true;
      product.changed = true;
      await product.reference?.update(product.toMap());
      var appDir = (await getTemporaryDirectory()).path;
      Directory(appDir).delete(recursive: true);
      return 0;
    } catch (err) {
      print(err);
      return 1;
    }
  }

  Future<int> delete(Product product) async {
    final googleDrive = GoogleDrive();
    try {
      for (var image in product.images ?? []) {
        await googleDrive.deleteFileFromDrive(googleDrive.getIdfromLink(image));
      }
      await googleDrive
          .deleteFileFromDrive(googleDrive.getIdfromLink(product.mainVideo));
      await googleDrive
          .deleteFileFromDrive(googleDrive.getIdfromLink(product.introVideo));
      await googleDrive
          .deleteFileFromDrive(googleDrive.getIdfromLink(product.finalVideo));
      await googleDrive.deleteFileFromDrive(product.googleDriveFolderId);
      var appDir = (await getTemporaryDirectory()).path;
      Directory(appDir).delete(recursive: true);
      await product.reference?.delete();
      return 0;
    } catch (err) {
      print(err);
      return 1;
    }
  }
}
