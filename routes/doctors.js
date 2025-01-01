const express = require ("express");
const router = express.Router();
const {register,getAllDoctors,getSettings,updateSettings,getDoctorById,updateProfile,getProfile,changePassword}=require("../controllers/doctorController");

const { verifyToken ,verifyTokenAndAdmin} = require("../middlewares/verifyToken");

router.post("/register",register);
router.get("/getAllDoctors",getAllDoctors);
router.get("/:id/setting", getSettings);
router.put("/:id/setsetting", updateSettings);
router.get("/:id", getDoctorById);
router.put("/update/:doctorId", updateProfile);
router.get("/profile/:doctorId", getProfile);

router.put("/change-password",verifyToken, changePassword);

module.exports =router;