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
  List<String> interactionDrugs = []; // List to hold drugs involved in interaction

  // Function to add drug to the list
  void _addDrug() {
    String drugName = _drugController.text.trim();
    if (drugName.isNotEmpty) {
      setState(() {
        // Add drug to the list
        drugs.add(drugName);

        // Check if there are two or more drugs entered to evaluate interaction
        if (drugs.length >= 2) {
          // Check for interactions (for demonstration purposes, using a simple condition)
          interactionMessage = _checkForInteractions();
          // Check the interaction details based on the drugs entered
          interactionDetails = _getInteractionDetails();
        }

        _drugController.clear(); // Clear the text input after adding the drug
      });
    }
  }

  // Function to check if any interactions exist
  String _checkForInteractions() {
    if (drugs.contains('Aspirin') && !drugs.contains('Ibuprofen')) {
      interactionDrugs.add('Aspirin');
      interactionDrugs.add('Ibuprofen');
      return 'Aspirin may interact with Ibuprofen!';
    } else if (drugs.contains('Ibuprofen') && !drugs.contains('Aspirin')) {
      interactionDrugs.add('Ibuprofen');
      interactionDrugs.add('Aspirin');
      return 'Ibuprofen may interact with Aspirin!';
    } else {
      return 'No known interactions with the current drug regimen.';
    }
  }

  // Function to generate interaction details
  String _getInteractionDetails() {
    if (interactionDrugs.isNotEmpty) {
      return 'Detailed interaction: ${interactionDrugs.join(', ')} may cause an adverse reaction when combined with each other.';
    } else {
      return '';
    }
  }

  // Function to clear all drugs
  void _clearAllDrugs() {
    setState(() {
      drugs.clear();
      interactionDrugs.clear(); // Clear drugs causing interaction
      interactionMessage = ''; // Clear the interaction message when drugs are cleared
      interactionDetails = ''; // Clear interaction details as well
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Drug Interaction Checker',
         style: TextStyle(fontWeight: FontWeight.bold),
        ),
         backgroundColor: Color(0xff613089),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Drug search field
            TextField(
              controller: _drugController,
              decoration: InputDecoration(
                labelText: 'Enter a drug, OTC or herbal supplement',
                labelStyle: const TextStyle(color: Color(0xff613089)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xffb41391), width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Modern "Add Drug" button with gradient and icon
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
                backgroundColor: const Color(0xff613089), // Background color
                foregroundColor: Colors.white, // Text and icon color
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: const Color(0xff613089),
              ),
            ),
            const SizedBox(height: 20),

            // Display the interaction message if exists
            if (interactionMessage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              
                decoration: BoxDecoration(
                  color: interactionMessage.contains('may interact')
                      ? Colors.red
                      : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Center( // Center the text for the main message
                      child: Text(
                        interactionMessage,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Show "See details below" prompt if there is an interaction
                    if (interactionMessage.contains('may interact')) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'See details below',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Show introductory texts only if no drugs are added
            if (drugs.isEmpty) ...[
              const Text(
                'Drug Interaction Checker',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '• Add a full drug regimen and view interactions.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 30),
            ],

            // Display added drugs
            if (drugs.isNotEmpty) ...[
              // Clear All button on the right of the Patient Regimen row
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
                physics: NeverScrollableScrollPhysics(),
                itemCount: drugs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(drugs[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline),
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

            // Display interaction details in a more user-friendly way
            if (interactionDetails.isNotEmpty) ...[
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
                      spacing: 8, // space between the drug names
                      children: interactionDrugs.map((drug) {
                        return Chip(
                          label: Text(
                            drug,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xff613089),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
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
