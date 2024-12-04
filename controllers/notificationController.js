const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {Notification}= require("../models/Notification");
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const {verifyTokenAndAuthorization , verifyTokenAndAdmin,verifyToken}=require("../middlewares/verifyToken");

/**
 * @desc Get all notifications for a user
 * @route /api/allnotifications
 * @method GET
 * @access Private
 */
module.exports.getAllNotifications =  asyncHandler(async (req, res) => {
    const userId = req.user.id; // Extract user ID from token
    const notifications = await Notification.find({ userId }).sort({ timestamp: -1 });
    res.status(200).json(notifications);
});
/**
 * @desc Add a notification for a user (triggered automatically)
 * @route /api/notifications
 * @method POST
 * @access Private
 */
module.exports.addNotification =  asyncHandler(async (req, res) => {
    const { userId, title, body } = req.body;

    if (!userId || !title || !body) {
        res.status(400);
        throw new Error("Please provide userId, title, and body.");
    }

    const notification = new Notification({ userId, title, body });
    await notification.save();

    res.status(201).json(notification);
});

/**
 * @desc Delete a notification
 * @route /api/notifications/:id
 * @method DELETE
 * @access Private
 */
module.exports.deleteNotification =  asyncHandler(async (req, res) => {
    const notificationId = req.params.id;

    const notification = await Notification.findById(notificationId);

    if (!notification) {
        res.status(404);
        throw new Error("Notification not found.");
    }

    // Ensure the user is authorized to delete the notification
    if (notification.userId.toString() !== req.user.id && !req.user.isAdmin) {
        res.status(403);
        throw new Error("Not authorized to delete this notification.");
    }

    await notification.remove();
    res.status(200).json({ message: "Notification deleted successfully." });
});
