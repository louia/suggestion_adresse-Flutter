import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suggestion d\'adresse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Suggestion d\'adresse FRANCE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _petitStyle = TextStyle(color: Colors.black38, fontSize: 14);

  var _codePController = TextEditingController();
  var _adresseController = TextEditingController();
  var _villeController = TextEditingController();

  String _valeureRue;
  String _valeureCodeP;
  String _valeurVille;

  String _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: this._formKey,
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Text(
                      "Rue",
                      style: _petitStyle,
                    ),
                    TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: _adresseController,
                      ),
                      suggestionsCallback: (pattern) async {
                        return await getSuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion["nom"]),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (suggestion) {
                        _adresseController.text = suggestion['rue'];
                        _codePController.text = suggestion['cp'];
                        _villeController.text = suggestion['ville'];
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                      onSaved: (value) => this._selectedCity = value,
                    ),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Text(
                      "Ville",
                      style: _petitStyle,
                    ),
                    TextFormField(
                      controller: _villeController,
                    ),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Text(
                      "Code postal",
                      style: _petitStyle,
                    ),
                    TextFormField(
                      controller: _codePController,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getSuggestions(String pattern) async {
    var result;
    if (pattern != '') {
      print(Uri.encodeFull(pattern));
      result = await http.get('https://api-adresse.data.gouv.fr/search/?q=' +
          Uri.encodeFull(pattern) +
          '&type=housenumber&autocomplete=1');
      if (result.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(result.body);
        List<Map<String, Object>> finish = new List<Map<String, Object>>();

        for (int i = 0; i < json["features"].length; i++) {
          finish.add({
            "nom": json["features"][i]["properties"]["label"],
            "coord" : json["features"][i]["geometry"]["coordinates"][1].toString() + "," + json["features"][i]["geometry"]["coordinates"][0].toString(),
            "ville" : json["features"][i]["properties"]["city"].toString(),
            "cp" : json["features"][i]["properties"]["postcode"].toString(),
            "rue" : json["features"][i]["properties"]["name"].toString(),
          });
        }
        return finish;
      } else {
        throw Exception('Failed to fetch.');
      }
    }
  }
}

