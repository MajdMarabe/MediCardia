const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {Doctor}= require("../models/Doctor");
const { Drug } = require("../models/Drug");
const {DonationRequest,validateDonationRequest} = require('../models/DonationRequest');
const {BloodSugar}= require("../models/BloodSugar");
const Appointment = require('../models/Appointment');
const {Pressure}= require("../models/Pressure");

const {validateCreatUser,validateLoginUser,validateUpdateUser,validatePublicData,validateHistory,validatelabTests,User}= require("../models/User");
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const sendEmail = require("../middlewares/email");
const {verifyTokenAndAuthorization , verifyTokenAndAdmin}=require("../middlewares/verifyToken");
class CustomError extends Error {
    constructor(message, statusCode) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = true;
        Error.captureStackTrace(this, this.constructor);
    }
}
/**
 * @desc Add new user (Sign Up)
 * @route /api/users/register
 * @method POST
 * @access public 
 */
module.exports.register = asyncHandler(async (req, res, next) => {
    const { error } = validateCreatUser(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    let user = await User.findOne({ email: req.body.email });
    if (user) {
        return res.status(400).json({ message: "This email is already registered" });
    }

    const salt = await bcrypt.genSalt(10);
    req.body.password_hash = await bcrypt.hash(req.body.password_hash, salt);

    user = new User({
        username: req.body.username,
        email: req.body.email,
        location: req.body.location,
        password_hash: req.body.password_hash,
    });

    await user.save();

    const verifyResponse = await module.exports.verifyEmail({ body: { email: user.email } }, res, next);
    if (!verifyResponse) {
        return; 
    }

    const token = user.generateToken();

    res.status(201).json({
        token,
        _id: user._id, 
    });
});
/**
 * @desc Get user's profile before update
 * @route /api/users/profile/:userid
 * @method GET
 * @access private (requires authentication)
 */
module.exports.getProfile = asyncHandler(async (req, res, next) => {
    const user = await User.findById(req.params.userid);
    if (!user) {
        return res.status(404).json({ message: "user not found" });
    }

    const { password_hash, ...userData } = user._doc;

    res.status(200).json({
        message: "user profile fetched successfully",
        user: userData,
    });
});
/**
 * @desc Update user profile
 * @route PUT /api/users/update/:userid
 * @method PUT
 * @access Private (requires authentication)
 */
module.exports.updateProfile = asyncHandler(async (req, res) => {
    const { username, email, phoneNumber, location,image } = req.body;
///console.log(image);
    const user = await User.findById(req.params.userid);

    if (!user) {
        return res.status(404).json({ message: "User not found" });
    }

    if (email && email !== user.email) {
        const emailExists = await User.findOne({ email });
        if (emailExists) {
            return res.status(400).json({ message: "This email is already registered" });
        }
    }

    if (phoneNumber && phoneNumber !== user.medicalCard?.publicData?.phoneNumber) {
        const phoneNumberExists = await User.findOne({
            "medicalCard.publicData.phoneNumber": phoneNumber,
        });
        if (phoneNumberExists) {
            return res.status(400).json({ message: "This phone number is already registered" });
        }
    }

    if (username) user.username = username;
    if (email) user.email = email;
    if (phoneNumber) user.medicalCard.publicData.phoneNumber = phoneNumber;
    if (location) user.location = location;
    
     if (image)  user.medicalCard.publicData.image = image;

    try {
        await user.save();

        res.status(200).json({
            message: "User profile updated successfully",
            user: {
                username: user.username,
                email: user.email,
                phoneNumber: user.medicalCard.publicData.phoneNumber,
                location: user.location,
                image: user.medicalCard.publicData.image,

            },
        });
    } catch (error) {
        console.error("Error updating profile:", error);
        res.status(500).json({ message: "There was an error updating the profile." });
    }
});


/**
 * @desc Change user's password
 * @route PUT /api/users/change-password
 * @method PUT
 * @access Private (requires authentication)
 */
module.exports.changePassword = asyncHandler(async (req, res) => {
    const { oldPassword, newPassword, confirmPassword } = req.body;
console.log(oldPassword);
    if (!oldPassword || !newPassword || !confirmPassword) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    if (newPassword !== confirmPassword) {
        return res.status(400).json({ message: 'New passwords do not match' });
    }

    const userid = req.user.id; 
    const user = await User.findById(userid);

    if (!user) {
        return res.status(404).json({ message: 'user not found' });
    }

    const isPasswordMatch = await bcrypt.compare(oldPassword, user.password_hash);
    if (!isPasswordMatch) {
        return res.status(400).json({ message: 'Old password is incorrect' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    user.password_hash = hashedPassword;
    await user.save();

    res.status(200).json({ message: 'Password changed successfully' });
});

/**
 * @desc Verify Email
 * @route /api/users/verifyemail
 * @method POST
 * @access public
 */
module.exports.verifyEmail = asyncHandler(async (req, res, next) => {
    const { email } = req.body;

    // Find user or doctor by email
    const user = await User.findOne({ email }) || await Doctor.findOne({ email });
    if (!user) {
        return next(new CustomError('Email not found', 404));
    }

    const verificationCode = Math.floor(1000 + Math.random() * 9000).toString();

    // Save the verification code and expiration in the user/doctor document
    user.verificationCode = verificationCode;
    user.verificationCodeExpires = Date.now() + 10 * 60 * 1000; // 10 minutes expiration
    await user.save({ validateBeforeSave: false });

    // Send verification code to email
    const message = `Your email verification code is: ${verificationCode}. It will expire in 10 minutes.`;

    try {
        await sendEmail({
            email: user.email,
            subject: 'Email Verification Code',
            message,
        });

        res.status(200).json({
            status: 'success',
            message: 'Verification code sent to your email',
            _id: user._id
        });
    } catch (err) {
        user.verificationCode = undefined;
        user.verificationCodeExpires = undefined;
        await user.save({ validateBeforeSave: false });

        return next(new CustomError('Error sending verification code. Please try again.', 500));
    }
});


/**
 * @desc  login
 * @route /api/users/login
 * @method Post
 * @access public
 */
module.exports.login = asyncHandler(async (req, res) => {
    console.log(req.body);

    const { error } = validateLoginUser(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    let user = await User.findOne({ email: req.body.email });
    if (!user) {
        user = await Doctor.findOne({ email: req.body.email });
        if (!user) {
            return res.status(400).json({ message: "Invalid email" });
        }
    }

    const passwordMatch = await bcrypt.compare(req.body.password_hash, user.password_hash);
    if (!passwordMatch) {
        return res.status(400).json({ message: "Invalid password" });
    }

    const token = user.generateToken();

    const { password_hash, ...other } = user._doc;

    res.status(200).json({ ...other, token });
});


 /**
 * @desc  login
 * @route /api/users/login
 * @method Post
 * @access public
 */
/*
module.exports.login= asyncHandler(async(req,res) =>{

    
    console.log(req.body);
        const {error} = validateLoginUser(req.body);
    if(error){
     return res.status(400).json({message: error.details[0].message}); 
                                                                
           }
    
           let user = await  User.findOne({email: req.body.email}); 
           if(!user){
    
             return res.status(400).json({message:"invalid email"});
           } 
    
    let passwordMatch= await bcrypt.compare(req.body.password_hash,user.password_hash);
    console.log(req.body.password_hash , user.password_hash,passwordMatch);
    if(!passwordMatch){
        return res.status(400).json({message:"invalid password"});
    } 
    
    const token =user.generateToken();
    //const token =null;
    const {password_hash, ...other}=user._doc;
    res.status(200).json({...other, token }); 
    
     
    });*/
    ////
    /**
 * @desc Get all users and doctors
 * @route /api/users
 * @method GET
 * @access public
 */
module.exports.getAllUsers = asyncHandler(async (req, res) => {
    try {
        // Fetch users and doctors
        const users = await User.find().select("-password_hash");
        const doctors = await Doctor.find({ role: { $ne: "admin" } }).select("-password_hash");

        // Combine the results in a single response object
        res.status(200).json({
            success: true,
            data: {
                users,
                doctors
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            success: false,
            message: "Failed to fetch users and doctors"
        });
    }
});

/**
 * @desc get users by id
 * @route /api/users/:id
 * @method get
 * @access public 
*/
    module.exports.getUserById=asyncHandler(async(req,res)=>{ 

        const user = await User.findById(req.params.id).populate(); 
        if (user) {
            res.status(200).json(user); 
        }
        else{
            res.status(404).json({ message:"user not found"});
        }
    });
    /**
 * @desc get settings by id
 * @route /api/users/:id/settings
 * @method get
 * @access public 
*/
module.exports.getSettings=asyncHandler(async(req,res)=>{ 

    const user = await User.findById(req.params.id).populate(); 

    if (user) {
        const Settings = user.notificationSettings;

        res.status(200).json(Settings); 
    }
    else{
        res.status(404).json({ message:"user not found"});
    }
});
/**
 * @desc    Update settings by user ID
 * @route   /api/users/:id/setsetting
 * @method  PUT
 * @access  public
 */
module.exports.updateSettings = asyncHandler(async (req, res) => {
    // Extract the user ID from the request parameters
    const userId = req.params.id;
  
    // Extract the settings from the request body
    const { reminderNotifications, messageNotifications, requestNotifications,donationNotifications } = req.body;
  
    // Find the user by their ID
    const user = await User.findById(userId);
   
    if (user) {
      // Update the user's notification settings
      user.notificationSettings = {
        reminders: reminderNotifications !== undefined ? reminderNotifications : user.notificationSettings.reminderNotifications,
        messages: messageNotifications !== undefined ? messageNotifications : user.notificationSettings.messageNotifications,
        requests: requestNotifications !== undefined ? requestNotifications : user.notificationSettings.requestNotifications,
        donation: donationNotifications !== undefined ? donationNotifications : user.notificationSettings.donationNotifications,
    };
  
      // Save the updated user object
      await user.save();
  
      // Return the updated settings
      res.status(200).json({
        message: "Notification settings updated successfully",
        notificationSettings: user.notificationSettings,
      });
    } else {
      res.status(404).json({ message: "User not found" });
    }
  });
  
/**
 * @desc update a user 
 * @route /api/user/:id
 * @method PUT
 * @access private
 * */
 
    module.exports.updateUserById=verifyTokenAndAuthorization ,asyncHandler(async(req,res)=>{ 

    
        const {error}= validateUpdateUser(req.body);
    
        if(error){
            return res.status(400).json({ message: error.details[0].message}); 
        }
        if(req.body.password_hash){
            const salt = await bcrypt.genSalt(10);
            req.body.password_hash = await bcrypt.hash(req.body.password_hash, salt);
      
        }
    
        const updateduser = await User.findByIdAndUpdate(req.params.id ,{
            $set: {
                
                username:  req.body.username,
                email: req.body.email,
                location : req.body.location,
                password_hash: req.body.password_hash
    
            }
        } , {new: true }).select("-password_hash"); 
     
        res.status(200).json(updateduser);
    });
/**
 * @desc Delete a user
 * @route /api/user/:id
 * @method DELETE
 * @access public
 */

    module.exports.deleteUserById=verifyTokenAndAuthorization,verifyTokenAndAdmin,asyncHandler(async(req,res)=>{ 
   
   
        const user= await User.findByIdAndDelete(req.params.id) ;
        
        if(user){
        res.status(200).json({ message:"user has been deleted"});
    }
    else{
        res.status(404).json({ message:"user not found"});
    }
    });
/**
 * @desc forget password
 * @route /api/user/forgetPassword
 * @method POST
 * @access public
 */
module.exports.forgetPassword = asyncHandler(async (req, res, next) => {
    // 1. Get user or doctor based on email
    let user = await User.findOne({ email: req.body.email });
    if (!user) {
        user = await Doctor.findOne({ email: req.body.email });
        if (!user) {
            return next(new CustomError('Invalid email', 404));
        }
    }

    // 2. Generate a random 4-digit verification code
    const verificationCode = Math.floor(1000 + Math.random() * 9000).toString(); // 4-digit code

    // Save the verification code and expiration in the user document
    user.verificationCode = verificationCode;
    user.verificationCodeExpires = Date.now() + 10 * 60 * 1000; // Code valid for 10 minutes

    await user.save({ validateBeforeSave: false });

    // 3. Send the verification code to the user's email
    const message = `Your password reset verification code is: ${verificationCode}. This code will expire in 10 minutes.`;

    try {
        await sendEmail({
            email: user.email,
            subject: 'Password Reset Verification Code',
            message: message,
        });

        res.status(200).json({
            status: 'success',
            message: "Verification code sent to the user's email",
        });
    } catch (err) {
        // If there is an error, clear the verification code fields and save the user again
        user.verificationCode = undefined;
        user.verificationCodeExpires = undefined;
        await user.save({ validateBeforeSave: false });

        return next(new CustomError('There was an error sending the verification code. Please try again later.', 500));
    }
});

   /**
 * @desc Verify the reset password code
 * @route /api/user/verifyCode
 * @method POST
 * @access public
 */
module.exports.verifyCode = asyncHandler(async (req, res, next) => {
    const { verificationCode } = req.body;

    // 1. Find the user or doctor by the verification code and check expiration
    let userOrDoctor = await User.findOne({
        verificationCode: verificationCode,
        verificationCodeExpires: { $gt: Date.now() } // Check if verification code has expired
    });

    // If user not found, check in the doctor collection
    if (!userOrDoctor) {
        userOrDoctor = await Doctor.findOne({
            verificationCode: verificationCode,
            verificationCodeExpires: { $gt: Date.now() } // Check if verification code has expired
        });

        if (!userOrDoctor) {
            // If no user or doctor found with the code or the code expired
            return next(new CustomError('Invalid or expired verification code', 400));
        }
    }

    // 2. Generate a temporary token for password reset (valid for 10 minutes)
    const tempToken = jwt.sign(
        { id: userOrDoctor._id, role: userOrDoctor.constructor.modelName }, // Add model name (User or Doctor) as role
        process.env.JWT_SECRET_KEY, // Use your secret key
        { expiresIn: '10m' } // Token expires in 10 minutes
    );

    // 3. Send the temporary token to the client for password reset
    res.status(200).json({
        status: 'success',
        message: 'Verification code is valid. Use the provided token to reset your password.',
        token: tempToken // Client will use this token to reset the password
    });
});



    /**
 * @desc Reset Password
 * @route /api/user/resetPassword
 * @method POST
 * @access public
 */
module.exports.resetPassword = asyncHandler(async (req, res, next) => {
    const { token, newPassword, confirmPassword } = req.body;

    // 1. Verify the token to extract the user ID
    let decoded;
    try {
        decoded = jwt.verify(token, process.env.JWT_SECRET_KEY); // Verify the token
    } catch (err) {
        return next(new CustomError('Invalid or expired token', 400));
    }

    // 2. Find the user by ID in both collections
    let user = await User.findById(decoded.id);
    if (!user) {
        user = await Doctor.findById(decoded.id);
        if (!user) {
            return next(new CustomError('User not found', 404));
        }
    }

    // 3. Check if the new password and confirm password match
    if (newPassword !== confirmPassword) {
        return res.status(400).json({ message: "Passwords do not match" });
    }

    // 4. Hash the new password and update the user
    const salt = await bcrypt.genSalt(10);
    user.password_hash = await bcrypt.hash(newPassword, salt);

    // Clear the verification code and expiration
    user.verificationCode = undefined;
    user.verificationCodeExpires = undefined;

    // Update the passwordChangedAt field
    user.passwordChangedAt = Date.now();

    await user.save();

    res.status(200).json({ message: 'Password has been reset successfully' });
});

/**
 * @desc Update Public Medical Card Data
 * @route /api/users/:id/public-medical-card
 * @method PUT
 * @access Public
 */
module.exports.updatePublicMedicalCardData = asyncHandler(async (req, res) => {
    const { publicData } = req.body; // البيانات العامة المرسلة من المستخدم

    // التحقق من صحة البيانات العامة
    const { error } = validatePublicData(publicData);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    // البحث عن المستخدم الذي سيتم تحديث بياناته
    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({ message: "User not found" });
    }

    // فصل حقل BloodDonationDate عن بقية البيانات العامة
    const { BloodDonationDate, Drugs, ...updatedPublicData } = publicData;

    // تحديث البيانات العامة للمستخدم
    user.medicalCard.publicData = {
        ...user.medicalCard.publicData,
        ...updatedPublicData, // دمج البيانات المحدثة العامة (بدون BloodDonationDate و Drugs)
    };

    // تحديث أو إضافة تواريخ التبرع بالدم إذا تم إرسالها
    if (BloodDonationDate && Array.isArray(BloodDonationDate)) {
        BloodDonationDate.forEach(donation => {
            if (donation.lastBloodDonationDate) {
                user.medicalCard.publicData.BloodDonationDate.push(donation);
            }
        });
    }

    // حفظ مستند المستخدم المحدث
    await user.save();

    res.status(200).json({ message: "Public medical card data updated successfully", user });
});
/**
 * @desc Get All Blood Donation Dates for a User
 * @route /api/users/:id/blood-donations
 * @method GET
 * @access Public
 */
module.exports.getBloodDonationDates = asyncHandler(async (req, res) => {
    console.log('innnnnnn');

    // البحث عن المستخدم باستخدام معرّف المستخدم
    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({ message: "User not found" });
    }

    // إرجاع جميع تواريخ التبرع بالدم
    const donationDates = user.medicalCard.publicData.BloodDonationDate;

    res.status(200).json({ donationDates });
});
/**
 * @desc Add a New Blood Donation Date for a User
 * @route /api/users/:id/blood-donations
 * @method POST
 * @access Public
 */
module.exports.addBloodDonationDate = asyncHandler(async (req, res) => {
    const { lastBloodDonationDate } = req.body; // تاريخ التبرع بالدم المرسل من المستخدم
    console.log(lastBloodDonationDate);

    if (!lastBloodDonationDate) {
        return res.status(400).json({ message: "lastBloodDonationDate is required" });
    }

    // البحث عن المستخدم الذي سيتم إضافة تاريخ التبرع له
    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({ message: "User not found" });
    }

    // تحويل التاريخ المرسل إلى كائن Date
    const newDonationDate = new Date(lastBloodDonationDate);

    // إضافة التاريخ الجديد إلى قائمة التواريخ
    user.medicalCard.publicData.BloodDonationDate.push({
        lastBloodDonationDate: newDonationDate,
    });

    // مقارنة التاريخ الجديد مع الحقل DonationDateForCheck وتحديثه إذا كان أحدث
    if (
        !user.medicalCard.publicData.DonationDateForCheck || // إذا كان الحقل فارغًا
        newDonationDate > new Date(user.medicalCard.publicData.DonationDateForCheck) // إذا كان التاريخ الجديد أحدث
    ) {
        user.medicalCard.publicData.DonationDateForCheck = newDonationDate;
    }

    // حفظ المستخدم
    await user.save();

    res.status(200).json({
        message: "Blood donation date added successfully",
        user,
    });
});


/**
 * @desc Update Medical History
 * @route /:id/medicalhistory
 * @method PUT
 * @access public
 */
module.exports.UpdatemedicalHistory = asyncHandler(async (req, res) => {
    const { userid, index, updatedItem } = req.body;

    console.log(userid, index, updatedItem);
  
    if (!userid || index === undefined || !updatedItem) {
      return res.status(400).json({ message: 'Missing required fields.' });
    }
  
    const user = await User.findById(userid);
  
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }
  
    if (!user.medicalCard?.privateData?.medicalHistory || index < 0 || index >= user.medicalCard.privateData.medicalHistory.length) {
      return res.status(400).json({ message: 'Invalid index or medical history.' });
    }
  
    user.medicalCard.privateData.medicalHistory[index] = updatedItem;
  
    await user.save();
  
    res.status(200).json({
      message: 'Medical history updated successfully.',
      medicalHistory: user.medicalCard.privateData.medicalHistory,
    });
});


/**
 * @desc Update lab Tests
 * @route /:id/labtests
 * @method PUT
 * @access public
 */
module.exports.UpdalabTests = asyncHandler(async (req, res) => {
    const { labTests } = req.body;
console.log(labTests);
    if (!Array.isArray(labTests)) {
        return res.status(400).json({ message: "labTests must be an array" });
    }

    const invalidEntry = labTests.find(entry => 
        !entry.testName || !entry.testResult || !entry.testDate
    );

    if (invalidEntry) {
        return res.status(400).json({ message: "Each lab Test entry must contain testName, testDate, and testResult." });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    user.medicalCard.privateData.labTests.push(...labTests);

    await user.save();

    res.status(200).json({ message: 'lab Tests updated successfully', user });
});

/**
 * @desc Update medicalNotes
 * @route /:id/medicalNotes
 * @method PUT
 * @access public
 */
module.exports.UpdamedicalNotes = asyncHandler(async (req, res) => {
    const { userid, noteId, updatedNote } = req.body; 
    // Validate input
    if (!noteId || typeof noteId !== 'string') {
        return res.status(400).json({ message: 'Note ID is required and should be a string.' });
    }
    if (!updatedNote || typeof updatedNote !== 'string') {
        return res.status(400).json({ message: 'Updated note content is required and should be a string.' });
    }

    const user = await User.findById(userid);
    if (!user) {
        return res.status(404).json({ message: 'User not found.' });
    }

    const noteIndex = user.medicalCard.privateData.medicalNotes.findIndex(note => note._id.toString() === noteId);
    if (noteIndex === -1) {
        return res.status(404).json({ message: 'Note not found.' });
    }

    user.medicalCard.privateData.medicalNotes[noteIndex].note = updatedNote;

    await user.save();

    res.status(200).json({ 
        message: 'Medical note updated successfully.', 
        updatedNote: user.medicalCard.privateData.medicalNotes[noteIndex] 
    });
});
/**
 * @desc Update treatmentPlans
 * @route /:id/treatmentPlans
 * @method PUT
 * @access public
 */
module.exports.UpdatreatmentPlans = asyncHandler(async (req, res) => {
    const { userid, planId } = req.params; // Extract user ID and plan ID from the route params
    const { updatedPlan } = req.body; // Extract the updated plan from the request body
    console.log(userid, planId ,updatedPlan)

    // Validate input
    if (!updatedPlan || typeof updatedPlan !== 'object') {
        return res.status(400).json({ message: 'Updated treatment plan data is required.' });
    }

    // Find the user by ID
    const user = await User.findById(userid);
    if (!user) {
        return res.status(404).json({ message: 'User not found.' });
    }

    // Find the specific treatment plan by ID
    const treatmentPlan = user.medicalCard.privateData.treatmentPlans.id(planId);
    if (!treatmentPlan) {
        return res.status(404).json({ message: 'Treatment plan not found.' });
    }

    // Update the treatment plan fields
    Object.keys(updatedPlan).forEach((key) => {
        treatmentPlan[key] = updatedPlan[key];
    });

    // Save the updated user document
    await user.save();

    res.status(200).json({
        message: 'Treatment plan updated successfully.',
        updatedPlan: treatmentPlan,
    });
});


/*
    module.exports.verifyCodeAndResetPassword = asyncHandler(async (req, res, next) => {
        const {  verificationCode, newPassword, confirmPassword } = req.body;
    
        // 1. Find the user by email and check the verification code
        const user = await User.findOne({
           
            verificationCode: verificationCode,
            verificationCodeExpires: { $gt: Date.now() } // Check if the code hasn't expired
        });
    
        if (!user) {
            return next(new CustomError('Invalid or expired verification code', 400));
            
        }
    
        // 2. Check if the new password and confirm password match
        if (newPassword !== confirmPassword) {
            return res.status(400).json({ message: "Passwords do not match" });
        }
    
        // 3. Hash the new password and update the user
        const salt = await bcrypt.genSalt(10);
        user.password_hash = await bcrypt.hash(newPassword, salt);
        
        // Clear the verification code and expiration
        user.verificationCode = undefined;
        user.verificationCodeExpires = undefined;
    
        // Update the passwordChangedAt field
        user.passwordChangedAt = Date.now();
    
        await user.save();
    
        res.status(200).json({ message: 'Password has been reset successfully' });
    });
    */
/*
   module.exports.forgetPassword = asyncHandler(async (req, res, next) => {
    // 1. Get user based on email
    const user = await User.findOne({ email: req.body.email });
    if (!user) {
        const error = new CustomError('Invalid email', 404); // Assuming you have a CustomError class
        return next(error);
    }

    // 2. Generate reset token using the instance method
    const resetToken = user.createResetPasswordToken();

    // Save the user document with the reset token and its expiration
    await user.save({ validateBeforeSave: false });

    // 3. Send the token to the user's email (you can customize this further)
    const resetUrl = `${req.protocol}://${req.get('host')}/api/users/resetPassword/${resetToken}`;
    const message = `We have received a password reset request. Please use the below link to reset your password: \n\n${resetUrl}\n\nThis reset password link will be valid only for 10 minutes.`;

    try {
        await sendEmail({
            email: user.email,
            subject: 'Password change request received',
            message: message
        });

        res.status(200).json({
            status: 'success',
            message: 'Password reset link sent to the user\'s email'
        });
    } catch (err) {
        // If there is an error, clear the reset token fields and save the user again
        user.passwordResetToken = undefined;
        user.passwordResetTokenExpires = undefined;
        await user.save({ validateBeforeSave: false });

        return next(new CustomError('There was an error sending the password reset email. Please try again later.', 500));
    }
});

    module.exports.passwordReset = asyncHandler(async(req,res,next)=>{ 
    const token = crypto.createHash('sha256').update(req.params.token).digest('hex');

    //crypto.createHash('sha256').update(req.params.token).digest('hex');

  const user = await User.findOne({passwordResetToken: token, passwordResetTokenExpires: {$gt: Date.now()}});

if(!user){
    const  error = new CustomError('Token is invalid or expired!', 400);
    console.log(error);

    next(error);
}

if(req.body.password == req.body.confirmPassword ){
    user.password_hash=req.body.password;
    user.passwordResetToken= undefined;
    user.passwordResetTokenExpires= undefined;
    user.passwordChangedAt = Date.now();
    user.save();
}else{

    console.log("The passwords not matches!")
}

    });
    */
/**
 * @desc Add Drug to a User
 * @route POST /api/users/:id/adddrugs
 * @method POST
 * @access Public
 */
module.exports.addDrugToUser = asyncHandler(async (req, res) => {
    const { id } = req.params; // User ID
    const { drugName, isPermanent, usageStartDate, usageEndDate } = req.body; // Drug data sent in the request body

    // Find the user
    const user = await User.findById(id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    // Find the drug by name
    const drug = await Drug.findOne({ Drugname: drugName });
    if (!drug) {
        return res.status(404).json({ message: 'Drug not found' });
    }

    // Check if the drug is already added
    const existingDrug = user.medicalCard.publicData.Drugs.find(
        (drugEntry) => drugEntry.drug.toString() === drug._id.toString()
    );
    
    if (existingDrug) {
        return res.status(400).json({ message: 'Drug is already added to this user' });
    }

    const drugEntry = {
        drug: drug._id,
        isPermanent: isPermanent || false, 
        usageStartDate: usageStartDate || null, 
        usageEndDate: usageEndDate || null, 
    };

    user.medicalCard.publicData.Drugs.push(drugEntry);

    await user.save();

    res.status(200).json({ message: 'Drug added to user successfully', user });
});








/**
 * @desc Update Drug End Date for a User
 * @route PUT /api/users/:id/updateDrugEndDate
 * @method PUT
 * @access Public
 */
module.exports.updateDrugEndDate = asyncHandler(async (req, res) => {
    const { id } = req.params; 
    const { drugName, newEndDate } = req.body; 
    const user = await User.findById(id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    const drug = await Drug.findOne({ Drugname: drugName });
    if (!drug) {
        return res.status(404).json({ message: 'Drug not found' });
    }

    const drugEntry = user.medicalCard.publicData.Drugs.find(
        (entry) => entry.drug.toString() === drug._id.toString()
    );
    
    if (!drugEntry) {
        return res.status(404).json({ message: 'Drug not found in user\'s medical card' });
    }

    drugEntry.usageEndDate = newEndDate;

    if (newEndDate && new Date(newEndDate) < new Date()) {
        drugEntry.isExpired = true;
    } else {
        drugEntry.isExpired = false;
    }

    await user.save();

    res.status(200).json({ message: 'Drug end date updated successfully', user });
});









   /**
 * @desc Add Drug to a User
 * @route POST /api/users/:id/adddrugs
 * @method POST
 * @access Public
 */
/*
   module.exports.addDrugToUser = asyncHandler(async (req, res) => {
    const { id } = req.params; // User ID
    const { drugName } = req.body; // Drug name sent in the request body

    // Find the user
    const user = await User.findById(id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    // Find the drug by name
    const drug = await Drug.findOne({ Drugname: drugName });
    if (!drug) {
        return res.status(404).json({ message: 'Drug not found' });
    }

    // Check if the drug is already added
    if (user.medicalCard.publicData.Drugs.includes(drug._id)) {
        return res.status(400).json({ message: 'Drug is already added to this user' });
    }

    // Add the drug's ObjectId to the user's Drugs array
    user.medicalCard.publicData.Drugs.push(drug._id);

    // Save the user document
    await user.save();

    res.status(200).json({ message: 'Drug added to user successfully', user });
});*/
/**
 * @desc Delete Drug from a User's medical card
 * @route DELETE /api/users/:id/deletedrugs
 * @method DELETE
 * @access Public
 */
module.exports.deleteDrugFromUser = asyncHandler(async (req, res) => {
    const { id } = req.params; // User ID
    const { drugName } = req.body; 

    const user = await User.findById(id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    const drug = await Drug.findOne({ Drugname: drugName });
    if (!drug) {
        return res.status(404).json({ message: 'Drug not found' });
    }

    const drugEntryIndex = user.medicalCard.publicData.Drugs.findIndex(
        (entry) => entry.drug.toString() === drug._id.toString()
    );

    if (drugEntryIndex === -1) {
        return res.status(404).json({ message: 'Drug not found in user\'s records' });
    }

    user.medicalCard.publicData.Drugs.splice(drugEntryIndex, 1);

    await user.save();

    res.status(200).json({ message: 'Drug removed from user successfully', user });
});


/** @desc Get Drug for a User
 * @route GET /api/users/:id/getUserDrugs
 * @method GET
 * @access Public
 */
module.exports.getUserDrugs = asyncHandler(async (req, res) => {
    const { id } = req.params;

    const user = await User.findById(id).populate(
        'medicalCard.publicData.Drugs',
        'Drugname Barcode details'
    );
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    const drugs = user.medicalCard.publicData.Drugs;

    res.status(200).json({ message: 'Drugs fetched successfully', drugs });
});


/**
 * @desc Delete Medical History Entry
 * @route DELETE /:id/medicalhistory
 * @method DELETE
 * @access public
 */
module.exports.DeleteMedicalHistory = asyncHandler(async (req, res) => {
    const { entryId } = req.body;

    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    user.medicalCard.privateData.medicalHistory = user.medicalCard.privateData.medicalHistory.filter(
        (entry) => entry._id.toString() !== entryId
    );

    await user.save();

    res.status(200).json({ message: 'Medical history entry deleted successfully' });
});

/**
 * @desc Delete Lab Test Entry
 * @route DELETE /:id/labtests
 * @method DELETE
 * @access public
 */
module.exports.DeleteLabTest = asyncHandler(async (req, res) => {
    const { entryId } = req.body;

    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    user.medicalCard.privateData.labTests = user.medicalCard.privateData.labTests.filter(
        (entry) => entry._id.toString() !== entryId
    );

    await user.save();

    res.status(200).json({ message: 'Lab test entry deleted successfully' });
});

/**
 * @desc Delete Medical Note Entry
 * @route DELETE /:id/medicalNotes
 * @method DELETE
 * @access public
 */
module.exports.DeleteMedicalNote = asyncHandler(async (req, res) => {
    const { entryId } = req.body;

    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    user.medicalCard.privateData.medicalNotes = user.medicalCard.privateData.medicalNotes.filter(
        (entry) => entry._id.toString() !== entryId
    );

    await user.save();

    res.status(200).json({ message: 'Medical note entry deleted successfully' });
});

/**
 * @desc Delete Treatment Plan Entry
 * @route DELETE /:id/treatmentplans
 * @method DELETE
 * @access public
 */
module.exports.DeleteTreatmentPlan = asyncHandler(async (req, res) => {
    const { entryId } = req.body;

    // Find the user by ID
    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    // Filter out the entry to delete
    user.medicalCard.privateData.treatmentPlans = user.medicalCard.privateData.treatmentPlans.filter(
        (entry) => entry._id.toString() !== entryId
    );

    // Save the updated user document
    await user.save();

    res.status(200).json({ message: 'Treatment plan entry deleted successfully' });
});


/**
 * @desc Get treatment plans for a user
 * @route GET /Gettreatmentplans/:id
 * @access public
 */
module.exports.getTreatmentPlans = asyncHandler(async (req, res) => {
    console.log(`innnnnnnnnnnn:`);

    try {
        // Extract the user ID from the request parameters
        const userId = req.params.id;

        // Find the user by ID in the database
        const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Extract treatment plans from the user's medical card
        const treatmentPlans = user.medicalCard?.privateData?.treatmentPlans || [];

        // Respond with the treatment plans
        res.status(200).json({
            message: 'Treatment plans fetched successfully',
            treatmentPlans,
        });
        
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
});

/**
 * @desc Add Medical Notes to a User
 * @route POST /api/users/medicalnotes
 * @method POST
 * @access Private
 */
module.exports.addMedicalNotes = asyncHandler(async (req, res) => {
    const { userid,notes } = req.body; 

    if (!Array.isArray(notes) || notes.length === 0) {
        return res.status(400).json({ message: 'Notes must be a non-empty array.' });
    }

    const invalidNote = notes.find(note => !note.note || typeof note.note !== 'string');
    if (invalidNote) {
        return res.status(400).json({ message: 'Each note must contain a "note" field as a string.' });
    }

    
    const user = await User.findById(userid);
    if (!user) {
        return res.status(404).json({ message: 'User not found.' });
    }

    user.medicalCard.privateData.medicalNotes.push(...notes);

    await user.save();

    res.status(200).json({ 
        message: 'Medical notes added successfully.', 
        medicalNotes: user.medicalCard.privateData.medicalNotes 
    });
});

/**
 * @desc Add Lab Tests to a User
 * @route POST /api/users/addLabTests
 * @method POST
 * @access Private
 */
module.exports.addLabTests = asyncHandler(async (req, res) => {
    const { userid, labTests } = req.body; 
console.log(i);
    if (!Array.isArray(labTests) || labTests.length === 0) {
        return res.status(400).json({ message: 'Lab tests must be a non-empty array.' });
    }

    const invalidTest = labTests.find(test => !test.testName || !test.testResult || !test.testDate ||
        typeof test.testName !== 'string' || typeof test.testResult !== 'string' || typeof test.testDate !== 'string');
    if (invalidTest) {
        return res.status(400).json({ message: 'Each lab test must contain "testName", "testResult", and "testDate" fields as strings.' });
    }

    const user = await User.findById(userid);
    if (!user) {
        return res.status(404).json({ message: 'User not found.' });
    }

    user.medicalCard.privateData.labTests.push(...labTests);

    await user.save();

    res.status(200).json({ 
        message: 'Lab tests added successfully.', 
        labTests: user.medicalCard.privateData.labTests 
    });
});
/**
 * @desc Add Medical History to a User
 * @route POST /api/users/addMedicalHistory
 * @method POST
 * @access Private
 */
module.exports.addMedicalHistory = asyncHandler(async (req, res) => {
    const { userid, medicalHistory } = req.body; 
console.log(medicalHistory,userid);
    if (!Array.isArray(medicalHistory) || medicalHistory.length === 0) {
        return res.status(400).json({ message: 'Medical history must be a non-empty array.' });
    }

    const invalidEntry = medicalHistory.find(entry => 
        !entry.conditionName || 
        !entry.diagnosisDate || 
        !entry.conditionDetails ||
        typeof entry.conditionName !== 'string' || 
        typeof entry.diagnosisDate !== 'string' ||
        typeof entry.conditionDetails !== 'string'
    );
    if (invalidEntry) {
        return res.status(400).json({ message: 'Each medical history entry must contain "condition" and "date" fields as strings.' });
    }
console.log(invalidEntry);
    const user = await User.findById(userid);
    if (!user) {
        return res.status(404).json({ message: 'User not found.' });
    }

    user.medicalCard.privateData.medicalHistory.push(...medicalHistory);

    await user.save();

    res.status(200).json({ 
        message: 'Medical history added successfully.', 
        medicalHistory: user.medicalCard.privateData.medicalHistory 
    });
});

/**
 * @desc Add Treatment Plan to a User
 * @route POST /api/users/addTreatmentPlan
 * @method POST
 * @access Private
 */
module.exports.addTreatmentPlan = asyncHandler(async (req, res) => {
    const { userid, treatmentPlans } = req.body; 
    console.log(treatmentPlans, userid);

    if (!Array.isArray(treatmentPlans) || treatmentPlans.length === 0) {
        return res.status(400).json({ message: 'Treatment plans must be a non-empty array.' });
    }

    const invalidEntry = treatmentPlans.find(entry =>
        !entry.prescribedMedications ||
        !entry.treatmentDuration ||
        !entry.treatmentGoals ||
        !entry.alternativeTherapies ||
        typeof entry.prescribedMedications !== 'string' ||
        typeof entry.treatmentDuration !== 'string' ||
        typeof entry.treatmentGoals !== 'string' ||
        typeof entry.alternativeTherapies !== 'string'
    );

    if (invalidEntry) {
        return res.status(400).json({ message: 'Each treatment plan entry must contain "prescribedMedications", "treatmentDuration", "treatmentGoals", and "alternativeTherapies" fields as strings.' });
    }

    const user = await User.findById(userid);
    if (!user) {
        return res.status(404).json({ message: 'User not found.' });
    }

    user.medicalCard.privateData.treatmentPlans.push(...treatmentPlans);

    await user.save();

    res.status(200).json({
        message: 'Treatment plans added successfully.',
        treatmentPlans: user.medicalCard.privateData.treatmentPlans
    });
});
/////// Statistics //////
/**
 * @desc Get the number of users and doctors with role 'doctor'
 * @route /api/users/stats/count
 * @method GET
 * @access public
 */
module.exports.getCounts = asyncHandler(async (req, res) => {
    try {
        const Pressurecount = await Pressure.countDocuments(); // Count all users

        const BloodSugarcount = await BloodSugar.countDocuments(); // Count all users
        
        const Appointmentcount = await Appointment.countDocuments(); // Count all users

        const DonationRequestcount = await DonationRequest.countDocuments(); // Count all users
        const userCount = await User.countDocuments(); // Count all users
        const doctorCount = await Doctor.countDocuments({ role: 'doctor' }); // Count doctors with role 'doctor'
         // Calculate blood type percentages
         const bloodTypeAggregation = await User.aggregate([
            { 
                $match: { "medicalCard.publicData.bloodType": { $ne: null } } // Match users with defined blood types
            },
            { 
                $group: { 
                    _id: "$medicalCard.publicData.bloodType", 
                    count: { $sum: 1 } 
                } 
            },
            {
                $project: { 
                    bloodType: "$_id", 
                    percentage: { 
                        $multiply: [{ $divide: ["$count", userCount] }, 100] 
                    },
                    _id: 0
                }
            }
        ]);

        res.status(200).json({ userCount, doctorCount,DonationRequestcount,BloodSugarcount,Appointmentcount,Pressurecount,
            bloodTypeDistribution: bloodTypeAggregation

         });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Error fetching counts" });
    }
});
