const express = require ("express");
const router = express.Router();
const {getDrugByBar,addDrug}=require("../controllers/drugController");

router.get("/barcode", getDrugByBar);
router.post("/adddrug", addDrug);

module.exports = router;