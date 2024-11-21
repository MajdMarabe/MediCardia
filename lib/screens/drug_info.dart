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

            // Tip Section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Color(0xff613089),
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ensure the barcode is clear and well-lit for the best results.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
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

class DrugDetailsDialog extends StatelessWidget {
  final DrugDetails drugDetails;

  const DrugDetailsDialog({required this.drugDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            const Text(
              'Drug Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xff613089),
              ),
            ),
            const SizedBox(height: 15),

            // Use section
            _buildDetailRow('Use', drugDetails.use),
            const SizedBox(height: 10),

            // Dose section
            _buildDetailRow('Dose', drugDetails.dose),
            const SizedBox(height: 10),

            // Time section
            _buildDetailRow('Time', drugDetails.time),
            const SizedBox(height: 10),

            // Notes section with overflow handling and scrolling
            _buildDetailRow('Notes', drugDetails.notes, isMultiline: true),
            const SizedBox(height: 20),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
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

  Widget _buildDetailRow(String label, String value, {bool isMultiline = false}) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xff2a2a2a),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: isMultiline
              ? Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }
}
