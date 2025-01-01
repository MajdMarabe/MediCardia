const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const Review = require("../models/Rating");
const {Doctor}= require("../models/Doctor");

const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const {verifyTokenAndAuthorization , verifyTokenAndAdmin}=require("../middlewares/verifyToken");

/**
 * @desc Get all reviews for a specific doctor
 * @route /api/reviews/:doctorId
 * @method GET
 * @access Public
 */
module.exports.getDoctorReviews = asyncHandler(async (req, res) => {
    const { doctorId } = req.params;

    // Validate doctorId
    if (!doctorId) {
        return res.status(400).json({ message: "Doctor ID is required." });
    }

    // Fetch reviews for the doctor
    const reviews = await Review.find({ doctorId }).populate('userId', 'username');

    res.status(200).json({
        doctorId,
        reviews,
    });
});

/**
 * @desc Get average rating, review distribution, and reviews for a doctor
 * @route /api/reviews/summary/:doctorId
 * @method GET
 * @access Public
 */
module.exports.getDoctorReviewSummary = asyncHandler(async (req, res) => {
    const { doctorId } = req.params;

    // Validate doctorId
    const doctor = await Doctor.findById(doctorId);
    if (!doctor) {
        return res.status(404).json({ message: "Doctor not found." });
    }

    // Fetch all active reviews for the doctor
    const reviews = await Review.find({ doctorId })
        .populate('userId', 'username profileImage')
        .sort({ createdAt: -1 });

    if (!reviews.length) {
        return res.status(200).json({
            averageRating: 0,
            reviewCount: 0,
            ratingDistribution: { excellent: 0, good: 0, average: 0, belowAverage: 0, poor: 0 },
            recentReviews: [],
        });
    }

    // Calculate average rating and distribution
    const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
    const averageRating = (totalRating / reviews.length).toFixed(1);
    const reviewCount = reviews.length;
    await Doctor.findByIdAndUpdate(doctorId, {  averageRating: averageRating  });

    const ratingDistribution = {
        excellent: reviews.filter((r) => r.rating === 5).length,
        good: reviews.filter((r) => r.rating === 4).length,
        average: reviews.filter((r) => r.rating === 3).length,
        belowAverage: reviews.filter((r) => r.rating === 2).length,
        poor: reviews.filter((r) => r.rating === 1).length,
    };

    // Limit recent reviews to the latest 5
    const recentReviews = reviews.slice(0, 5).map((review) => ({
        username: review.userId.username,
        //imageUrl: review.userId.image || 'https://via.placeholder.com/150',
        rating: review.rating,
        date: review.createdAt.toDateString(),
        comment: review.review,
    }));

    res.status(200).json({
        averageRating: parseFloat(averageRating),
        reviewCount,
        ratingDistribution,
        recentReviews,
    });
});

/**
 * @desc Get top 5 doctors by average rating
 * @route /api/rating/top/rated
 * @method GET
 * @access Public
 */

module.exports.getTopRatedDoctors = asyncHandler(async (req, res) => {
    try {
        // Fetch top 5 doctors sorted by averageRating in descending order
        const topDoctors = await Doctor.find()
            .sort({ averageRating: -1 }) // Sort by averageRating descending
            .limit(5) // Limit to top 5 doctors
            .select('fullName phone specialization workplace numberOfPatients averageRating numberOfReviews'); // Select required fields

        // Check if doctors are found
        if (!topDoctors.length) {
            return res.status(404).json({ message: 'No doctors found.' });
        }

        // Return the data
        res.status(200).json({
            message: 'Top-rated doctors fetched successfully.',
            data: topDoctors.map((doctor) => ({
                id: doctor._id,
                name: doctor.fullName,
                speciality: doctor.specialization,
                image: doctor.image || 'https://via.placeholder.com/150',
                averageRating: doctor.averageRating,
                workplace: doctor.workplace,
                phone:doctor.phone,
                numberOfPatients :doctor.numberOfPatients,
                numberOfReviews:doctor.numberOfReviews,
            })),
        });
    } catch (error) {
        console.error('Error fetching top-rated doctors:', error);
        res.status(500).json({ message: 'An error occurred while fetching top-rated doctors.' });
    }
});



/**
 * @desc Add a new review for a doctor
 * @route /api/reviews
 * @method POST
 * @access Private (User authentication required)
 */
module.exports.addReview = asyncHandler(async (req, res) => {
    const { doctorId, rating, review } = req.body;

    // Validate the input
    if (!doctorId || !rating || rating < 1 || rating > 5) {
        return res.status(400).json({ message: "Invalid data. Ensure doctorId and valid rating are provided." });
    }

    // Check if the user has already reviewed the doctor
    const existingReview = await Review.findOne({ doctorId, userId: req.user.id });
    if (existingReview) {
        return res.status(400).json({ message: "You have already reviewed this doctor." });
    }

    // Create a new review
    const newReview = new Review({
        doctorId,
        userId: req.user.id,
        rating,
        review,
    });

    await newReview.save();
    await Doctor.findByIdAndUpdate(doctorId, { $inc: { numberOfReviews: 1 } });

    await Review.calculateAverageRating(doctorId);

    res.status(201).json({ message: "Review added successfully.", review: newReview });
});
