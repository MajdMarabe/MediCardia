const jwt = require("jsonwebtoken");
const asyncHandler = require("express-async-handler");
const bcrypt = require('bcryptjs');
const { Doctor, validateCreateDoctor } = require('../models/Doctor');
const sendEmail = require("../middlewares/email");

/**
 * @desc Sign up a new doctor
 * @route /api/doctors/register
 * @method POST
 * @access public
 */
module.exports.register = asyncHandler(async (req, res, next) => {
    // Validate input data
    const { error } = validateCreateDoctor(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    // Check if doctor already exists by email
    let doctor = await Doctor.findOne({ email: req.body.email });
    if (doctor) {
        return res.status(400).json({ message: "This email is already registered" });
    }

    // Check if doctor already exists by license number
    doctor = await Doctor.findOne({ licenseNumber: req.body.licenseNumber });
    if (doctor) {
        return res.status(400).json({ message: "This license number is already registered" });
    }

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(req.body.password_hash, salt);

    // Create new doctor object
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

        const verifyResponse = await module.exports.verifyEmail({ body: { email: doctor.email } }, res, next);
        if (!verifyResponse) {
            return; // Prevent further execution if verification fails
        }

        const token = doctor.generateToken();

        const { password_hash, ...other } = result._doc;

        res.status(201).json({
            ...other,
            token,
            message: "Doctor registered successfully. Please verify your email."
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "There was an error registering the doctor" });
    }
});

/**
 * @desc Verify Email for Doctor
 * @route /api/doctors/verifyemail
 * @method POST
 * @access public
 */
module.exports.verifyEmail = asyncHandler(async (req, res, next) => {
    const { email } = req.body;

    const doctor = await Doctor.findOne({ email });
    if (!doctor) {
        return next(new CustomError('Email not found', 404));
    }

    const verificationCode = Math.floor(1000 + Math.random() * 9000).toString();

    doctor.verificationCode = verificationCode;
    doctor.verificationCodeExpires = Date.now() + 10 * 60 * 1000; // 10 minutes expiration
    await doctor.save({ validateBeforeSave: false });

    const message = `Your email verification code is: ${verificationCode}. It will expire in 10 minutes.`;

    try {
        await sendEmail({
            email: doctor.email,
            subject: 'Email Verification Code',
            message,
        });

        res.status(200).json({
            status: 'success',
            message: 'Verification code sent to your email',
        });
    } catch (err) {
        doctor.verificationCode = undefined;
        doctor.verificationCodeExpires = undefined;
        await doctor.save({ validateBeforeSave: false });

        return next(new CustomError('Error sending verification code. Please try again.', 500));
    }
});

/**
 * @desc Get all doctors and their info
 * @route /api/doctors
 * @method GET
 * @access public
 */
module.exports.getAllDoctors = asyncHandler(async (req, res, next) => {
    try {
        const doctors = await Doctor.find().select('-password_hash'); 

        if (!doctors || doctors.length === 0) {
            return res.status(404).json({ message: "No doctors found." });
        }

        res.status(200).json(doctors);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "There was an error retrieving the doctors." });
    }
});







/**
 * @desc get doctor by id
 * @route /api/doctors/:id
 * @method get
 * @access public 
*/
module.exports.getDoctorById=asyncHandler(async(req,res)=>{ 

    const user = await Doctor.findById(req.params.id).populate(); 
    if (user) {
        res.status(200).json(user); 
    }
    else{
        res.status(404).json({ message:"doctor not found"});
    }
});
/**
* @desc get settings by id
* @route /api/doctors/:id/settings
* @method get
* @access public 
*/
module.exports.getSettings=asyncHandler(async(req,res)=>{ 

const user = await Doctor.findById(req.params.id).populate(); 

if (user) {
    const Settings = user.notificationSettings;

    res.status(200).json(Settings); 
}
else{
    res.status(404).json({ message:"doctor not found"});
}
});
/**
* @desc    Update settings by user ID
* @route   /api/doctors/:id/setsetting
* @method  PUT
* @access  public
*/
module.exports.updateSettings = asyncHandler(async (req, res) => {
const userId = req.params.id;

const { reminderNotifications, messageNotifications, requestNotifications } = req.body;

const user = await Doctor.findById(userId);

if (user) {
  user.notificationSettings = {
   // reminders: reminderNotifications !== undefined ? reminderNotifications : user.notificationSettings.reminderNotifications,
    messages: messageNotifications !== undefined ? messageNotifications : user.notificationSettings.messageNotifications,
    requests: requestNotifications !== undefined ? requestNotifications : user.notificationSettings.requestNotifications,
  };

  await user.save();

  res.status(200).json({
    message: "Notification settings updated successfully",
    notificationSettings: user.notificationSettings,
  });
} else {
  res.status(404).json({ message: "Doctor not found" });
}
});

