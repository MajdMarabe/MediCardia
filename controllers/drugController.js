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
  const bar = req.query.barcode; 

  console.log(`barcode: ${bar}`);

  if (!bar) {
    return res.status(400).json({ message: "Barcode is required" });
  }

  let drug = await Drug.findOne({ Barcode: bar });
  if (!drug) {
    return res.status(404).json({ message: "Drug not found" });
  }

  res.status(200).json({ drugName: drug.Drugname });
});
/**
 * @desc Get drug  by barcode
 * @route /barcodeUse
 * @method GET
 * @access public 
 */
module.exports.getDrugUseByBar = asyncHandler(async (req, res) => {
  const bar = req.query.barcode; 

  console.log(`barcode: ${bar}`);

  if (!bar) {
    return res.status(400).json({ message: "Barcode is required" });
  }

  let drug = await Drug.findOne({ Barcode: bar });
  if (!drug) {
    return res.status(404).json({ message: "Drug not found" });
  }

  res.status(200).json({ drug: drug });
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


/**
 * @desc Search for drug interactions by query
 * @route /searchDrugInteractions
 * @method GET
 * @access public
 */
module.exports.searchDrugInteractions = asyncHandler(async (req, res) => {
  const { query } = req.query; // Retrieve the query string

  try {
    const response = await axios.get(
      `https://www.medscape.com/api/quickreflookup/LookupService.ashx?q=${encodeURIComponent(query)}&sz=500&type=10417&metadata=has-interactions&format=json`
    );
    res.status(200).json(response.data);
  } catch (error) {
    console.error("Error fetching data:", error.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

/**
 * @desc Get drug interactions by IDs
 * @route /getDrugInteraction
 * @method GET
 * @access public
 */
module.exports.getDrugInteraction = asyncHandler(async (req, res) => {
  const { ids } = req.query;

  if (!ids) {
    return res.status(400).json({ error: "Drug IDs are required" });
  }

  try {
    const response = await axios.get(
      `https://reference.medscape.com/druginteraction.do?action=getMultiInteraction&ids=${encodeURIComponent(ids)}`
    );
    res.status(200).json(response.data);
  } catch (error) {
    console.error("Error fetching data from Medscape API:", error.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

/**
 * @desc Check for interactions between multiple drugs
 * @route /checkDrugInteractions
 * @method POST
 * @access public
 */
module.exports.checkDrugInteractions = asyncHandler(async (req, res) => {
  const drugNames = req.body.drugs;

  if (!Array.isArray(drugNames) || drugNames.length < 2) {
    return res.status(400).json({ error: "You must provide at least two drug names." });
  }

  const drugIds = await fetchRelevantDrugIds(drugNames);

  if (drugIds.length < 2) {
    return res.status(400).json({
      error: "Unable to fetch valid IDs for at least two drugs.",
      details: { drugIds },
    });
  }

  try {
    const response = await axios.get(
      `http://localhost:5001/api/drugs/getDrugInteraction?ids=${drugIds.join(',')}`
    );

    if (response.data && Array.isArray(response.data.multiInteractions)) {
      const interactions = response.data.multiInteractions;
      if (interactions.length > 0) {
        console.log(`Found ${interactions.length} interactions.`);
        interactions.forEach((interaction, index) => {
          console.log(
            `${index + 1}: ${interaction.subject} and ${interaction.object} - ${interaction.text}`
          );
        });
      } else {
        console.log("No interactions found.");
      }
    } else {
      console.log("No interactions or invalid response format.");
    }

    res.status(200).json({
      message: "Drug interactions fetched successfully.",
      interactions: response.data,
    });
  } catch (error) {
    console.error("Error checking interactions:", error.message);
    res.status(500).json({
      error: "Failed to check drug interactions.",
      details: error.message,
    });
  }
});

/**
 * @desc Fetch relevant drug IDs for the given drug names
 * @param {string[]} drugNames - List of drug names to fetch IDs for
 * @returns {Promise<string[]>} List of drug IDs
 */
const fetchRelevantDrugIds = async (drugNames) => {
  const drugIds = [];

  for (const drugName of drugNames) {
    try {
      const response = await axios.get(`http://localhost:5001/api/drugs/searchDrugInteractions`, {
        params: { query: drugName },
      });

      const references = response.data.types[0]?.references || [];

      let selectedId = null;
      for (const ref of references) {
        if (ref.text.toLowerCase() === drugName.toLowerCase()) {
          selectedId = ref.id; // Exact match
          break;
        }
      }

      if (!selectedId && references.length > 0) {
        selectedId = references[0].id; // Default to the first result
      }

      if (selectedId) {
        drugIds.push(selectedId);
        console.log(`Selected ID for "${drugName}": ${selectedId}`);
      } else {
        console.warn(`No valid ID found for "${drugName}".`);
      }
    } catch (error) {
      console.error(`Error fetching data for "${drugName}":`, error.message);
    }
  }

  return drugIds;
};