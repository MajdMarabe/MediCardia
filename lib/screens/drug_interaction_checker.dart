import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _drugController,
              decoration: InputDecoration(
                labelText: 'Enter a drug, OTC or herbal supplement',
                labelStyle: const TextStyle(color: Color(0xff613089)),
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

            if (interactionMessage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: interactionMessage.contains('Some interactions found')
                      ? const Color.fromARGB(255, 153, 105, 177)
                      :  Colors.blueGrey.shade200,
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

            if (drugs.isEmpty) ...[
              const Text(
                '• Add a full drug regimen and view interactions.',
                style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
              ),
              const SizedBox(height: 30),
            ],

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
                    title: Text(drugs[index],style: const TextStyle(
          fontSize: 18,
          //fontWeight: FontWeight.w600,
          color: Color(0xff613089), 
        ),),
                    
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline,color: Color(0xff613089)),
                      onPressed: () {
                        setState(() {
                          drugs.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ],

            // Show interaction details only if interactions were found
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
    );
  }
}
