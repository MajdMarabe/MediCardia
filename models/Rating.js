const mongoose = require('mongoose');
const {Doctor}= require("../models/Doctor");

const ReviewSchema = new mongoose.Schema({
    doctorId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor',
        required: true
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    rating: { 
        type: Number,
        required: true,
        min: 1, 
        max: 5  
    },
    review: { 
        type: String,
        trim: true,
        default: null 
    }
}, { timestamps: true }); 

// حساب متوسط التقييمات (Method أو Static)
ReviewSchema.statics.calculateAverageRating = async function (doctorId) {
    const result = await this.aggregate([
        { $match: { doctorId, isActive: true } },
        { $group: { _id: '$doctorId', averageRating: { $avg: '$rating' }, reviewCount: { $sum: 1 } } }
    ]);

    if (result.length > 0) {
        await mongoose.model('Doctor').findByIdAndUpdate(doctorId, {
            average_rating: result[0].averageRating,
            review_count: result[0].reviewCount
        });
    } else {
        await mongoose.model('Doctor').findByIdAndUpdate(doctorId, {
            average_rating: 0,
            review_count: 0
        });
    }
};

ReviewSchema.statics.calculateAverageRating = async function (doctorId) {
    const result = await this.aggregate([
        { $match: { doctorId: doctorId } }, // Match reviews for the specific doctor
        {
            $group: {
                _id: '$doctorId',
                averageRating: { $avg: '$rating' }, // Calculate average rating
            },
        },
    ]);

    if (result.length > 0) {
        // Update the doctor's average rating
        await Doctor.findByIdAndUpdate(doctorId, {
            averageRating: result[0].averageRating,
        });
    } else {
        // If no reviews, reset the average rating to 0
        await Doctor.findByIdAndUpdate(doctorId, {
            averageRating: 0,
        });
    }
};

const Review = mongoose.model('Review', ReviewSchema);

module.exports = Review;
