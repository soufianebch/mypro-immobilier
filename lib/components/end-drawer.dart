import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:mypro_immobilier/shared/my_varriables.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class EndDrawer extends StatefulWidget {
  EndDrawer({Key? key, required this.filters, required this.callBack})
      : super(key: key);
  final Function(Map<String, dynamic>) callBack;

  /// [filters] is a Map of:
  /// hashtag, typedebien, ville, secteur, nbrChambres, nbrSallesDeBain, nbrSalons, nbrEtage, nbrFacades, ascensseur, terrasse, meuble, climatisation, chauffage, cuisineEquipee, concierge, securite, parking, duplex, prixMin, prixMax, surfaceTotalMin, surfaceTotalMax, surfaceHabitable, surfaceHabitable, inStock, contact
  final Map<String, dynamic> filters;
  @override
  _EndDrawerState createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  List<String> selectList = [];
  late final Map<String, List<String>> villes;
  late SfRangeValues _superficieRange;
  late SfRangeValues _prixRange;
  late final hashTagController;
  late final nbrChambresController;
  late final nbrSalonsController;
  late final salleDeBainController;

  toggleToList(List<String> selectList, String value) {
    setState(() {
      if (selectList.contains(value)) {
        selectList.remove(value);
        search(value, null);
      } else {
        selectList.add(value);
        search(value, true);
      }
    });
  }

  /// a [key] could be:
  /// hashtag, typedebien, ville, secteur, nbrChambres, nbrSallesDeBain, nbrSalons, nbrEtage, nbrFacades, ascensseur, terrasse, meuble, climatisation, chauffage, cuisineEquipee, concierge, securite, parking, duplex, prixMin, prixMax, surfaceTotalMin, surfaceTotalMax, surfaceHabitable, surfaceHabitable, inStock, contact
  search(String key, dynamic value) {
    widget.filters['hashtag'] = null;
    setState(() {
      widget.filters[key] = value == '' ? null : value;
    });
    widget.callBack(widget.filters);
  }

  @override
  void initState() {
    villes = MyVarriables.villes;
    hashTagController =
        TextEditingController(); //text:'${widget.filters['hashtag']??''}'
    nbrChambresController =
        TextEditingController(text: '${widget.filters['nbrChambres'] ?? ''}');
    nbrSalonsController =
        TextEditingController(text: '${widget.filters['nbrSalons'] ?? ''}');
    salleDeBainController = TextEditingController(
        text: '${widget.filters['nbrSallesDeBain'] ?? ''}');

    _superficieRange = SfRangeValues(widget.filters['surfaceTotalMin'] ?? 0,
        widget.filters['surfaceTotalMax'] ?? 400);
    _prixRange = SfRangeValues((widget.filters['prixMin'] ?? 0) / 10000,
        (widget.filters['prixMax'] ?? 4000000) / 10000);

    widget.filters.forEach((key, value) {
      if (value == true) selectList.add(key);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  width: 150,
                  child: TextFormField(
                    controller: hashTagController,
                    obscureText: false,
                    onFieldSubmitted: (value) {
                      widget.callBack(
                        {'hashtag': value == '' ? null : int.parse(value)},
                      );
                      Navigator.pop(context);
                    },
                    decoration: InputDecoration(
                      labelText: '#',
                      labelStyle:
                          Theme.of(context).textTheme.bodyText1!.copyWith(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                              ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                        ),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                        ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                Divider(
                  height: 50,
                  thickness: 0.5,
                  indent: 0,
                  endIndent: 0,
                  color: MyTheme.secondaryColor,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
                        child: Text(
                          'Ville:',
                          style:
                              Theme.of(context).textTheme.headline2!.copyWith(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                  ),
                        ),
                      ),
                      SizedBox(width: 25),
                      Container(
                        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        width: 190,
                        height: 40,
                        child: DropdownButtonFormField(
                          items: villes.entries.map(
                            (e) {
                              var ville = e.key;
                              return new DropdownMenuItem(
                                  value: ville,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.location_city, size: 17),
                                      SizedBox(width: 5),
                                      Container(
                                          width: 123,
                                          child: FittedBox(
                                              alignment: Alignment.centerLeft,
                                              fit: BoxFit.scaleDown,
                                              child: Text(ville))),
                                    ],
                                  ));
                            },
                          ).toList(),
                          onChanged: (String? value) {
                            search('ville', value);
                            search('secteur', null);
                          },
                          value: widget.filters['ville'] as String?,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                  ),
                          elevation: 2,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 0,
                                  color: Colors.transparent,
                                )),
                            fillColor: MyTheme.tertiaryColor,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            errorStyle: TextStyle(fontSize: 0, height: 0),
                          ),
                          validator: (value) => value == null ? '' : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (villes[widget.filters['ville']] != null &&
                    villes[widget.filters['ville']]!.length > 0)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
                          child: Text(
                            'Secteur:',
                            style:
                                Theme.of(context).textTheme.headline2!.copyWith(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                    ),
                          ),
                        ),
                        SizedBox(width: 0),
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 0, 8, 4),
                          width: 190,
                          height: 40,
                          child: DropdownButtonFormField(
                            items:
                                villes[widget.filters['ville']]?.map((secteur) {
                              return new DropdownMenuItem(
                                  value: secteur,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.location_on, size: 17),
                                      SizedBox(width: 5),
                                      Container(
                                        width: 123,
                                        child: FittedBox(
                                            alignment: Alignment.centerLeft,
                                            fit: BoxFit.scaleDown,
                                            child: Text(secteur)),
                                      ),
                                    ],
                                  ));
                            }).toList(),
                            onChanged: (String? value) {
                              search('secteur', value);
                            },
                            value: widget.filters['secteur'] as String?,
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic,
                                    ),
                            elevation: 2,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: Colors.transparent,
                                  )),
                              fillColor: MyTheme.tertiaryColor,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 10),
                              errorStyle: TextStyle(fontSize: 0, height: 0),
                            ),
                            validator: (value) => value == null ? '' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DetaitsDuBienWidget(
                        controller: nbrSalonsController,
                        onChanged: (value) => search(
                            'nbrSalons', value == '' ? null : int.parse(value)),
                        icon: Icon(
                          Icons.chair,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      DetaitsDuBienWidget(
                        controller: nbrChambresController,
                        onChanged: (value) => search('nbrChambres',
                            value == '' ? null : int.parse(value)),
                        icon: FaIcon(
                          FontAwesomeIcons.bed,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                      // DetaitsDuBienWidget(
                      //   controller: nbrEtageController,
                      //   icon: Icon(
                      //     Icons.stairs,
                      //     color: Colors.black,
                      //     size: 24,
                      //   ),
                      // ),
                      DetaitsDuBienWidget(
                        controller: salleDeBainController,
                        onChanged: (value) => search('nbrSallesDeBain',
                            value == '' ? null : int.parse(value)),
                        icon: FaIcon(
                          FontAwesomeIcons.shower,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.5,
                  indent: 50,
                  endIndent: 50,
                  color: MyTheme.secondaryColor,
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
                      child: Text(
                        'Superficie: (m²)',
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                            ),
                      ),
                    ),
                    SfRangeSlider(
                      values: _superficieRange,
                      min: 0,
                      max: 400,
                      tooltipShape: SfPaddleTooltipShape(),
                      tooltipTextFormatterCallback:
                          (actualValue, formattedText) =>
                              '${(actualValue as num).floor()}',
                      startThumbIcon: Container(
                          padding: EdgeInsets.all(5),
                          child: FittedBox(
                              child: Text(
                            '${(_superficieRange.start as num).floor()}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))),
                      endThumbIcon: Container(
                          padding: EdgeInsets.all(5),
                          child: FittedBox(
                              child: Text(
                            '${(_superficieRange.end as num).floor()}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))),
                      enableTooltip: true,
                      showLabels: true,
                      labelFormatterCallback: (actualValue, formattedText) {
                        if (actualValue == 400)
                          return 'Max';
                        else if (actualValue == 0)
                          return 'Min';
                        else
                          return '';
                      },
                      onChanged: (SfRangeValues values) {
                        setState(() {
                          _superficieRange = values;
                        });
                        search('surfaceTotalMin', values.start.floor());
                        search('surfaceTotalMax', values.end.floor());
                      },
                    )
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
                      child: Text(
                        'Prix: (10 KDhs)',
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                            ),
                      ),
                    ),
                    SfRangeSlider(
                      values: _prixRange,
                      min: 0,
                      max: 400,
                      tooltipShape: SfPaddleTooltipShape(),
                      tooltipTextFormatterCallback:
                          (actualValue, formattedText) =>
                              '${(actualValue as num).floor()}',
                      startThumbIcon: Container(
                          padding: EdgeInsets.all(5),
                          child: FittedBox(
                              child: Text(
                            '${(_prixRange.start as num).floor()}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))),
                      endThumbIcon: Container(
                          padding: EdgeInsets.all(5),
                          child: FittedBox(
                              child: Text(
                            '${(_prixRange.end as num).floor()}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))),
                      enableTooltip: true,
                      showLabels: true,
                      labelFormatterCallback: (actualValue, formattedText) {
                        if (actualValue == 400)
                          return 'Max';
                        else if (actualValue == 0)
                          return 'Min';
                        else
                          return '';
                      },
                      onChanged: (SfRangeValues values) {
                        setState(() {
                          _prixRange = values;
                        });
                        search('prixMin', values.start.floor() * 10000);
                        search('prixMax', values.end.floor() * 10000);
                      },
                    )
                  ],
                ),
                Divider(
                  thickness: 0.5,
                  indent: 50,
                  endIndent: 50,
                  color: MyTheme.secondaryColor,
                ),
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width - 20,
                  margin: EdgeInsets.only(top: 10, bottom: 30),
                  child: GridView(
                      scrollDirection: Axis.horizontal,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.24,
                        // mainAxisExtent: 90,
                      ),
                      children: [
                        Capsule(
                          value: 'ascensseur',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'terrasse',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'meuble',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'climatisation',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'chauffage',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'cuisine Equipe',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'concierge',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'securite',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'parking',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                        Capsule(
                          value: 'duplex',
                          selectList: selectList,
                          onTap: (value) => toggleToList(selectList, value),
                        ),
                      ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetaitsDuBienWidget extends StatelessWidget {
  const DetaitsDuBienWidget(
      {Key? key, required this.controller, required this.icon, this.onChanged})
      : super(key: key);

  final TextEditingController controller;
  final Function(String)? onChanged;
  final icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Color(0x00FFFFFF),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          icon,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              obscureText: false,
              textInputAction: TextInputAction.next,
              validator: (value) => value == '' ? '' : null,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                isDense: true,
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black.withAlpha(70),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: MyTheme.primaryColor,
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0),
                  ),
                ),
              ),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontFamily: 'Poppins',
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}

class Capsule extends StatelessWidget {
  Capsule(
      {Key? key, required this.value, this.selectList = const [], this.onTap});
  final String value;
  final List selectList;
  final Function(String value)? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: InkWell(
          onTap: () => onTap?.call(value),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: CircleAvatar(
                    child: Icon(
                      Icons.check,
                      size: 15,
                      color: selectList.contains(value)
                          ? Colors.white
                          : Colors.black,
                    ),
                    backgroundColor: selectList.contains(value)
                        ? MyTheme.primaryColor
                        : Colors.transparent,
                    maxRadius: 13,
                  ),
                ),
                Container(
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
