const mongoose = require('mongoose');

const doctorScheduleSchema = new mongoose.Schema({
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: true,
  },
  date: {
    type: String, // Format: YYYY-MM-DD
    required: true,
  },
  Time: {
    from: {
        type: String, // Format: HH:mm 
        required: true,
      },
      to: {
        type: String, // Format: HH:mm 
        required: true,
      },

  },
  slots: [
    {
      time: {
        type: String, // Format: HH:mm 
        required: true,
      },
      status: {
        type: String,
        enum: ['available', 'booked'],
        default: 'available',
      },
      appointmentId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Appointment',  
        required: false,  
      },
    },
  ],
}, { timestamps: true });

module.exports = mongoose.model('DoctorSchedule', doctorScheduleSchema);
