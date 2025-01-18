const mongoose = require('mongoose');
const cron = require('node-cron');
const moment = require('moment');

// سكيم الموعد
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
  time: {
    type: String, // Format: HH:mm
    required: true,
  },
  notes: {
    type: String,
    required: false,
  },
  status: {
    type: String,
    enum: ['booked', 'completed', 'cancelled'],
    default: 'booked',
  },
}, { timestamps: true });

// تحقق من وجود النموذج مسبقًا
const Appointment = mongoose.models.Appointment || mongoose.model('Appointment', appointmentSchema);

// وظيفة التحقق
async function checkAndUpdateAppointments() {
  try {
    const currentDate = moment(); // التاريخ الحالي

    // البحث عن المواعيد التي مر موعدها
    const expiredAppointments = await Appointment.find({
      status: 'booked',
    });

    expiredAppointments.forEach(async (appointment) => {
      // تحويل التاريخ المخزن إلى تاريخ قابل للمقارنة
      const appointmentDate = moment(appointment.date, 'DD-MM-YYYY');
      const appointmentTime = moment(appointment.time, 'HH:mm');
      const appointmentDateTime = appointmentDate.set({
        hour: appointmentTime.hours(),
        minute: appointmentTime.minutes(),
      });

      // إذا مر الموعد، قم بتحديثه إلى completed
      if (appointmentDateTime.isBefore(currentDate)) {
        appointment.status = 'completed';
        await appointment.save();
        console.log(`Appointment with ID ${appointment._id} has been marked as completed.`);
      }
    });
  } catch (err) {
    console.error('Error checking appointments:', err);
  }
}

// جدولة الوظيفة لتعمل كل دقيقة
cron.schedule('* * * * *', () => {
  console.log('Running scheduled job to update expired appointments...');
  checkAndUpdateAppointments();
});

module.exports = Appointment;
