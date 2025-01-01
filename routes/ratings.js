const express = require("express");
const router = express.Router();
const { verifyToken ,verifyTokenAndAdmin} = require("../middlewares/verifyToken");
const { getDoctorReviews,addReview,getDoctorReviewSummary,getTopRatedDoctors} = require("../controllers/ratingController");

router.post("/add",verifyToken, addReview);

router.get("/:doctorId",getDoctorReviewSummary );

router.get("/top/rated",getTopRatedDoctors );






module.exports = router;
