const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {Doctor}= require("../models/Doctor");
const DoctorPatientRelation = require('../models/DoctorUser');


const {validateCreatUser,validateLoginUser,validateUpdateUser,validatePublicData,validateHistory,validatelabTests,User}= require("../models/User");
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { validateCreateDoctor } = require('../models/Doctor');
const {verifyTokenAndAuthorization,verifyTokenAndDoctor , verifyToken , verifyTokenAndAdmin}=require("../middlewares/verifyToken");

const sendEmail = require("../middlewares/email");
/**
 * @desc Add a new relation between doctor and patient
 * @route /api/relations
 * @method POST
 * @access Private
 */
module.exports.addRelation = asyncHandler(async (req, res) => {
    const { doctorId, patientId, relationType, notes } = req.body;
  
    // Check if a relation already exists
    const existingRelation = await DoctorPatientRelation.findOne({
      doctorId,
      patientId,
    });
  
    if (existingRelation) {
      return res.status(409).json({ // 409 Conflict status
        message: 'Relation already exists',
        relation: existingRelation
      });
    }
  
    // If no existing relation, create a new one
    const newRelation = new DoctorPatientRelation({
      doctorId,
      patientId,
      relationType,
      notes,
    });
  
    await newRelation.save();


    await Doctor.findByIdAndUpdate(doctorId, { $inc: { numberOfPatients: 1 } });


    res.status(201).json({ message: 'Relation added successfully', relation: newRelation });
  });
  
/**
 * @desc Get all patients for a specific doctor
 * @route /api/relations/doctor/:doctorId
 * @method GET
 * @access Private
 */
module.exports.getPatientsForDoctor =  asyncHandler(async (req, res) => {
    const { doctorId } = req.params;
console.log(doctorId);
    const relations = await DoctorPatientRelation.find({ doctorId, isActive: true })
        .populate('patientId', 'username email location medicalCard');
        console.log(relations);

    res.status(200).json(relations);
});
/**
 * @desc Get all doctors for a specific patient
 * @route /api/relations/patient/:patientId
 * @method GET
 * @access Private
 */
module.exports.getDoctorsForPatient =  asyncHandler(async (req, res) => {
    const { patientId } = req.params;

    const relations = await DoctorPatientRelation.find({ patientId, isActive: true })
        .populate('doctorId', 'fullName email specialization image');

    res.status(200).json(relations);
});
/**
 * @desc Remove relation between doctor and patient
 * @route /api/relations
 * @method DELETE
 * @access Private
 */
module.exports.removeRelation = verifyTokenAndAdmin, asyncHandler(async (req, res) => {
    const { doctorId, patientId } = req.body;

    const relation = await DoctorPatientRelation.findOneAndUpdate(
        { doctorId, patientId, isActive: true },
        { isActive: false, endDate: Date.now() }
    );

    if (!relation) {
        res.status(404).json({ message: 'Relation not found' });
    } else {
      await Doctor.findByIdAndUpdate(doctorId, { $inc: { numberOfPatients: -1 } });

        res.status(200).json({ message: 'Relation removed successfully' });
    }
});
