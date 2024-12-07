const mongoose = require("mongoose");
const joi = require('joi');
const jwt = require("jsonwebtoken");
const crypto = require('crypto');

// User Schema
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
    role: {
        type: String,
        required: true,
        enum: ['patient', 'doctor','admin'],
        default: 'patient' 
    },
    medicalCard: {
        publicData: {
            idNumber: { type: String, trim: true, default: null ,unique: true}, 
            gender: { type: String, enum: ['Male', 'Female'], trim: true, default: null }, 
            age: { type: Number, default: null }, 
            bloodType: { type: String, trim: true, default: null },
            chronicConditions: { type: [String], trim: true, default: [] }, 
            allergies: { type: [String], trim: true, default: [] },
            lastBloodDonationDate: { type: Date, default: null },
            phoneNumber: { type: String, trim: true, default: null },
          /*  Drugs:[
                { 
                    type: mongoose.Schema.Types.ObjectId, 
                    ref: "Drug" 
                },
            ],*/

            Drugs: [
                { 
                    drug: { type: mongoose.Schema.Types.ObjectId, ref: "Drug" }, // الربط مع جدول الأدوية
                   isPermanent: { type: Boolean, default: false }, // دائم أم مؤقت
                usageStartDate: { type: Date, default: null }, // تاريخ البدء
                    usageEndDate: { type: Date, default: null } // تاريخ الانتهاء (للأدوية المؤقتة)
                },
            ],
             //{ type: [String], trim: true, default: [] },
            image: { 
                type: String,  // Store base64 image string
                default: null 
            },
        },
        privateData: {
            medicalHistory: [
                {
                  conditionName: { type: String, trim: true, default: null  },
                  diagnosisDate: { type: Date,  default: Date.now  },
                  conditionDetails: { type: String , trim: true, default: null },
                },
              ],
              labTests: [
                {
                  testName: { type: String, trim: true, default: null },
                  testResult: { type: String  , trim: true, default: null },
                  testDate: { type: Date, trim: true, default: null  },
                },
              ],
              medicalNotes: [
                {
                  note: { type: String, trim: true, default: null },
                //  dateAdded: { type: Date, default: Date.now },
                },
              ],
              treatmentPlans: [
                {
                  prescribedMedications: { type: String, trim: true, default: null },
                  treatmentDuration: { type: String,trim: true, default: null }, // e.g., "6 months"
                  treatmentGoals: { type: String,trim: true, default: null },
                  alternativeTherapies: { type: String,trim: true, default: null }, // Optional
                },
              ],
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
        lastBloodDonationDate: joi.alternatives().try(joi.date(), joi.string().allow('').optional()),
        phoneNumber: joi.string().trim().optional(),
        Drugs: joi.array().items(joi.string().trim()).optional(),
        image: joi.string().optional() 


    });

    return schema.validate(publicData);
}

function validateHistory(publicData) {
    const schema = joi.object({
        conditionName: joi.string().trim().optional(),
        diagnosisDate: joi.alternatives().try(joi.date(), joi.string().allow('').optional()),
        conditionDetails: joi.string().trim().optional(),


    });

    return schema.validate(publicData);
}

function validateHistory(publicData) {
    const schema = joi.object({
        
        conditionName: joi.string().trim().optional(),
        diagnosisDate: joi.alternatives().try(joi.date(), joi.string().allow('').optional()),
        conditionDetails: joi.string().trim().optional(),

    });

    return schema.validate(publicData);
}


function validatelabTests(publicData) {
    const schema = joi.object({
        testName: joi.string().trim().optional(),
        testDate: joi.alternatives().try(joi.date(), joi.string().allow('').optional()),
        testResult: joi.string().trim().optional(), 


    });

    return schema.validate(publicData);
}


module.exports = {
    User,
    validateCreatUser,
    validateLoginUser,
    validateUpdateUser,
    validatePublicData,
    validateHistory,
    validatelabTests
};
