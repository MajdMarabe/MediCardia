const mongoose = require("mongoose");

const PressureSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    readings: [
        {
            Systolic: { type: Number, required: true }, 
            Diastolic: { type: Number, required: true }, 
           // status: { type: String, enum: ['normal', 'high', 'low'], required: true }, 
            date: { type: Date, default: Date.now }
        }
    ]
}, { timestamps: true });
const Pressure = mongoose.model("Pressure", PressureSchema);

module.exports ={Pressure} ;
