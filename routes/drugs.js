const express = require ("express");
const router = express.Router();
const {getbarcode}=require("../controllers/drugController");

router.get("/latest-barcode", getbarcode);
module.exports = router;