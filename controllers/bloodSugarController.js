const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {BloodSugar}= require("../models/BloodSugar");
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const {verifyTokenAndAuthorization , verifyTokenAndAdmin,verifyToken}=require("../middlewares/verifyToken");

/**
 * @desc Add a new blood sugar reading
 * @route /api/bloodSugar/add
 * @method POST
 * @access Private (Requires token)
 */
module.exports.addReading =  asyncHandler(async (req, res) => {
    const { glucoseLevel, measurementType,date } = req.body;

    let status = "normal";
    if (glucoseLevel < 70) status = "low";
    else if (glucoseLevel > 130) status = "high";

    const reading = {
        glucoseLevel,
        measurementType,
        status,
        date,
    };

    let bloodSugar = await BloodSugar.findOne({ userId: req.user.id });
    if (!bloodSugar) {
        bloodSugar = new BloodSugar({ userId: req.user.id, readings: [reading] });
    } else {
        bloodSugar.readings.push(reading);
    }

    await bloodSugar.save();

    res.status(201).json({ message: "Reading added successfully!", data: reading });
});
/**
 * @desc Get glucose readings for GlucoseCard
 * @route /api/bloodSugar/:id/glucoseCard
 * @method GET
 * @access public
 */
module.exports.getGlucoseCardReadings = asyncHandler(async (req, res) => {
        const { id } = req.params; // User ID

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const weekStart = new Date();
    weekStart.setDate(todayStart.getDate() - 7);

    const monthStart = new Date();
    monthStart.setDate(todayStart.getDate() - 30);

    const bloodSugarData = await BloodSugar.findOne({ userId: id });

    if (!bloodSugarData) {
        return res.status(200).json({
            today: { avgGlucose: "0", levels: [], labels: [], period: "Today" },
            week: { avgGlucose: "0", levels: [], labels: [], period: "Week" },
            month: { avgGlucose: "0", levels: [], labels: [], period: "Month" },
        });
    }

    const { readings } = bloodSugarData;

    const groupByDate = (filteredReadings) => {
        const grouped = {};
        filteredReadings.forEach(({ glucoseLevel, date }) => {
            const dateKey = date.toLocaleDateString("en-US", { weekday: "long" });
            if (!grouped[dateKey]) grouped[dateKey] = [];
            grouped[dateKey].push(glucoseLevel);
        });
        return Object.keys(grouped).map((dateKey) => ({
            label: dateKey,
            avgLevel: Math.round(
                grouped[dateKey].reduce((sum, level) => sum + level, 0) / grouped[dateKey].length
            ),
        }));
    };

    const groupByWeek = (filteredReadings) => {
        const grouped = {};
        filteredReadings.forEach(({ glucoseLevel, date }) => {
            const weekNumber = Math.ceil(date.getDate() / 7); // Calculate week number
            const weekKey = `Week ${weekNumber}`;
            if (!grouped[weekKey]) grouped[weekKey] = [];
            grouped[weekKey].push(glucoseLevel);
        });
        return Object.keys(grouped).map((weekKey) => ({
            label: weekKey,
            avgLevel: Math.round(
                grouped[weekKey].reduce((sum, level) => sum + level, 0) / grouped[weekKey].length
            ),
        }));
    };

    const filterByDateRange = (startDate) => {
        return readings
            .filter((reading) => new Date(reading.date) >= startDate)
            .map((reading) => ({
                glucoseLevel: reading.glucoseLevel,
                date: new Date(reading.date),
            }));
    };

    const todayReadings = filterByDateRange(todayStart);
    const weekReadings = filterByDateRange(weekStart);
    const monthReadings = filterByDateRange(monthStart);

    const formatToday = (filteredReadings) => {
        const levels = filteredReadings.map((r) => r.glucoseLevel);
        const labels = filteredReadings.map((r) =>
            r.date.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit" })
        );

        const avgGlucose = levels.length
            ? Math.round(levels.reduce((sum, level) => sum + level, 0) / levels.length).toString()
            : "0";

        return { avgGlucose, levels, labels, period: "Today" };
    };

    const formatWeek = (filteredReadings) => {
        const grouped = groupByDate(filteredReadings);
        return {
            avgGlucose: grouped.length
                ? Math.round(
                      grouped.reduce((sum, { avgLevel }) => sum + avgLevel, 0) / grouped.length
                  ).toString()
                : "0",
            levels: grouped.map((g) => g.avgLevel),
            labels: grouped.map((g) => g.label),
            period: "Week",
        };
    };

    const formatMonth = (filteredReadings) => {
        const grouped = groupByWeek(filteredReadings);
        return {
            avgGlucose: grouped.length
                ? Math.round(
                      grouped.reduce((sum, { avgLevel }) => sum + avgLevel, 0) / grouped.length
                  ).toString()
                : "0",
            levels: grouped.map((g) => g.avgLevel),
            labels: grouped.map((g) => g.label),
            period: "Month",
        };
    };

    res.status(200).json({
        today: formatToday(todayReadings),
        week: formatWeek(weekReadings),
        month: formatMonth(monthReadings),
    });
});
