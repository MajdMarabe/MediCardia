const express = require ("express");
const router = express.Router();
const {register,getAllDoctors,getSettings,updateSettings,getDoctorById}=require("../controllers/doctorController");


router.post("/register",register);
router.get("/getAllDoctors",getAllDoctors);
router.get("/:id/setting", getSettings);
router.put("/:id/setsetting", updateSettings);
router.get("/:id", getDoctorById);
module.exports =router;