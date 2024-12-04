const express = require("express");
const router = express.Router();
const { getAllNotifications,addNotification,deleteNotification } = require("../controllers/notificationController");
const { verifyToken ,verifyTokenAndAdmin} = require("../middlewares/verifyToken");

// Define the route
router.post("/addnotifications",verifyToken, addNotification);
router.get("/allnotifications",verifyToken, getAllNotifications);
router.delete("/:id",verifyToken, deleteNotification);

module.exports = router;
