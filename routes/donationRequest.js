const express = require ("express");
const router = express.Router();

const {addDonationRequest,getDonationRequestsForUser}=require("../controllers/donationRequestController");

router.post("/addRequest",addDonationRequest);
router.get("/getRequest/:id",getDonationRequestsForUser);


module.exports =router;