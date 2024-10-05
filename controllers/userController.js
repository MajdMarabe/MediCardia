const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {validateCreatUser,validateLoginUser,validateUpdateUser,User}= require("../models/User");
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
 * @desc add new user (sign up)
 * @route /api/users/register
 * @method get
 * @access public 
*/
module.exports.register =  asyncHandler(async(req, res) => {
    // Validate the request body
    const { error } = validateCreatUser(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    // Check if the user already exists
    let user = await User.findOne({ email: req.body.email });
    if (user) {
        return res.status(400).json({ message: "This user already registered" });
    }


    //hashing pass
    const salt = await bcrypt.genSalt(10);
    req.body.password_hash = await bcrypt.hash(req.body.password_hash,salt);
    // Create a new user object with the skill's ObjectId
    user = new User({
        username: req.body.username,
        email: req.body.email,
        location: req.body.location,
      
        password_hash: req.body.password_hash,
        
    });

    try {
        const result = await user.save();
      const token =user.generateToken();
      
        const { password_hash, ...other } = result._doc;
        res.status(201).json({ ...other, token });
    } catch (err) {
        console.error(err);  // Log the error message
        res.status(500).json({ message: " the user name already registered" });
    }
    


});


 /**
 * @desc  login
 * @route /api/users/login
 * @method Post
 * @access public
 */
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
    
     
    });
    ////
    /**
 * @desc get all users 
 * @route /api/users
 * @method get
 * @access public 
*/
    module.exports.getAllUsers=verifyTokenAndAdmin,asyncHandler(async(req,res)=>{
        const users = await User.find().select("-password_hash");  
        res.status(200).json(users);
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

    module.exports.forgetPassword = asyncHandler(async (req, res, next) => {
        // 1. Get user based on email
        const user = await User.findOne({ email: req.body.email });
        if (!user) {
            const error = new CustomError('Invalid email', 404);
            return next(error);
        }
    
        // 2. Generate a random 6-digit verification code
        const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    
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
                message: message
            });
    
            res.status(200).json({
                status: 'success',
                message: 'Verification code sent to the user\'s email'
            });
        } catch (err) {
            // If there is an error, clear the verification code fields and save the user again
            user.verificationCode = undefined;
            user.verificationCodeExpires = undefined;
            await user.save({ validateBeforeSave: false });
    
            return next(new CustomError('There was an error sending the verification code. Please try again later.', 500));
        }
    });
    module.exports.forgetPassword = asyncHandler(async (req, res, next) => {
        // 1. Get user based on email
        const user = await User.findOne({ email: req.body.email });
        if (!user) {
            const error = new CustomError('Invalid email', 404);
            return next(error);
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
                message: message
            });
    
            res.status(200).json({
                status: 'success',
                message: 'Verification code sent to the user\'s email'
            });
        } catch (err) {
            // If there is an error, clear the verification code fields and save the user again
            user.verificationCode = undefined;
            user.verificationCodeExpires = undefined;
            await user.save({ validateBeforeSave: false });
    
            return next(new CustomError('There was an error sending the verification code. Please try again later.', 500));
        }
    });
    
    

    module.exports.verifyCode = asyncHandler(async (req, res, next) => {
        const { verificationCode } = req.body;
    
        // 1. Find the user by the verification code and check if it hasn't expired
        const user = await User.findOne({
            verificationCode: verificationCode,
            verificationCodeExpires: { $gt: Date.now() } // Check if the code hasn't expired
        });
    
        if (!user) {
            return next(new CustomError('Invalid or expired verification code', 400));
        }
    
        // 2. Generate a temporary token for password reset
        const tempToken = jwt.sign(
            { id: user._id }, // Store user ID in the token
           process.env.JWT_SECRET_KEY, // Use your secret key
            { expiresIn: '10m' } // Token expires in 10 minutes
        );
    
        // 3. Send the temporary token to the client
        res.status(200).json({
            status: 'success',
            message: 'Verification code is valid. Use the provided token to reset your password.',
            token: tempToken // Client will use this token for the password reset step
        });
    });
    module.exports.resetPassword = asyncHandler(async (req, res, next) => {
        const { token, newPassword, confirmPassword } = req.body;
    
        // 1. Verify the token to extract the user ID
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET_KEY); // Verify the token
        } catch (err) {
            return next(new CustomError('Invalid or expired token', 400));
        }
    
        // 2. Find the user by ID
        const user = await User.findById(decoded.id);
        if (!user) {
            return next(new CustomError('User not found', 404));
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