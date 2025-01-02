const express = require("express");
const router = express.Router();
const { verifyToken ,verifyTokenAndAdmin} = require("../middlewares/verifyToken");

const {
    verifyCode,
    resetPassword,
    verifyCodeAndResetPassword,
    forgetPassword,
    register,
    login,
    getAllUsers,
    getUserById,
    updateUserById,
    deleteUserById,
    updatePublicMedicalCardData,
    UpdatemedicalHistory,
    UpdalabTests,
    UpdamedicalNotes,
    UpdatreatmentPlans,
    DeleteMedicalHistory,
    DeleteLabTest,
    DeleteMedicalNote,
    DeleteTreatmentPlan,
    verifyEmail,
    addDrugToUser,
    updateDrugEndDate,
    deleteDrugFromUser,
    getUserDrugs,
    addMedicalNotes,
    getTreatmentPlans,
    addLabTests,
    addMedicalHistory,
    addTreatmentPlan,
    getSettings,
    updateSettings,
    getProfile,
    changePassword,
    updateProfile,
    getBloodDonationDates,
    addBloodDonationDate
    
} = require("../controllers/userController");

// Drug-related routes
router.post('/:id/adddrugs', addDrugToUser);
router.delete('/:id/deletedrugs', deleteDrugFromUser);
router.get('/:id/getUserDrugs', getUserDrugs);
router.put("/:id/updateDrugEndDate", updateDrugEndDate);
router.get('/:id/blood-donations', getBloodDonationDates);
router.post('/:id/blood-donations', addBloodDonationDate);

// User routes
router.get("/", getAllUsers);
router.get("/:id/setting", getSettings);
router.put("/:id/setsetting", updateSettings);
router.get("/:id", getUserById);
router.get("/profile/:userid", getProfile);
router.put("/change-password",verifyToken, changePassword);
router.put("/update/:userid", updateProfile);


router.post("/register", register);
router.post("/login", login);
router.put("/:id", updateUserById);
router.put('/:id/public-medical-card', updatePublicMedicalCardData);

// Medical card routes
router.put('/updateMedicalHistory', UpdatemedicalHistory);
router.put('/:id/labtests', UpdalabTests);
//router.put('/:id/medicalNotes', UpdamedicalNotes);
router.put('/:userid/treatmentPlans/:planId', UpdatreatmentPlans);

// Delete routes for medical data
router.delete('/:id/medicalhistory', DeleteMedicalHistory);
router.delete('/:id/labtests', DeleteLabTest);
router.delete('/:id/medicalNotes', DeleteMedicalNote);
router.delete('/:id/treatmentplans', DeleteTreatmentPlan);

// Password and email verification routes
router.delete("/:id", deleteUserById);
router.post("/forgetPassword", forgetPassword);
router.post('/verifyCode', verifyCode);
router.post('/resetPassword', resetPassword);
router.post('/verifyEmail', verifyEmail);
router.get('/Gettreatmentplans/:id', getTreatmentPlans);
router.post("/addMedicalNotes",addMedicalNotes);
router.post("/labtests",addLabTests);
router.post("/addMedicalHistory",addMedicalHistory);
router.post("/addTreatmentPlan",addTreatmentPlan);

//router.post('/verifyCode', verifyCodeAndResetPassword);
//router.patch("/verifyCode", passwordReset);

module.exports = router;
