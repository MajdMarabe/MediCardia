import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class DrugInteractionCheckerPage extends StatefulWidget {
  @override
  _DrugInteractionCheckerPageState createState() =>
      _DrugInteractionCheckerPageState();
}

class _DrugInteractionCheckerPageState
    extends State<DrugInteractionCheckerPage> {
  final TextEditingController _drugController = TextEditingController();
  List<String> drugs = [];
  String interactionMessage = '';
  String interactionDetails = '';
  List<String> interactionDrugs = [];
  List<String> drugSuggestions = []; 
  bool isSuggestionsVisible = false; 


  
  // Function to get drug suggestions based on user input
  Future<void> _getDrugSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        drugSuggestions.clear();
        isSuggestionsVisible = false;
      });
      return;
    }

     String apiUrl = '${ApiConstants.baseUrl}/drugs/suggestions';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          drugSuggestions =
              data.map<String>((item) => item['name'] as String).toList();
          isSuggestionsVisible = drugSuggestions.isNotEmpty;
        });
      } else {
        setState(() {
          drugSuggestions.clear();
          isSuggestionsVisible = false;
        });
      }
    } catch (e) {
      setState(() {
        drugSuggestions.clear();
        isSuggestionsVisible = false;
      });
    }
  }

  void _addDrug(String drugName) {
    if (drugName.isNotEmpty) {
      setState(() {
        drugs.add(drugName);
        _drugController.clear(); 
        drugSuggestions.clear(); 
        isSuggestionsVisible = false; 
      });

      if (drugs.length >= 2) {
        _checkForInteractions();
      }
    }
  }

  Future<void> _checkForInteractions() async {
     String apiUrl = '${ApiConstants.baseUrl}/drugs/checkDrugInteractions';

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
        return references
            .map<String>((item) => item['text'].toString())
            .toList();
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
      appBar: kIsWeb
          ? AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Drugs Interaction Checker',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                  letterSpacing: 1.5,
                ),
              ),
              automaticallyImplyLeading: false,
            )
          : AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Drugs Interaction Checker',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                  letterSpacing: 1.5,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth =
              constraints.maxWidth > 600 ? 700 : constraints.maxWidth;

          // Conditionally wrap the content with Center widget based on the platform
          Widget bodyContent = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Field for Drugs
                    TypeAheadFormField<String>(
                      debounceDuration: const Duration(milliseconds: 300),
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
                            borderSide:
                                const BorderSide(color: Color(0xffb41391), width: 2.0),
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
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),

                  
                    ElevatedButton(
                      onPressed: () => _addDrug(_drugController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff613089),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: constraints.maxWidth * 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xff613089),
                      ),
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
                    ),
                    const SizedBox(height: 20),

                    // Display Drug Suggestions
                    if (isSuggestionsVisible) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: drugSuggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(drugSuggestions[index]),
                            onTap: () {
                              _addDrug(drugSuggestions[index]);
                            },
                          );
                        },
                      ),
                    ],

                    // Display Interaction Message
                    if (interactionMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: interactionMessage.contains('Some interactions found')
                              ? const Color.fromARGB(255, 153, 105, 177)
                              : Colors.blueGrey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                interactionMessage,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (interactionMessage.contains('Some interactions found')) ...[
                              const SizedBox(height: 10),
                              const Center(
                                child: Text(
                                  'See details below',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // If no drugs are added
                    if (drugs.isEmpty) ...[
                      const Text(
                        '• Add a full drug regimen and view interactions.',
                        style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Display Drugs List
                    if (drugs.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Patient Regimen',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff613089),
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearAllDrugs,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.clear_all,
                                  color: Color(0xff613089),
                                  size: 20,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff613089),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: drugs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              drugs[index],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xff613089),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Color(0xff613089)),
                              onPressed: () {
                                setState(() {
                                  drugs.removeAt(index);
                                  if (drugs.isEmpty) {
                                    _clearAllDrugs();
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],

                    // Display Interaction Details
                    if (interactionMessage.contains('Some interactions found')) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Drugs Involved in Interaction:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff613089),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: interactionDrugs.map((drug) {
                                return Chip(
                                  label: Text(
                                    drug,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xff613089),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Interaction Details:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff613089),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              interactionDetails,
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );

          
          return kIsWeb ? Center(child: bodyContent) : bodyContent;
        },
      ),
    );
  }
}