const express = require('express');
const { addRelation, getPatientsForDoctor, getDoctorsForPatient, updateRelation, removeRelation } = require('../controllers/doctorUserController');

const router = express.Router();

router.post('/relations', addRelation);
router.get('/relations/doctor/:doctorId', getPatientsForDoctor);
router.get('/relations/patient/:patientId', getDoctorsForPatient);
//router.patch('/relations', updateRelation);
router.delete('/relations', removeRelation);

module.exports =router;