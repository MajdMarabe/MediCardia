const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {Doctor}= require("../models/Doctor");
const Appointment = require('../models/Appointment');
const DoctorSchedule = require('../models/DoctorSchedule');
/**
 * @desc Add a working period for a doctor
 * @route /api/appointment/:doctorId/schedule
 * @method POST
 * @access Private
 */

module.exports.addDoctorSchedule = asyncHandler(async (req, res) => {
    const { doctorId } = req.params;
    const { startTime, endTime, durationMinutes,date } = req.body; 
  console.log( startTime, endTime, durationMinutes );
    if (!startTime || !endTime || !durationMinutes) {
      return res
        .status(400)
        .json({ message: 'Please provide startTime, endTime, and durationMinutes' });
    }
  
    const start = new Date(`2025-01-01T${startTime}:00`);
    const end = new Date(`2025-01-01T${endTime}:00`);
  
    if (start >= end) {
      return res.status(400).json({ message: 'Start time must be before end time' });
    }
  
    const existingSchedules = await DoctorSchedule.find({ doctorId });
    for (const schedule of existingSchedules) {
if(date==schedule.date){
      for (const slot of schedule.slots) {
        const slotStart = new Date(`2025-01-01T${slot.time}:00`);
        const slotEnd = new Date(slotStart.getTime() + durationMinutes * 60000);
  
        if (
          (start < slotEnd && start >= slotStart) || 
          (end > slotStart && end <= slotEnd) || 
          (start <= slotStart && end >= slotEnd) 
        ) {
          return res.status(400).json({
            message: 'The new period overlaps with an existing schedule',
          });
        }
      }
    }
    }
  
    let slots = [];
    let currentTime = start;
  
    while (currentTime < end) {
      const slotTime = currentTime.toTimeString().slice(0, 5); 
      slots.push({ time: slotTime, status: 'available' });
  
      currentTime = new Date(currentTime.getTime() + durationMinutes * 60000);
    }
  
    const newSchedule = new DoctorSchedule({
      doctorId,
      date: date,//.toISOString().slice(0, 10), 
      slots,
      Time: { from: startTime, to: endTime },

    });
  
    await newSchedule.save();
  
    res.status(201).json({
      message: 'Schedule added successfully',
      schedule: newSchedule,
    });
  });
 /**
 * @desc Get all working periods added by a doctor for a specific date
 * @route /api/appointment/:doctorId/schedule
 * @method POST
 * @access Private
 */

module.exports.getDoctorSchedules = asyncHandler(async (req, res) => {
    const { doctorId } = req.params; 
    const { date } = req.body;

    if (!date) {
        return res.status(400).json({
            message: 'Date is required in the request body',
        });
    }

    const schedules = await DoctorSchedule.find({
        doctorId,
        date,
    });

    if (!schedules || schedules.length === 0) {
        return res.status(404).json({
            message: 'No schedules found for this doctor on the specified date',
        });
    }

    const formattedSchedules = schedules.map(schedule => ({
        date: schedule.date,
        time: {
            from: schedule.Time.from,
            to: schedule.Time.to,
        },
    }));

    res.status(200).json({
        message: 'Schedules retrieved successfully',
        schedules: formattedSchedules,
    });
});

  
/**
 * @desc Delete Schedule from Doctor's schedule
 * @route DELETE /api/appointments/:doctorId/schedule
 * @method DELETE
 * @access Public
 */
module.exports.deleteSchedule = asyncHandler(async (req, res) => {
    const { doctorId } = req.params; 
    const { startTime, endTime, date } = req.body; 

    const moment = require('moment');

    const schedules = await DoctorSchedule.find({ doctorId: doctorId, date: date });

    if (!schedules || schedules.length === 0) {
        return res.status(404).json({ message: 'Doctor schedule not found' });
    }

    const targetSchedule = schedules.find(schedule => {
        const dbStartTime = moment(schedule.Time.from, "HH:mm").format("HH:mm");
        const dbEndTime = moment(schedule.Time.to, "HH:mm").format("HH:mm");
        const requestStartTime = moment(startTime, "HH:mm").format("HH:mm");
        const requestEndTime = moment(endTime, "HH:mm").format("HH:mm");

        return dbStartTime === requestStartTime && dbEndTime === requestEndTime;
    });

    if (targetSchedule) {
        await DoctorSchedule.deleteOne({ _id: targetSchedule._id });
        return res.status(200).json({ message: 'Schedule removed successfully' });
    }

    return res.status(404).json({ message: 'Time range not found in any schedule' });
});


/**
 * @desc Update a working period for a doctor
 * @route /api/appointment/:doctorId/schedule
 * @method PUT
 * @access Private
 */
module.exports.updateDoctorSchedule = asyncHandler(async (req, res) => {
    const { doctorId } = req.params;
    const { from, to, newFrom, newTo } = req.body;

    if (!from || !to || !newFrom || !newTo) {
        return res.status(400).json({
            message: 'Please provide from, to, newFrom, and newTo times to update the schedule',
        });
    }

    const existingSchedule = await DoctorSchedule.findOne({ doctorId, 'Time.from': from, 'Time.to': to });

    if (!existingSchedule) {
        return res.status(404).json({
            message: 'Schedule not found',
        });
    }

    const slotIndex = existingSchedule.slots.findIndex(
        (slot) => slot.time === from
    );

    if (slotIndex === -1) {
        return res.status(400).json({
            message: 'The specified slot does not exist in the schedule',
        });
    }

    existingSchedule.slots[slotIndex].time = newFrom;

    existingSchedule.Time.from = newFrom;
    existingSchedule.Time.to = newTo;

    await existingSchedule.save();

    res.status(200).json({
        message: 'Schedule updated successfully',
        schedule: existingSchedule,
    });
});
/**
 * @desc Retrieve all available slots for a specific doctor on a specific date
 * @route GET /api/schedules/:doctorId/slots
 * @method POST
 * @access Public
 */
module.exports.getDoctorSlots = asyncHandler(async (req, res) => {
    const { doctorId } = req.params; 
    const { date } = req.body; 
    console.log(date, doctorId);

    if (!date) {
        return res.status(400).json({
            message: 'Date is required in the body.',
        });
    }

    const schedules = await DoctorSchedule.find({
        doctorId,
        date,
    });

    if (!schedules || schedules.length === 0) {
        return res.status(404).json({
            message: 'No schedule found for this doctor on the specified date.',
        });
    }

    const allSlots = schedules.flatMap(schedule => schedule.slots);

    const availableSlots = allSlots.filter(slot => slot.status === 'available');

    if (availableSlots.length === 0) {
        return res.status(404).json({
            message: 'No available slots for this doctor on the specified date.',
        });
    }

    res.status(200).json({
        message: 'Slots retrieved successfully.',
        slots: availableSlots,
    });
});
/**
 * @desc Retrieve all books slots for a specific doctor on a specific date
 * @route GET /api/schedules/:doctorId/booked
 * @method POST
 * @access Public
 */
module.exports.getDoctorbooked = asyncHandler(async (req, res) => {
    const { doctorId } = req.params; 
    const { date } = req.body; 

    if (!date) {
        return res.status(400).json({
            message: 'Date is required in the body.',
        });
    }

    const schedules = await DoctorSchedule.find({
        doctorId,
        date,
    }).populate({
        path: 'slots.appointmentId', 
        select: 'patientId time status notes', 
        populate: {
            path: 'patientId', 
            select: 'username ', 
        },
    });

    if (!schedules || schedules.length === 0) {
        return res.status(404).json({
            message: 'No schedule found for this doctor on the specified date.',
        });
    }

    const allSlots = schedules.flatMap(schedule => schedule.slots);

    const bookedSlots = allSlots.filter(slot => slot.status === 'booked');

    if (bookedSlots.length === 0) {
        return res.status(404).json({
            message: 'No booked slots for this doctor on the specified date.',
        });
    }
    res.status(200).json({
        message: 'Slots retrieved successfully.',
        slots: bookedSlots.map(slot => ({
            time: slot.time,
            notes: slot.appointmentId?.notes, 

            appointmentId: slot.appointmentId?._id,
            status: slot.status,
            patientName: slot.appointmentId?.patientId?.username,
            patientId: slot.appointmentId?.patientId,

        })),
    });
});

/**
 * @desc Book an appointment by changing the status of a specific slot to "booked"
 * @route POST /api/schedules/:doctorId/book
 * @method POST
 * @access Public
 */
module.exports.bookAppointment = asyncHandler(async (req, res) => {
    const { doctorId } = req.params; 
    const { date, time ,notes} = req.body; 
    const patientId = req.user.id; 
    if (!date || !time) {
        return res.status(400).json({
            message: 'Date and time are required in the body.',
        });
    }

    const schedule = await DoctorSchedule.findOne({
        doctorId,
        date,
        'slots.time': time, 
    });

    if (!schedule) {
        return res.status(404).json({
            message: 'No available slot found for the specified doctor, date, and time.',
        });
    }

    const slot = schedule.slots.find(slot => slot.time === time);

    if (slot.status === 'booked') {
        return res.status(400).json({
            message: 'This slot is already booked.',
        });
    }

    const appointment = await Appointment.create({
        doctorId,
        patientId,
        date,
        time,
        notes,
        status: 'booked',
    });

    slot.status = 'booked';
    slot.appointmentId = appointment._id;  

    await schedule.save();

    res.status(200).json({
        message: 'Appointment booked successfully.',
        appointment: {
            id: appointment._id,
            doctorId: appointment.doctorId,
            patientId: appointment.patientId,
            date: appointment.date,
            time: appointment.time,
            notes:appointment.notes,
        },
    });
});
/**
 * @desc Delete an appointment and reset the corresponding slot in the doctor's schedule
 * @route DELETE /api/appointment/:appointmentId
 * @method DELETE
 * @access Public
 */
module.exports.deleteAppointment = asyncHandler(async (req, res) => {
    const { appointmentId } = req.params;

    // Find the appointment by ID
    const appointment = await Appointment.findById(appointmentId);

    if (!appointment) {
        return res.status(404).json({
            message: 'Appointment not found.',
        });
    }

    // Find the doctor's schedule containing the slot for this appointment
    const schedule = await DoctorSchedule.findOne({
        doctorId: appointment.doctorId,
        date: appointment.date,
        'slots.time': appointment.time,
    });

    if (!schedule) {
        return res.status(404).json({
            message: 'Schedule not found for the doctor and date.',
        });
    }else{
        const slot = schedule.slots.find(slot => slot.time === appointment.time);
        if (slot) {
            slot.status = 'available';
            slot.appointmentId = null;
        }
        await schedule.save();



    }

    // Find the slot in the schedule and reset its status

    // Delete the appointment directly
    await Appointment.findByIdAndDelete(appointmentId);

    // Save the updated schedule

    res.status(200).json({
        message: 'Appointment deleted successfully and slot reset to available.',
    });
});
/**
 * @desc Cancel an appointment and reset the corresponding slot in the doctor's schedule
 * @route PATCH /api/appointment/:appointmentId/cancel
 * @method PATCH
 * @access Public
 */
module.exports.cancelAppointment = asyncHandler(async (req, res) => {
    const { appointmentId } = req.params;

    // Find the appointment by ID
    const appointment = await Appointment.findById(appointmentId);

    if (!appointment) {
        return res.status(404).json({
            message: 'Appointment not found.',
        });
    }

    // Check if the appointment is already cancelled
    if (appointment.status === 'cancelled') {
        return res.status(400).json({
            message: 'The appointment is already cancelled.',
        });
    }

    // Find the doctor's schedule containing the slot for this appointment
    const schedule = await DoctorSchedule.findOne({
        doctorId: appointment.doctorId,
        date: appointment.date,
        'slots.time': appointment.time,
    });

    if (!schedule) {
        return res.status(404).json({
            message: 'Schedule not found for the doctor and date.',
        });
    }

    // Find the slot in the schedule and reset its status
    const slot = schedule.slots.find(slot => slot.time === appointment.time);
    if (slot) {
        slot.status = 'cancelled';
        slot.appointmentId = null;
    }

    // Update the appointment's status to "cancelled"
    appointment.status = 'cancelled';
    await appointment.save();

    // Save the updated schedule
    await schedule.save();

    res.status(200).json({
        message: 'Appointment status updated to cancelled and slot reset to available.',
    });
});


///////

/**
 * @desc Retrieve all booked appointments for a specific user
 * @route GET /api/appointment/:userId/booked
 * @method GET
 * @access Public
 */
module.exports.getUserBookedAppointments = asyncHandler(async (req, res) => {
    const { userId } = req.params;

    // Fetch appointments for the user with status 'booked'
    const appointments = await Appointment.find({
        patientId: userId,
        status: 'booked',
    })
        .populate('doctorId', 'fullName specialization') // Populates doctor information
        .select('date time notes status'); // Select relevant fields

    // Check if appointments exist
    if (!appointments || appointments.length === 0) {
        return res.status(404).json({ message: 'No booked appointments found for this user.' });
    }

    // Respond with the fetched appointments
    res.status(200).json({
        message: 'Booked appointments retrieved successfully.',
        appointments,
    });
});

/**
 * @desc Retrieve all booked appointments for a specific user
 * @route GET /api/appointment/:userId/cancelled
 * @method GET
 * @access Public
 */
module.exports.getUserCancelledAppointments = asyncHandler(async (req, res) => {
    const { userId } = req.params;

    // Fetch appointments for the user with status 'booked'
    const appointments = await Appointment.find({
        patientId: userId,
        status: 'cancelled',
    })
        .populate('doctorId', 'fullName specialization') // Populates doctor information
        .select('date time notes status'); // Select relevant fields

    // Check if appointments exist
    if (!appointments || appointments.length === 0) {
        return res.status(404).json({ message: 'No booked appointments found for this user.' });
    }

    // Respond with the fetched appointments
    res.status(200).json({
        message: 'Booked appointments retrieved successfully.',
        appointments,
    });
});

/**
 * @desc Check if a patient has a completed appointment with a specific doctor
 * @route /api/appointment/check-completed
 * @method POST
 * @access Private
 */
module.exports.checkCompletedAppointment = asyncHandler(async (req, res) => {
    const { patientId, doctorId } = req.body;
console.log("patientId, doctorId ");
    if (!patientId || !doctorId) {
        return res.status(400).json({
            message: 'Patient ID and Doctor ID are required',
        });
    }

    const completedAppointment = await Appointment.findOne({
        patientId,
        doctorId,
        status: 'completed',
    });

    if (!completedAppointment) {
        return res.status(404).json({
            message: 'No completed appointment found for this patient with the specified doctor',
        });
    }

    res.status(200).json({
        message: 'Completed appointment found',
        appointment: {
            date: completedAppointment.date,
            time: completedAppointment.time,
            notes: completedAppointment.notes,
        },
    });
});