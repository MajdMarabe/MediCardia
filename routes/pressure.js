const express = require("express");
const router = express.Router();
const { addReading,getWeeklyReadings,fetchPressureData} = require("../controllers/pressureController");
const { verifyToken } = require("../middlewares/verifyToken");

router.post("/add",verifyToken, addReading);
//router.get("/glucoseCard",verifyToken, getGlucoseCardReadings);
router.get("/weeklyreadings",verifyToken, getWeeklyReadings);
router.get("/:id/data", fetchPressureData);

module.exports = router;
