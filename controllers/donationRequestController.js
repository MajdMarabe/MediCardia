const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {DonationRequest,validateDonationRequest} = require('../models/DonationRequest');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const axios = require('axios');
/** 
 * @desc Add new donation request
 * @route /api/donationrequests/add
 * @method POST
 * @access private
 */


module.exports.addDonationRequest = asyncHandler(async (req, res) => {
    const { error } = validateDonationRequest(req.body); 
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }
    const { bloodType, units, hospital, createdByDoctor, requiredDate, assignedToUser } = req.body;

    // Validate required fields
    if (!bloodType ||!units|| !hospital || !createdByDoctor || !requiredDate || !assignedToUser) {
        return res.status(400).json({ message: "Please provide all required fields" });
    }

    const donationRequest = new DonationRequest({
        bloodType,
        units,
        hospital,
        createdByDoctor,
        requiredDate,
        assignedToUser,
    });

    try {
        // Save the new donation request
        const result = await donationRequest.save();
        res.status(201).json({
            message: "Donation request added successfully",
            donationRequest: result
        });
    } catch (err) {
        console.error(err); // Log the error message
        res.status(500).json({ message: "Error adding the donation request" });
    }
});
/** 
 * @desc Get all donation requests assigned to a user
 * @route /api/donationrequests/user/:userId
 * @method GET
 * @access private
 */
module.exports.getDonationRequestsForUser = asyncHandler(async (req, res) => {
    const { id } = req.params;

    // دالة لحذف الطلبات القديمة التي مر عليها أكثر من يومين
    const deleteOldRequests = async () => {
        try {
            const twoDaysAgo = new Date();
            twoDaysAgo.setDate(twoDaysAgo.getDate() - 2); // تحديد تاريخ قبل يومين
            twoDaysAgo.setHours(0, 0, 0, 0); // تأكد من مقارنة اليوم بالكامل بدون ساعات

            console.log("Deleting requests older than:", twoDaysAgo);

            // حذف الطلبات التي تم إنشاؤها قبل يومين
            const result = await DonationRequest.deleteMany({ createdAt: { $lt: twoDaysAgo } });

            console.log(`${result.deletedCount} old requests deleted.`);
        } catch (err) {
            console.error('Error deleting old requests:', err);
        }
    };

    try {
        // حذف الطلبات القديمة قبل استرجاع الطلبات الحالية
        await deleteOldRequests();

        // Find all donation requests assigned to the user
        const donationRequests = await DonationRequest.find({ assignedToUser: id })
            .populate('hospital', 'name city nameArabic phone latitude longitude') // Populate hospital data
            .populate('createdByDoctor', 'name') // Populate doctor data
            .sort({ createdAt: -1 }); // Sort by creation date (newest first)

        console.log(donationRequests);

        if (!donationRequests || donationRequests.length === 0) {
            return res.status(404).json({ message: "No donation requests found for this user." });
        }

        res.status(200).json({
            message: "Donation requests fetched successfully",
            donationRequests
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Error fetching donation requests" });
    }
});
