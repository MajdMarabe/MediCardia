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
        required: true,
        trim: true,
    },
    licenseNumber: {
        type: String,
        required: true,
        trim: true,
        unique: true,
    },
    workplace: {
        name: { type: String, required: true, trim: true }, // اسم المستشفى أو العيادة
        address: { type: String, trim: true }, // العنوان التفصيلي
    },
    isAdmin: {
        type: Boolean,
        default: false,
    },
    verificationCode: {
        type: String,
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
