import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F5FF),
    appBar: kIsWeb
        ? AppBar(
            backgroundColor: const Color(0xFFF2F5FF),
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Reviews',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff613089),
                letterSpacing: 1.5,
              ),
            ),
          )
        : AppBar(
            backgroundColor: const Color(0xFFF2F5FF),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: const Text(
              'Reviews',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff613089),
                letterSpacing: 1.5,
              ),
            ),
          ),
    body: Builder(
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double contentWidth = screenWidth > 600 ? 900 : screenWidth;  

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth), 
                child: Column(
                  children: [
                 
                    Column(
                      children: [
                        const Text(
                          '4.0',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF613089),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              color: index < 4 ? Colors.amber : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'based on 23 reviews',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        _buildRatingBar('Excellent', Colors.green, 0.8),
                        _buildRatingBar('Good', Colors.lightGreen, 0.6),
                        _buildRatingBar('Average', Colors.yellow, 0.4),
                        _buildRatingBar('Below Average', Colors.orange, 0.2),
                        _buildRatingBar('Poor', Colors.red, 0.1),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildReviewCard(
                      imageUrl: 'https://via.placeholder.com/150',
                      username: 'Joan Perkins',
                      rating: 5,
                      date: '1 days ago',
                      comment:
                          'This chair is a great addition for any room in your home, not only just the living room. Featuring a mid-century design with modern available on the market.',
                    ),
                    _buildReviewCard(
                      imageUrl: 'https://via.placeholder.com/150',
                      username: 'Frank Garrett',
                      rating: 4,
                      date: '4 days ago',
                      comment:
                          'Suspendisse potenti. Nullam tincidunt lacus tellus, aliquam est vehicula. Pellentesque consectetur condimentum nulla.',
                    ),
                    _buildReviewCard(
                      imageUrl: 'https://via.placeholder.com/150',
                      username: 'Randy Palmer',
                      rating: 4,
                      date: '1 month ago',
                      comment:
                          'Aenean ante nisi, gravida non mattis semper, varius et turpis. Vivamus viverra, urna sed bibendum laoreet.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WriteReviewPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F5FF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 12,
                        ),
                        side: const BorderSide(
                          color: Color(0xFF613089),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Write a Review',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF613089),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}








  Widget _buildRatingBar(String label, Color color, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              color: color,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildReviewCard({
    required String imageUrl,
    required String username,
    required int rating,
    required String date,
    required String comment,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      rating,
                      (index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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




/////////////////////////////////////////////////////////




class WriteReviewPage extends StatefulWidget {
  @override
  _WriteReviewPageState createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  int _selectedStars = 0;
  String? _feedback;
  bool? _recommend;
  final TextEditingController _feedbackController = TextEditingController();


  
void _submitReview() {
  if (_selectedStars == 0 && _feedback == null && _recommend == null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xffF0E5FF), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color:Color(0xFF613089), size: 24), 
            SizedBox(width: 8),
            Text(
              'Incomplete!',
              style: TextStyle(
                color: Color(0xFF613089),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'CuteFont', 
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide at least one piece of feedback before submitting.',
              style: TextStyle(
                color: Color(0xFF613089),
                fontSize: 16,
                fontFamily: 'CuteFont', 
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Icon(Icons.error, color: Color(0xFF613089), size: 60), 
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Color(0xffF0E5FF), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), 
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF613089),
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xffF0E5FF), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
        ),
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Color(0xFF613089), size: 24), 
            SizedBox(width: 8),
            Text(
              'Thank You  :)',
              style: TextStyle(
                color: Color(0xFF613089),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'CuteFont', 
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your review has been submitted successfully!',
              style: TextStyle(
                color: Color(0xFF613089),
                fontSize: 16,
                fontFamily: 'CuteFont', 
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Icon(Icons.check_circle, color: Color(0xFF613089), size: 60), 
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); 
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xffF0E5FF), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), 
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF613089),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



///////////////////////////////////////////////



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
    appBar: kIsWeb
        ? AppBar(
            backgroundColor: const Color(0xFFF2F5FF),
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Write a Review',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff613089),
                letterSpacing: 1.5,
              ),
            ),
          )
        : AppBar(
            backgroundColor: const Color(0xFFF2F5FF),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: const Text(
              'Write a Review',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff613089),
                letterSpacing: 1.5,
              ),
            ),
          ),
      body: Builder(
        builder: (context) {
          double screenWidth = MediaQuery.of(context).size.width;
          double contentWidth = screenWidth > 600 ? 900 : screenWidth; 
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'How was your experience?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF613089),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedStars = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            color: index < _selectedStars ? Colors.amber[300] : Colors.grey[350],
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF613089),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      onChanged: (value) {
                        setState(() {
                          _feedback = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Write here...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF613089)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F5FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Do you recommend Dr. Mim?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF613089),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            activeColor: const Color(0xFF613089),
                            groupValue: _recommend,
                            onChanged: (value) {
                              setState(() {
                                _recommend = value;
                              });
                            },
                            title: const Text(
                              'Yes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF613089),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            value: false,
                            activeColor: const Color(0xFF613089),
                            groupValue: _recommend,
                            onChanged: (value) {
                              setState(() {
                                _recommend = value;
                              });
                            },
                            title: const Text(
                              'No',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF613089),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F5FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 12,
                          ),
                          side: const BorderSide(
                            color: Color(0xFF613089),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF613089),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}