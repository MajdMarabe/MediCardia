const mongoose = require('mongoose');

const donationRequestSchema = new mongoose.Schema({
    bloodType: { type: String, required: true }, 
    units: { type: String, required: true },
    hospital: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'Hospital', 
        required: true 
    }, 
    createdByDoctor: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'Doctor', 
        required: true 
    }, 
    requiredDate: { type: Date, required: true },  
    assignedToUser: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    }, 
}, 
{
    timestamps: true, 
});

const DonationRequest = mongoose.model('DonationRequest', donationRequestSchema);
const Joi = require('joi');

// Validation function for the donation request
const validateDonationRequest = (data) => {
    const schema = Joi.object({
        bloodType: Joi.string().required(),
        units: Joi.string().required(),
        hospital: Joi.string().required(),
        createdByDoctor: Joi.string().required(),
        requiredDate: Joi.date().required(),
        assignedToUser: Joi.string().required()
    });

    return schema.validate(data);
};

module.exports = { DonationRequest,validateDonationRequest };

