const mongoose = require("mongoose");
const joi = require('joi');
const jwt = require("jsonwebtoken");
const crypto = require('crypto');

// project Schema
const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        trim: true,
        minlength: 3,
        maxlength: 250,
        unique: true
    },
    email: {
        type: String,
        required: true,
        minlength: 3,
        trim: true,
        maxlength: 250,
        unique: true
    },
    location: {
        type: String,
        required: true,
        minlength: 3,
        trim: true
    },
    password_hash: {
        type: String,
        required: true,
        minlength: 3,
        trim: true
    },
    isAdmin: {
        type: Boolean,
        default: false
    },
    verificationCode: {
        type: String
    },
    verificationCodeExpires: {
        type: Date
    },
    passwordChangedAt: {
        type: Date
    },
    medicalCard: {
        publicData: {
            idNumber: { type: String, trim: true }, // رقم الهوية
            gender: { type: String, enum: ['Male', 'Female'], trim: true }, // الجنس
            age: { type: Number }, // العمر
            bloodType: { type: String, trim: true }, // زمرة الدم
            chronicConditions: { type: [String], trim: true }, // أمراض مزمنة
            allergies: { type: [String], trim: true }, // حساسية
            lastBloodDonationDate: { type: Date }, // تاريخ آخر تبرع بالدم
            phoneNumber: { type: String, trim: true }, // رقم الهاتف
            Drugs: { type: [String], trim: true },
        },
        privateData: {
/*
            prescribedMedications: { type: [String], trim: true },
            labTests: [
                {
                    testName: { type: String, trim: true },
                    result: { type: String, trim: true },
                    date: { type: Date }
                }
            ],
            doctorNotes: { type: String, trim: true }*/
        },
        permissions: {
           /* doctors: [
                {
                    doctorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor' },
                    accessLevel: { type: String, enum: ['public', 'private'], default: 'private' }
                }
            ]*/
        }
    }
    /*passwordChangedAt: Date,
    passwordResetToken: String,
    passwordResetTokenExpires: Date*/
}, { timestamps: true });

// Token generation method
UserSchema.methods.generateToken = function () {
    return jwt.sign({ id: this._id, isAdmin: this.isAdmin }, process.env.JWT_SECRET_KEY);
};

// Instance method to create a reset password token
UserSchema.methods.createResetPasswordToken = function () {
    const resetToken = crypto.randomBytes(32).toString('hex');

    // Hash the token and set it to the user document
    this.passwordResetToken = crypto.createHash('sha256').update(resetToken).digest('hex');

    // Set expiration time to 10 minutes
    this.passwordResetTokenExpires = Date.now() + 10 * 60 * 1000;

    return resetToken; // Return plain token
};

// Project Model
const User = mongoose.model("User", UserSchema);

// Validation functions
function validateCreatUser(obj) {
    const schema = joi.object({
        username: joi.string().trim().min(3).max(250).required(),
        email: joi.string().trim().min(3).required().email(),
        location: joi.string().trim().min(3).required(),
        password_hash: joi.string().trim().min(3).required(),
    });
    return schema.validate(obj);
}

function validateUpdateUser(obj) {
    const schema = joi.object({
        username: joi.string().trim().min(3).max(250),
        email: joi.string().trim().min(3).email(),
        location: joi.string().trim().min(3),
        password_hash: joi.string().trim().min(3),
    });
    return schema.validate(obj);
}

function validateLoginUser(obj) {
    const schema = joi.object({
        email: joi.string().trim().min(3).required().email(),
        password_hash: joi.string().trim().min(3).required(),
    });
    return schema.validate(obj);
}
function validatePublicData(publicData) {
    const schema = joi.object({
        idNumber: joi.string().trim().optional(),
        gender: joi.string().valid('Male', 'Female').trim().optional(),
        age: joi.number().integer().min(0).optional(),
        bloodType: joi.string().trim().optional(),
        chronicConditions: joi.array().items(joi.string().trim()).optional(),
        allergies: joi.array().items(joi.string().trim()).optional(),
        lastBloodDonationDate: joi.date().optional(),
        phoneNumber: joi.string().trim().optional(),
        Drugs: joi.array().items(joi.string().trim()).optional()
    });

    return schema.validate(publicData);
}
module.exports = {
    User,
    validateCreatUser,
    validateLoginUser,
    validateUpdateUser,
    validatePublicData

};
