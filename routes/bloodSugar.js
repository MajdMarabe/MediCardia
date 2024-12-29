const express = require("express");
const router = express.Router();
const { getGlucoseCardReadings,addReading } = require("../controllers/bloodSugarController");
const { verifyToken } = require("../middlewares/verifyToken");

// Define the route
router.post("/add",verifyToken, addReading);
router.get("/:id/glucoseCard", getGlucoseCardReadings);

module.exports = router;
