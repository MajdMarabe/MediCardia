import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'constants.dart'; // For making HTTP requests
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Review {
  final String username;
  final int rating;
  final String date;
  final String comment;

  Review({
    required this.username,
    required this.rating,
    required this.date,
    required this.comment,
  });

  // A method to convert JSON data into a Review object
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      username: json['username'],
      rating: json['rating'],
      date: json['date'],
      comment: json['comment'],
    );
  }
}

class ReviewsPage extends StatefulWidget {
 final String doctorid;
  const ReviewsPage({Key? key, required this.doctorid}) : super(key: key);
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  double averageRating = 0.0;
  int reviewCount = 0;
  bool isLoading = true;
List<Review> reviews = [];

Map<String, int> ratingDistribution = {
  'Excellent': 0,
  'Good': 0,
  'Average': 0,
  'Below Average': 0,
  'Poor': 0,
};

  @override
  void initState() {
    super.initState();
    fetchRatingData();
  }

  Future<void> fetchRatingData() async {
    final apiUrl = '${ApiConstants.baseUrl}/rating/${widget.doctorid}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['reviewCount'] == 0 || data['recentReviews'] == null) {
          setState(() {
            averageRating = 0.0;
            reviewCount = 0;
            reviews = [];
            ratingDistribution = {
              'Excellent': 0,
              'Good': 0,
              'Average': 0,
              'Below Average': 0,
              'Poor': 0,
            };
            isLoading = false;
          });
          return;
        }

        setState(() {
          ratingDistribution = {
            'Excellent': data['ratingDistribution']['excellent'],
            'Good': data['ratingDistribution']['good'],
            'Average': data['ratingDistribution']['average'],
            'Below Average': data['ratingDistribution']['belowAverage'],
            'Poor': data['ratingDistribution']['poor'],
          };
          averageRating = (data['averageRating'] is int)
              ? (data['averageRating'] as int).toDouble()
              : data['averageRating'] is double
                  ? data['averageRating']
                  : 0.0;
          reviewCount = data['reviewCount'] ?? 0;
          reviews = (data['recentReviews'] as List)
              .map((reviewData) => Review.fromJson(reviewData))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
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
    body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                if (reviewCount == 0)
                  const Center(
                    child: Text(
                      'No reviews available yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                else ...[
                  Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
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
                            color: index < averageRating.round()
                                ? Colors.amber
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'based on $reviewCount reviews',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: ratingDistribution.entries.map((entry) {
                      return _buildRatingBar(
                        entry.key,
                        _getRatingColor(entry.key),
                        entry.value.toDouble() / (reviewCount > 0 ? reviewCount : 1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ...reviews.map((review) => _buildReviewCard(
                        imageUrl: '', // Replace with actual image URL
                        username: review.username,
                        rating: review.rating,
                        date: review.date,
                        comment: review.comment,
                      )),
                ],
                const SizedBox(height: 16),
                /*ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WriteReviewPage(doctorid: widget.doctorid),
                      ),
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
                ),*/
              ],
            ),
          ),
        ),
      ),

    );
  }

Color _getRatingColor(String category) {
  switch (category) {
    case 'Excellent':
      return Colors.green;
    case 'Good':
      return Colors.lightGreen;
    case 'Average':
      return Colors.yellow;
    case 'Below Average':
      return Colors.orange;
    case 'Poor':
      return Colors.red;
    default:
      return Colors.grey;
  }}
Widget _buildReviewCard({
  required String imageUrl,
  required String username,
  required int rating,
  required String date,
  required String comment,
}) {
  return Card(
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
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
            ),
          ),
        ],
      ),
    );
  }
}


/////////////////////////////////////////////////////////

