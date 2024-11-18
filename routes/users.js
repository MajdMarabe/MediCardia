const express = require ("express");
const router = express.Router();
const {verifyCode,resetPassword,verifyCodeAndResetPassword,forgetPassword,register,login,getAllUsers,getUserById,updateUserById,deleteUserById,updatePublicMedicalCardData,UpdatemedicalHistory,UpdalabTests,UpdamedicalNotes,UpdatreatmentPlans}=require("../controllers/userController");


/////

router.get("/",getAllUsers);

router.get("/:id",getUserById) ;

router.post("/register",register);
router.post("/login",login);  


router.put("/:id",updateUserById); 
router.put('/:id/public-medical-card', updatePublicMedicalCardData);
router.put('/:id/medicalhistory' , UpdatemedicalHistory);
router.put('/:id/labtests' ,UpdalabTests);
router.put('/:id/medicalNotes' ,UpdamedicalNotes);
router.put('/:id/treatmentPlans' ,UpdatreatmentPlans);


router.delete("/:id",deleteUserById);
router.post("/forgetPassword",forgetPassword);
router.post('/verifyCode', verifyCode);
router.post('/resetPassword', resetPassword);

//router.post('/verifyCode', verifyCodeAndResetPassword);

///router.patch("/verifyCode",passwordReset);
module.exports =router;