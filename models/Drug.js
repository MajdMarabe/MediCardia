const mongoose = require("mongoose");
const joi = require('joi');
const jwt = require("jsonwebtoken");
const crypto = require('crypto');

// Drug Schema
const DrugSchema = new mongoose.Schema({
    Drugname: {
        type: String,
        required: true,
        trim: true,
        minlength: 3,
        maxlength: 250,
       unique: true
    },
    Barcode: {
        type: String,
        required: false,
        minlength: 3,
        trim: true,
        maxlength: 250,
        unique: true,
        default: null
    },
    details: [
        {
            Use: { type: String, trim: true, default: null },
            Dose: { type: String,trim: true, default: null }, // e.g., "6 months"
            Time: { type: String,trim: true, default: null },
            Notes: { type: String,trim: true, default: null }, // Optional
        },
      ],
}, { timestamps: true });
function validateBarcode(obj) {
    const schema = joi.object({
        Barcode: joi.string().min(3).max(250).required()
    });
    return schema.validate(obj);
}
function validateDrug (obj) {
    const schema = joi.object({
        Drugname: joi.string().min(3).max(250).required(),
        Barcode: joi.string().min(3).max(250).required(),
        Use: joi.string().min(3).max(250).required(),
        Dose: joi.string().min(3).max(250).required(),
        Time: joi.string().min(3).max(250).required(),
        Notes: joi.string().min(3).max(250).required(),

    });
    return schema.validate(obj);
}
const Drug = mongoose.model("Drug", DrugSchema);

module.exports = {
    Drug,
    validateBarcode,
    validateDrug
   
};
