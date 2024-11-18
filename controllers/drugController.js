const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const {validateBarcode,validateDrug,Drug}= require("../models/Drug");
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const axios = require('axios');
/**
 * @desc Get drug name by barcode
 * @route //barcode
 * @method GET
 * @access public 
 */
module.exports.getDrugByBar = asyncHandler(async (req, res) => {
  const bar = req.query.barcode; // Use query parameters instead of the body

  console.log(`barcode: ${bar}`);

  // Validate the barcode if needed
  if (!bar) {
    return res.status(400).json({ message: "Barcode is required" });
  }

  // Check if the barcode exists in the database
  let drug = await Drug.findOne({ Barcode: bar });
  if (!drug) {
    return res.status(404).json({ message: "Drug not found" });
  }

  // Return the drug name
  res.status(200).json({ drugName: drug.Drugname });
});

/** 
* @desc Add new drug
* @route /api/drugs/add
* @method POST
* @access public
*/
module.exports.addDrug = asyncHandler(async (req, res) => {
   // Validate the request body
   const { error } = validateDrug(req.body); // Assuming validateDrug is a Joi validation function for the drug
   if (error) {
       return res.status(400).json({ message: error.details[0].message });
   }

   // Check if the drug already exists by barcode
   let drug = await Drug.findOne({ Barcode: req.body.Barcode });
   if (drug) {
       return res.status(400).json({ message: "Drug with this barcode already exists" });
   }

   // Create a new drug object
   drug = new Drug({
       Drugname: req.body.Drugname,
       Barcode: req.body.Barcode,
   });

   try {
       const result = await drug.save();
       res.status(201).json({ message: "Drug added successfully", drug: result });
   } catch (err) {
       console.error(err); // Log the error message
       res.status(500).json({ message: "Error adding the drug" });
   }
});