const express = require("express");
const router = express.Router();
const { verifyToken ,verifyTokenAndAdmin} = require("../middlewares/verifyToken");
const {
    addDoctorSchedule,
    getDoctorSchedules,
    deleteSchedule,
    updateDoctorSchedule,
    getDoctorSlots,
    bookAppointment,
    getDoctorbooked,
    getUserBookedAppointments,
    deleteAppointment,
    cancelAppointment,
    getUserCancelledAppointments,
    checkCompletedAppointment
    
} = require("../controllers/appointmentController");



router.post('/:doctorId/schedule',verifyToken, addDoctorSchedule);
router.post('/:doctorId',verifyToken, getDoctorSchedules);
router.put('/:doctorId/schedule',verifyToken, updateDoctorSchedule);
router.delete('/:doctorId/schedule',verifyToken, deleteSchedule);
router.post('/schedules/:doctorId/slots', getDoctorSlots);
router.post('/schedules/:doctorId/booked', getDoctorbooked);

//////
router.post('/schedules/:doctorId/book',verifyToken, bookAppointment);
router.get('/:userId/booked', getUserBookedAppointments);
router.delete('/:appointmentId', deleteAppointment);// by user
router.patch('/:appointmentId/cancel', cancelAppointment);// by doctor
router.get('/:userId/cancelled', getUserCancelledAppointments);

router.post('/check/completed', checkCompletedAppointment);

module.exports = router;
