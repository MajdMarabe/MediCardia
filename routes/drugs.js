const express = require ("express");
const router = express.Router();
const {getDrugByBar,addDrug,checkDrugInteractions,searchDrugInteractions,getDrugInteraction,getDrugUseByBar,getDrugUseByName}=require("../controllers/drugController");

router.get("/barcode", getDrugByBar);
router.get("/barcodeUse", getDrugUseByBar);

router.post("/adddrug", addDrug);
router.post("/checkDrugInteractions", checkDrugInteractions);

router.get("/searchDrugInteractions", searchDrugInteractions);

router.get("/getDrugInteraction", getDrugInteraction);
router.get("/getDrugbyName", getDrugUseByName);

module.exports = router;

