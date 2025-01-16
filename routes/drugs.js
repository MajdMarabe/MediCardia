const express = require ("express");
const router = express.Router();
const {getDrugByBar,getDrugById,updateDrug,addDrugByAdmin,addDrug,getDrugSuggestions,deleteDrug,getAllDrugs,checkDrugInteractions,searchDrugInteractions,getDrugInteraction,getDrugUseByBar,getDrugUseByName}=require("../controllers/drugController");
const { verifyToken ,verifyTokenAndAdmin} = require("../middlewares/verifyToken");

router.get("/barcode", getDrugByBar);
router.get("/barcodeUse", getDrugUseByBar);

router.post("/adddrug", addDrug);
router.post("/checkDrugInteractions", checkDrugInteractions);

router.get("/searchDrugInteractions", searchDrugInteractions);

router.get("/getDrugInteraction", getDrugInteraction);
router.get("/getDrugbyName", getDrugUseByName);

router.get("/:drugId", getDrugById);
router.get("/getDrug/Suggestions", getDrugSuggestions);
router.post("/admin", addDrugByAdmin);
router.get("/", getAllDrugs);
router.put("/:id", updateDrug);
router.delete("/:id", deleteDrug);


module.exports = router;

