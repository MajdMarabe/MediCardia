const express = require ("express");
const router = express.Router();
const {register,getAllDoctors,getSettings,updateSettings,AddDoctorByAdmin,getDoctorCountsBySpecialization,getDoctorStatsById,deleteDoctorById,updateDoctorbyAdmin,getDoctorById,searchDoctors,updateProfile,getProfile,changePassword,registerAdmin}=require("../controllers/doctorController");

const { verifyToken ,verifyTokenAndAdmin} = require("../middlewares/verifyToken");

router.post("/register",register);
router.get("/getAllDoctors",getAllDoctors);
router.get("/:id/setting", getSettings);
router.put("/:id/setsetting", updateSettings);
router.get("/:id", getDoctorById);
router.put("/update/:doctorId", updateProfile);
router.get("/profile/:doctorId", getProfile);
router.post("/admin/register",registerAdmin);

router.put("/change-password",verifyToken, changePassword);
//////
router.get('/admin/search',searchDoctors);
router.get('/:doctorid/stats',getDoctorStatsById);
router.get('/stats/count',getDoctorCountsBySpecialization);
router.delete("/:id", deleteDoctorById);
router.put("/admin/update/:userid", updateDoctorbyAdmin);
router.post("/addDoctor/admin",AddDoctorByAdmin);

module.exports =router;