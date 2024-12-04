const mongoose = require("mongoose");

const BloodSugarSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    readings: [
        {
            glucoseLevel: { type: Number, required: true }, 
            measurementType: { 
                type: String, 
                enum: ['before_meal', 'after_meal'], 
                required: true 
            },
            status: { type: String, enum: ['normal', 'high', 'low'], required: true }, 
            date: { type: Date, default: Date.now }
        }
    ]
}, { timestamps: true });
const BloodSugar = mongoose.model("BloodSugar", BloodSugarSchema);

module.exports ={BloodSugar} ;
