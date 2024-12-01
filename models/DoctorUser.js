const { optional } = require('joi');
const mongoose = require('mongoose');

const DoctorPatientRelationSchema = new mongoose.Schema({
    doctorId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor',
        required: true
    },
    patientId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
   /* relationType: { 
        type: String,
        enum: ['consultation', 'treatment', 'follow-up'], 
        default: 'treatment'
    },*/
    startDate: { 
        type: Date,
        default: Date.now
    },
    endDate: { 
        type: Date,
        default: null
    },
    isActive: {
        type: Boolean,
        default: true
    },
    notes: { // ملاحظات إضافية
        type: String,
        trim: true,
        default: null
    
    }
}, { timestamps: true });

const DoctorPatientRelation = mongoose.model('DoctorPatientRelation', DoctorPatientRelationSchema);

module.exports = DoctorPatientRelation;
