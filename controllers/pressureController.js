const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {Pressure}= require("../models/Pressure");
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const {verifyTokenAndAuthorization , verifyTokenAndAdmin,verifyToken}=require("../middlewares/verifyToken");

/**
 * @desc Add a new blood sugar reading
 * @route /api/pressure/add
 * @method POST
 * @access Private (Requires token)
 */
module.exports.addReading =  asyncHandler(async (req, res) => {
    const { Systolic, Diastolic,date } = req.body;

    const reading = {
        Systolic,
        Diastolic,
        date,
    };

    let pressure = await Pressure.findOne({ userId: req.user.id });
    if (!pressure) {
        pressure = new Pressure({ userId: req.user.id, readings: [reading] });
    } else {
        pressure.readings.push(reading);
    }

    await pressure.save();

    res.status(201).json({ message: "Reading added successfully!", data: reading });
});
/**
 * @desc Get blood pressure readings
 * @route /api/pressure/weeklyreadings
 * @method GET
 * @access Private (Requires token)
 */
module.exports.getWeeklyReadings = asyncHandler(async (req, res) => {
    const userId = req.user.id;

    const pressure = await Pressure.findOne({ userId });

    if (!pressure || !pressure.readings.length) {
        return res.status(404).json({ message: 'No readings found for this user.' });
    }

    const now = new Date();
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(now.getDate() - 7);

    const weeklyReadings = pressure.readings.filter((reading) => {
        const readingDate = new Date(reading.date);
        return readingDate >= oneWeekAgo && readingDate <= now;
    });

    res.status(200).json({
        message: 'Weekly readings retrieved successfully.',
        data: weeklyReadings,
    });
});
/**
 * @desc Fetch pressure data
 * @route /api/pressure/:id/data
 * @method GET
 * @access Private (Requires token)
 */

const moment = require('moment');

module.exports.fetchPressureData = asyncHandler(async (req, res) => {
    const { id } = req.params; // User ID

    const pressure = await Pressure.findOne({ userId: id });

    if (!pressure) {     
        return res.status(404).json({ message: 'No pressure data found for this user.' });
    }

    const readings = pressure.readings;

    const today = moment().startOf('day');
    const weekStart = moment().startOf('week');
    const monthStart = moment().startOf('month');

    const todayReadings = readings.filter(reading => moment(reading.date).isSame(today, 'day'));
    const weekReadings = readings.filter(reading => moment(reading.date).isSameOrAfter(weekStart, 'day') && moment(reading.date).isBefore(today, 'day'));
    const monthReadings = readings.filter(reading => moment(reading.date).isSameOrAfter(monthStart, 'day') && moment(reading.date).isBefore(today, 'day'));

    const calculateAverage = (readings) => {
        const totalSystolic = readings.reduce((sum, reading) => sum + reading.Systolic, 0);
        const totalDiastolic = readings.reduce((sum, reading) => sum + reading.Diastolic, 0);
        return {
            systolic: Math.round(totalSystolic / readings.length), 
            diastolic: Math.round(totalDiastolic / readings.length) 
        };
    };

    const formatReadings = (readings, rangeType) => {
        const formattedData = {
            systolicLevels: [],
            diastolicLevels: [],
            labels: [],
        };

        const groupedReadings = {};

        readings.forEach(reading => {
            const date = moment(reading.date);
            let label = '';

            switch (rangeType) {
                case 'today':
                    label = date.format('h:mm A');
                    formattedData.systolicLevels.push(reading.Systolic);
                    formattedData.diastolicLevels.push(reading.Diastolic);
                    formattedData.labels.push(label);
                    break;
                case 'week':
                    label = date.format('ddd'); 
                    const day = date.format('YYYY-MM-DD'); 
                    if (!groupedReadings[day]) {
                        groupedReadings[day] = [];
                    }
                    groupedReadings[day].push(reading);
                    break;
                case 'month':
                    label = `Week ${date.isoWeek()}`; 
                    const weekNumber = date.isoWeek();
                    if (!groupedReadings[weekNumber]) {
                        groupedReadings[weekNumber] = [];
                    }
                    groupedReadings[weekNumber].push(reading);
                    break;
            }
        });

        if (rangeType === 'week' || rangeType === 'month') {
            for (const key in groupedReadings) {
                const avg = calculateAverage(groupedReadings[key]);
                formattedData.systolicLevels.push(avg.systolic);
                formattedData.diastolicLevels.push(avg.diastolic);
                formattedData.labels.push(rangeType === 'week' ? moment(key).format('ddd') : `Week ${key}`);
            }
        }

        return formattedData;
    };

    const pressureDataFormatted = {
        today: formatReadings(todayReadings, 'today'),
        week: formatReadings(weekReadings, 'week'),
        month: formatReadings(monthReadings, 'month'),
    };

    res.status(200).json(pressureDataFormatted);
});
