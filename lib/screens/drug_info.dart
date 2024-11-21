import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'; // Import the package

// Mock Drug Data
class DrugDetails {
  final String use;
  final String dose;
  final String time;
  final String notes;

  DrugDetails({required this.use, required this.dose, required this.time, required this.notes});
}

class DrugInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Barcode Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xff613089),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // Scanner Area
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade50,
                          Colors.purple.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  // Use the barcode.png image as an icon
                  Image.asset(
                    'assets/images/barcode.png', // The path to your image
                    width: 150,
                    height: 150,
                    color: Colors.purple.shade300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Instruction Text
            const Center(
              child: Text(
                "Scan any drug barcode to view details.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Modern Scan Button
            ElevatedButton(
              onPressed: () async {
                String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
                  "#ff6666", // Color for the scan line
                  "Cancel", // Cancel button text
                  true, // Show flash icon
                  ScanMode.BARCODE, // Scan mode (can also be QR_CODE)
                );
                if (barcodeScanResult != "-1") {
                  // Simulate fetching drug details after scanning
                  DrugDetails drugDetails = DrugDetails(
                    use: "Pain relief",
                    dose: "6 months",
                    time: "Once a day",
                    notes: "Take with food for better absorption",
                  );

                  // Show a dialog or overlay with the drug details
                  showDialog(
                    context: context,
                    builder: (context) {
                      return DrugDetailsDialog(drugDetails: drugDetails);
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff613089), // Button color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: const Color(0xff613089),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/barcode.png', // The path to your image
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Scan Medicine Barcode',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Additional Info
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade50,
                    Colors.purple.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                color: Colors.purple.shade200, // Updated background color
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Position the barcode within the scanner frame.\n'
                    '• Hold still while the scanner processes the barcode.\n'
                    '• Ensure the barcode is clear and well-lit for the best results.\n'
                    '• Get detailed information about the scanned drug.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Dialog to show drug details
class DrugDetailsDialog extends StatelessWidget {
  final DrugDetails drugDetails;

  const DrugDetailsDialog({required this.drugDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Drug Details',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff613089)),
            ),
            const SizedBox(height: 15),
            Text(
              'Use: ${drugDetails.use}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Dose: ${drugDetails.dose}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Time: ${drugDetails.time}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Notes: ${drugDetails.notes}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff613089),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
