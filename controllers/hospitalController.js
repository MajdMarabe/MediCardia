const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const Hospital = require('../models/Hospital');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const axios = require('axios');


/** 
 * @desc Add new hospital
 * @route /api/hospitals/add
 * @method POST
 * @access public
 */

module.exports.addHospital = asyncHandler(async (req, res) => {
    const { name, nameArabic, city, latitude, longitude, phone } = req.body;

    if (!name || !nameArabic || !city  || !latitude || !longitude) {
        return res.status(400).json({ message: "Please provide all required fields" });
    }

    let existingHospital = await Hospital.findOne({ name, city });
    if (existingHospital) {
        return res.status(400).json({ message: "Hospital with this name already exists in the same city" });
    }

    const hospital = new Hospital({
        name,
        nameArabic,
        city,
        latitude,
        longitude,
        phone,
    });

    try {
        const result = await hospital.save();
        res.status(201).json({ message: "Hospital added successfully", hospital: result });
    } catch (err) {
        console.error(err); 
        res.status(500).json({ message: "Error adding the hospital" });
    }
});
/** 
 * @desc Get hospitals by name (for auto-complete)
 * @route /api/hospitals/search
 * @method GET
 * @access public
 */

module.exports.getHospitalsByName = asyncHandler(async (req, res) => {
    const { name } = req.query;

    if (!name) {
        return res.status(400).json({ message: "Please provide a hospital name to search for" });
    }

    try {
        const hospitals = await Hospital.find({ name: { $regex: name, $options: 'i' } });

        if (hospitals.length === 0) {
            return res.status(404).json({ message: "No hospitals found matching the name" });
        }

        res.status(200).json({ hospitals });
    } catch (err) {
        console.error(err); 
        res.status(500).json({ message: "Error fetching hospitals" });
    }
});
