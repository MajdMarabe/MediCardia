const express = require ("express");
const router = express.Router();

const {addHospital,getHospitalsByName}=require("../controllers/hospitalController");

router.post("/addhospital",addHospital);
router.get("/gethospital",getHospitalsByName);

module.exports =router;