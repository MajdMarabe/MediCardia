import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'constants.dart';

class DrugInteractionCheckerPage extends StatefulWidget {
  @override
  _DrugInteractionCheckerPageState createState() =>
      _DrugInteractionCheckerPageState();
}

class _DrugInteractionCheckerPageState
    extends State<DrugInteractionCheckerPage> {
  TextEditingController _drugController = TextEditingController();
  List<String> drugs = [];
  String interactionMessage = '';
  String interactionDetails = '';
  List<String> interactionDrugs = [];

  void _addDrug() {
    String drugName = _drugController.text.trim();
    if (drugName.isNotEmpty) {
      setState(() {
        drugs.add(drugName);
        _drugController.clear(); // Clear the input field
      });

      if (drugs.length >= 2) {
        _checkForInteractions();
      }
    }
  }

  Future<void> _checkForInteractions() async {
    final String apiUrl = '${ApiConstants.baseUrl}/drugs/checkDrugInteractions';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'drugs': drugs}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          final interactions = data['interactions'] ?? {};
          final errorCode = interactions['errorCode'] as int? ?? 0;

          if (errorCode == 1) {
            interactionMessage = 'Some interactions found:';
            final multiInteractions =
                interactions['multiInteractions'] as List<dynamic>? ?? [];

            interactionDrugs = multiInteractions
                .map<String>((interaction) =>
                    '${interaction['subject']} and ${interaction['object']}')
                .toList();

            interactionDetails = multiInteractions
                .map<String>((interaction) => '${interaction['text']}')
                .join("\n");
          } else {
            interactionMessage = 'No interactions found.';
            interactionDrugs = [];
            interactionDetails = '';
          }
        });
      } else {
        setState(() {
          interactionMessage = 'Error: ${jsonDecode(response.body)['error']}';
          interactionDrugs = [];
          interactionDetails = '';
        });
      }
    } catch (e) {
      setState(() {
        interactionMessage = 'Error: Unable to fetch interactions. $e';
        interactionDrugs = [];
        interactionDetails = '';
      });
    }
  }

  Future<List<String>> _fetchDrugSuggestions(String query) async {
    final String apiUrl =
        'https://www.medscape.com/api/quickreflookup/LookupService.ashx?q=$query&sz=500&type=10417&metadata=has-interactions&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final cleanedResponse =
            response.body.replaceAll(RegExp(r'^MDICshowResults\(|\);?$'), '');
        final Map<String, dynamic> data = json.decode(cleanedResponse);
        final List<dynamic> references = data['types'][0]['references'];
        return references.map<String>((item) => item['text'].toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  void _clearAllDrugs() {
    setState(() {
      drugs.clear();
      interactionDrugs.clear();
      interactionMessage = '';
      interactionDetails = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Drugs Interaction Checker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TypeAheadFormField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _drugController,
                decoration: InputDecoration(
                  labelText: 'Enter a drug, OTC or herbal supplement',
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              suggestionsCallback: _fetchDrugSuggestions,
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                _drugController.text = suggestion;
              },
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _addDrug,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add Drug',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff613089),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: const Color(0xff613089),
              ),
            ),
            const SizedBox(height: 20),

            if (drugs.isNotEmpty) ...[
              const Text(
                'Patient Regimen:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
              ),
              ...drugs.map((drug) => ListTile(
                    title: Text(drug),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Color(0xff613089)),
                      onPressed: () {
                        setState(() {
                          drugs.remove(drug);
                        });
                      },
                    ),
                  )),
            ],

            if (interactionMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                interactionMessage,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              if (interactionDrugs.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...interactionDrugs.map((interaction) => Text(interaction)),
                const SizedBox(height: 10),
                Text(interactionDetails),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
