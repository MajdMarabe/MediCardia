const mongoose = require("mongoose");
const joi = require("joi");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

const DoctorSchema = new mongoose.Schema({
    fullName: {
        type: String,
        required: true,
        trim: true,
        minlength: 3,
        maxlength: 250,
    },
    image: { 
        type: String,  // Store base64 image string
        default: null 
    },
    email: {
        type: String,
        required: true,
        trim: true,
        minlength: 3,
        maxlength: 250,
        unique: true,
    },
    password_hash: {
        type: String,
        required: true,
        trim: true,
        minlength: 3,
    },
    phone: {
        type: String,
        required: true,
        trim: true,
    },
    specialization: {
        type: String,
        required: function() { return this.role === 'doctor'; }, 
        enum: [
            "General",
            "Plastic Surgery",
            "Eye",
            "Nose",
            "Dentistry",
            "Cardiology",
            "Endocrinology",
            "Nephrology",
            "Psychiatry",
            "Gynecology",
            "Pediatrics",
          ],
        trim: true,
    },
    licenseNumber: {
        type: String,
        required: function() { return this.role === 'doctor'; }, 
        trim: true,
        unique: true,
    },
    workplace: {
        name: { type: String,         
          required: function() { return this.role === 'doctor'; }, 
             trim: true }, // اسم المستشفى أو العيادة
        address: { type: String, trim: true }, // العنوان التفصيلي
    },
    verificationCode: {
        type: String,
    },
    about: {
        type: String,
        default:null,
    },
    verificationCodeExpires: {
        type: Date,
    },
    passwordChangedAt: {
        type: Date,
    },
    role: {
        type: String,
        enum: ['patient', 'doctor', 'admin'],
        default: 'doctor', 
    },
    notificationSettings: {
       /// reminders: {type: Boolean, default: true} ,
        messages: {type: Boolean, default: true} ,
        requests: {type: Boolean, default: true} ,
    },
      numberOfPatients: {
        type: Number,
        default: 0,
    },
    averageRating: {
        type: Number,
        default: 0, 
    },
    numberOfReviews: {
        type: Number,
        default: 0, 
    },
}, { timestamps: true });

DoctorSchema.methods.generateToken = function () {
    return jwt.sign({ id: this._id, isAdmin: this.isAdmin }, process.env.JWT_SECRET_KEY);
};

DoctorSchema.methods.createResetPasswordToken = function () {
    const resetToken = crypto.randomBytes(32).toString("hex");

    this.passwordResetToken = crypto.createHash("sha256").update(resetToken).digest("hex");

    this.passwordResetTokenExpires = Date.now() + 10 * 60 * 1000;

    return resetToken; 
};

const Doctor = mongoose.model("Doctor", DoctorSchema);

function validateCreateDoctor(obj) {
    const schema = joi.object({
        fullName: joi.string().trim().min(3).max(250).required(),
        email: joi.string().trim().min(3).email().required(),
        password_hash: joi.string().trim().min(3).required(),
        phone: joi.string().trim().required(),
        specialization: joi.string().trim().required(),
        licenseNumber: joi.string().trim().required(),
        workplaceName: joi.string().trim().required(),
        workplaceAddress: joi.string().trim().optional(),
                image: joi.string().optional() ,
        
    });
    return schema.validate(obj);
}

function validateUpdateDoctor(obj) {
    const schema = joi.object({
        fullName: joi.string().trim().min(3).max(250),
        email: joi.string().trim().min(3).email(),
        password_hash: joi.string().trim().min(3),
        phone: joi.string().trim(),
        specialization: joi.string().trim(),
        licenseNumber: joi.string().trim(),
        workplaceName: joi.string().trim(),
        workplaceAddress: joi.string().trim(),
        image: joi.string().optional() ,
        
about:joi.string().optional(),
    });
    return schema.validate(obj);
}

function validateLoginDoctor(obj) {
    const schema = joi.object({
        email: joi.string().trim().min(3).email().required(),
        password_hash: joi.string().trim().min(3).required(),
    });
    return schema.validate(obj);
}

module.exports = {
    Doctor,
    validateCreateDoctor,
    validateUpdateDoctor,
    validateLoginDoctor,
};
