const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const axios = require('axios');
const { Doctor, validateCreateDoctor } = require('../models/Doctor'); 

/**
 * @desc Sign up a new doctor
 * @route /api/doctors/register
 * @method POST
 * @access public
 */
module.exports.register = asyncHandler(async (req, res) => {
    const { error } = validateCreateDoctor(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    let doctor = await Doctor.findOne({ email: req.body.email });
    if (doctor) {
        return res.status(400).json({ message: "This email is already registered" });
    }

    doctor = await Doctor.findOne({ licenseNumber: req.body.licenseNumber });
    if (doctor) {
        return res.status(400).json({ message: "This license number is already registered" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(req.body.password_hash, salt);

    doctor = new Doctor({
        fullName: req.body.fullName,
        email: req.body.email,
        password_hash: hashedPassword,
        phone: req.body.phone,
        specialization: req.body.specialization,
        licenseNumber: req.body.licenseNumber,
        workplace: {
            name: req.body.workplaceName,
            address: req.body.workplaceAddress || '',
        },
    });

    try {
        const result = await doctor.save();

        const token = doctor.generateToken();

        const { password_hash, ...other } = result._doc;

        res.status(201).json({
            ...other,
            token
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "There was an error registering the doctor" });
    }
});
