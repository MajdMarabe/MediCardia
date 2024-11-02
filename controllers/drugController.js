const jwt =require("jsonwebtoken");
const asyncHandler= require("express-async-handler"); 
const axios = require('axios');

   /**
 * @desc get barcode
 * @route /api/latest-barcode
 * @method get
 * @access public 
*/
module.exports.getbarcode=asyncHandler(async(req,res)=>{
  
    try {
        // Make a GET request to the Python server
        const response = await axios.get('http://localhost:5001/get_latest_barcode');
        
        // Send the barcode data to the client
        res.json(response.data);
      } catch (error) {
        console.error("Error fetching barcode data:", error);
        res.status(500).json({ error: "Could not fetch barcode data from Python server" });
      }
});