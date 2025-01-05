const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: true,
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  date: {
    type: String, // Format: YYYY-MM-DD
    required: true,
  },
  notes: {
    type: String, // Format: YYYY-MM-DD
    required: false,
  },
  time: {
    type: String, // Format: HH:mm 
    required: true,
  },
  status: {
    type: String,
    enum: ['booked', 'completed', 'cancelled'],
    default: 'booked',
  },
}, { timestamps: true });

module.exports = mongoose.model('Appointment', appointmentSchema);
