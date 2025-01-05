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
    getDoctorbooked
} = require("../controllers/appointmentController");



router.post('/:doctorId/schedule',verifyToken, addDoctorSchedule);
router.post('/:doctorId',verifyToken, getDoctorSchedules);
router.put('/:doctorId/schedule',verifyToken, updateDoctorSchedule);
router.delete('/:doctorId/schedule',verifyToken, deleteSchedule);
router.post('/schedules/:doctorId/slots', getDoctorSlots);
router.post('/schedules/:doctorId/booked', getDoctorbooked);

//////
router.post('/schedules/:doctorId/book',verifyToken, bookAppointment);

module.exports = router;
