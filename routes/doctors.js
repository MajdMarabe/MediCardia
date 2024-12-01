const express = require ("express");
const router = express.Router();
const {register,getAllDoctors}=require("../controllers/doctorController");


router.post("/register",register);
router.get("/getAllDoctors",getAllDoctors);

module.exports =router;