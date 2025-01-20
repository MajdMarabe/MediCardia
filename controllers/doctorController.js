const jwt = require("jsonwebtoken");
const asyncHandler = require("express-async-handler");
const bcrypt = require('bcryptjs');
const { Doctor, validateCreateDoctor ,validateUpdateDoctor} = require('../models/Doctor');
const DoctorSchedule = require('../models/DoctorSchedule');

const sendEmail = require("../middlewares/email");
/**
 * @desc Register a new admin
 * @route /api/admins/register
 * @method POST
 * @access public
 */
module.exports.registerAdmin = asyncHandler(async (req, res, next) => {
    const { fullName, email, password_hash, phone } = req.body;

    if (!fullName || !email || !password_hash || !phone) {
        return res.status(400).json({ message: "All fields are required" });
    }

    let admin = await Doctor.findOne({ email });
    if (admin) {
        return res.status(400).json({ message: "This email is already registered" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password_hash, salt);

    admin = new Doctor({
        fullName,
        email,
        password_hash: hashedPassword,
        phone,
        role: "admin", 
    });

    try {
        const result = await admin.save();

        const token = admin.generateToken();

        const { password_hash, ...other } = result._doc;

        res.status(201).json({
            ...other,
            token,
            message: "Admin registered successfully",
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "There was an error registering the admin" });
    }
});

/**
 * @desc Sign up a new doctor
 * @route /api/doctors/register
 * @method POST
 * @access public
 */
module.exports.register = asyncHandler(async (req, res, next) => {
    const { error } = validateCreateDoctor(req.body);
    console.log(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    let doctor = await Doctor.findOne({ email: req.body.email });
    if (doctor) {
        return res.status(400).json({ message: "This email is already registered" });
    }

    doctor = await Doctor.findOne({ licenseNumber: req.body.licenseNumber });
    if (doctor) {
        return res.status(400).json({ message: "This license number is already registered" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(req.body.password_hash, salt);

    doctor = new Doctor({
        fullName: req.body.fullName,
        image: req.body.image,
        email: req.body.email,
        password_hash: hashedPassword,
        phone: req.body.phone,
        specialization: req.body.specialization,
        licenseNumber: req.body.licenseNumber,
        workplace: {
            name: req.body.workplaceName,
            address: req.body.workplaceAddress || '',
        },
    });

    try {
        const result = await doctor.save();

        const verifyResponse = await module.exports.verifyEmail({ body: { email: doctor.email } }, res, next);
        if (!verifyResponse) {
            return; 
        }

        const token = doctor.generateToken();

        const { password_hash, ...other } = result._doc;

        res.status(201).json({
            ...other,
            token,
            message: "Doctor registered successfully. Please verify your email."
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "There was an error registering the doctor" });
    }
});
/**
 * @desc Get doctor's profile before update
 * @route /api/doctors/profile/:doctorId
 * @method GET
 * @access private (requires authentication)
 */
module.exports.getProfile = asyncHandler(async (req, res, next) => {
    const doctor = await Doctor.findById(req.params.doctorId);
    if (!doctor) {
        return res.status(404).json({ message: "Doctor not found" });
    }

    const { password_hash, ...doctorData } = doctor._doc;

    res.status(200).json({
        message: "Doctor profile fetched successfully",
        doctor: doctorData,
    });
});

/**
 * @desc Change doctor's password
 * @route PUT /api/doctors/change-password
 * @method PUT
 * @access Private (requires authentication)
 */
module.exports.changePassword = asyncHandler(async (req, res) => {
    const { oldPassword, newPassword, confirmPassword } = req.body;
console.log(oldPassword);
    if (!oldPassword || !newPassword || !confirmPassword) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    if (newPassword !== confirmPassword) {
        return res.status(400).json({ message: 'New passwords do not match' });
    }

    const doctorId = req.user.id; 
    const doctor = await Doctor.findById(doctorId);

    if (!doctor) {
        return res.status(404).json({ message: 'Doctor not found' });
    }

    const isPasswordMatch = await bcrypt.compare(oldPassword, doctor.password_hash);
    if (!isPasswordMatch) {
        return res.status(400).json({ message: 'Old password is incorrect' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    doctor.password_hash = hashedPassword;
    await doctor.save();

    res.status(200).json({ message: 'Password changed successfully' });
});

/**
 * @desc Update doctor's profile
 * @route /api/doctors/update/:doctorId
 * @method PUT
 * @access private (requires authentication)
 */
module.exports.updateProfile = asyncHandler(async (req, res, next) => {
    console.log(req.body);
    const { error } = validateUpdateDoctor(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    const doctor = await Doctor.findById(req.params.doctorId);
    if (!doctor) {
        return res.status(404).json({ message: "Doctor not found" });
    }

    if (req.body.email && req.body.email !== doctor.email) {
        const emailExists = await Doctor.findOne({ email: req.body.email });
        if (emailExists) {
            return res.status(400).json({ message: "This email is already registered" });
        }
    }

    if (req.body.licenseNumber && req.body.licenseNumber !== doctor.licenseNumber) {
        const licenseExists = await Doctor.findOne({ licenseNumber: req.body.licenseNumber });
        if (licenseExists) {
            return res.status(400).json({ message: "This license number is already registered" });
        }
    }

    doctor.fullName = req.body.fullName || doctor.fullName;
    doctor.image = req.body.image || doctor.image;
    doctor.about = req.body.about || doctor.about;

    
    doctor.email = req.body.email || doctor.email;
    doctor.phone = req.body.phone || doctor.phone;
    doctor.specialization = req.body.specialization || doctor.specialization;
    doctor.licenseNumber = req.body.licenseNumber || doctor.licenseNumber;
    doctor.workplace.name = req.body.workplaceName || doctor.workplace.name;
    doctor.workplace.address = req.body.workplaceAddress || doctor.workplace.address;

    try {
        const updatedDoctor = await doctor.save();

        const { password_hash, ...updatedData } = updatedDoctor._doc;

        res.status(200).json({
            message: "Doctor profile updated successfully",
            doctor: updatedData,
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "There was an error updating the profile" });
    }
});

/**
 * @desc Verify Email for Doctor
 * @route /api/doctors/verifyemail
 * @method POST
 * @access public
 */
module.exports.verifyEmail = asyncHandler(async (req, res, next) => {
    const { email } = req.body;

    const doctor = await Doctor.findOne({ email });
    if (!doctor) {
        return next(new CustomError('Email not found', 404));
    }

    const verificationCode = Math.floor(1000 + Math.random() * 9000).toString();

    doctor.verificationCode = verificationCode;
    doctor.verificationCodeExpires = Date.now() + 10 * 60 * 1000; // 10 minutes expiration
    await doctor.save({ validateBeforeSave: false });

    const message = `${verificationCode}`;

    try {
        await sendEmail({
            email: doctor.email,
            subject: 'Email Verification Code',
            message,
        });

        res.status(200).json({
            status: 'success',
            message: 'Verification code sent to your email',
        });
    } catch (err) {
        doctor.verificationCode = undefined;
        doctor.verificationCodeExpires = undefined;
        await doctor.save({ validateBeforeSave: false });

        return next(new CustomError('Error sending verification code. Please try again.', 500));
    }
});

/**
 * @desc Get all doctors and their info
 * @route /api/doctors
 * @method GET
 * @access public
 */
module.exports.getAllDoctors = asyncHandler(async (req, res, next) => {
    try {
        const doctors = await Doctor.find().select('-password_hash'); 

        if (!doctors || doctors.length === 0) {
            return res.status(404).json({ message: "No doctors found." });
        }

        res.status(200).json(doctors);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "There was an error retrieving the doctors." });
    }
});







/**
 * @desc get doctor by id
 * @route /api/doctors/:id
 * @method get
 * @access public 
*/
module.exports.getDoctorById=asyncHandler(async(req,res)=>{ 

    const user = await Doctor.findById(req.params.id).populate(); 
    if (user) {
        res.status(200).json(user); 
    }
    else{
        res.status(404).json({ message:"doctor not found"});
    }
});
/**
* @desc get settings by id
* @route /api/doctors/:id/settings
* @method get
* @access public 
*/
module.exports.getSettings=asyncHandler(async(req,res)=>{ 

const user = await Doctor.findById(req.params.id).populate(); 

if (user) {
    const Settings = user.notificationSettings;

    res.status(200).json(Settings); 
}
else{
    res.status(404).json({ message:"doctor not found"});
}
});
/**
* @desc    Update settings by user ID
* @route   /api/doctors/:id/setsetting
* @method  PUT
* @access  public
*/
module.exports.updateSettings = asyncHandler(async (req, res) => {
const userId = req.params.id;

const { reminderNotifications, messageNotifications, requestNotifications } = req.body;

const user = await Doctor.findById(userId);

if (user) {
  user.notificationSettings = {
   // reminders: reminderNotifications !== undefined ? reminderNotifications : user.notificationSettings.reminderNotifications,
    messages: messageNotifications !== undefined ? messageNotifications : user.notificationSettings.messageNotifications,
    requests: requestNotifications !== undefined ? requestNotifications : user.notificationSettings.requestNotifications,
  };

  await user.save();

  res.status(200).json({
    message: "Notification settings updated successfully",
    notificationSettings: user.notificationSettings,
  });
} else {
  res.status(404).json({ message: "Doctor not found" });
}
});
//////////admin
/**
 * @desc Search for doctors by name and get their statistics
 * @route /api/doctors/admin
 * @method GET
 * @access private (requires authentication)
 */
module.exports.searchDoctors = asyncHandler(async (req, res, next) => {
    try {
        const { name } = req.query;

        // Validate that name is provided
        if (!name) {
            return res.status(400).json({ message: "Name query parameter is required" });
        }

        // Search for doctors with names that match or partially match the query
        const doctors = await Doctor.find({
            fullName: { $regex: name, $options: 'i' } // Case-insensitive search
        }).select('fullName numberOfPatients averageRating numberOfReviews');

        // Return the matching doctors with their statistics
        res.status(200).json({
            message: "Doctors fetched successfully",
            doctors,
        });
    } catch (error) {
        next(error);
    }
});
/**
 * @desc Get statistics for a specific doctor by ID
 * @route /api/doctors/:id/stats
 * @method GET
 * @access private (requires authentication)
 */
module.exports.getDoctorStatsById = asyncHandler(async (req, res, next) => {
    try {
        const { doctorid } = req.params; // Get the doctor's ID from the URL parameter
        const { startDate, endDate } = req.query; // Get startDate and endDate from query parameters

        // Validate if the ID is provided
        if (!doctorid) {
            return res.status(400).json({ message: "Doctor ID is required" });
        }

        // Find the doctor by ID
        const doctor = await Doctor.findById(doctorid);

        // Check if the doctor exists
        if (!doctor) {
            return res.status(404).json({ message: "Doctor not found" });
        }

        // Build the filter for appointments if startDate and endDate are provided
        let appointmentFilter = {};
        if (startDate && endDate) {
            appointmentFilter = {
                date: {
                    $gte: new Date(startDate),
                    $lte: new Date(endDate),
                },
            };
        }

        // Count booked and available slots based on the filter
        const schedules = await DoctorSchedule.find({ doctorId: doctorid });

        let bookedSlots = 0;
        let availableSlots = 0;
        let appointmentCount = 0;

        schedules.forEach(schedule => {
            schedule.slots.forEach(slot => {
                // If a time frame is specified, filter by it
                if (appointmentFilter.date) {
                    // Assuming you have a property 'date' in the slot or schedule
                    if (new Date(slot.date) >= new Date(startDate) && new Date(slot.date) <= new Date(endDate)) {
                        if (slot.status === 'booked') {
                            bookedSlots++;
                        } else {
                            availableSlots++;
                        }
                    }
                } else {
                    // If no time frame, count all slots
                    if (slot.status === 'booked') {
                        bookedSlots++;
                    } else {
                        availableSlots++;
                    }
                }
            });
        });

        // Calculate the statistics
        const doctorStats = {
            patientCount: doctor.numberOfPatients,
            appointmentCount: bookedSlots, // Total booked slots
            availableSlotsCount: availableSlots, // Total available slots
            averageRating: doctor.averageRating,
            numberOfReviews: doctor.numberOfReviews,
            specialization: doctor.specialization,
        };

        // Return the doctor's statistics
        res.status(200).json({
            message: "Doctor statistics fetched successfully",
            statistics: doctorStats,
        });
    } catch (error) {
        next(error);
    }
});

/////////admin
/**
 * @desc Get the number of doctors by specialization within a date range
 * @route /api/doctors/stats/count
 * @method GET
 * @access public
 */
module.exports.getDoctorCountsBySpecialization = asyncHandler(async (req, res) => {
    try {
        // Get startDate and endDate from query params
        const { startDate, endDate } = req.query;

        // Convert the dates from string to Date object
        const start = startDate ? new Date(startDate) : new Date(0); // Default to 1970-01-01 if no start date
        const end = endDate ? new Date(endDate) : new Date(); // Default to the current date if no end date

        // Aggregate doctor counts by specialization within the given date range
        const doctorCounts = await Doctor.aggregate([
            {
                $match: {
                    role: 'doctor',
                    createdAt: { $gte: start, $lte: end } // Filter by created date within range
                }
            },
            {
                $group: {
                    _id: "$specialization", // Group by specialization
                    count: { $sum: 1 } // Count the number of doctors in each specialization
                }
            },
            {
                $project: {
                    specialization: "$_id", // Rename _id to specialization
                    count: 1,
                    _id: 0 // Remove _id from the output
                }
            }
        ]);

        // Send the response with the counts for each specialization
        res.status(200).json(doctorCounts);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Error fetching doctor counts by specialization" });
    }
});

/**
 * @desc Delete a user
 * @route /api/doctors/:id
 * @method DELETE
 * @access public
 */

module.exports.deleteDoctorById=asyncHandler(async(req,res)=>{ 
    console.log(req.params.id);
       
            const user= await Doctor.findByIdAndDelete(req.params.id) ;
            
            if(user){
            res.status(200).json({ message:"user has been deleted"});
        }
        else{
            res.status(404).json({ message:"user not found"});
        }
        });
        
/**
 * @desc Update doctpr by Admin
 * @route PUT /api/users/admin/update/:userid
 * @method PUT
 * @access Private (requires authentication)
 */
module.exports.updateDoctorbyAdmin = asyncHandler(async (req, res) => {
    const { fullName, email, phone, password,specialization,licenseNumber,workplacename,workplaceadress } = req.body;
///console.log(image);
    const user = await Doctor.findById(req.params.userid);

    if (!user) {
        return res.status(404).json({ message: "User not found" });
    }

    if (email && email !== user.email) {
        const emailExists = await Doctor.findOne({ email });
        if (emailExists) {
            return res.status(400).json({ message: "This email is already registered" });
        }
    }
    if (licenseNumber && licenseNumber !== user.licenseNumber) {
        const licenseNumberExists = await Doctor.findOne({ licenseNumber });
        if (licenseNumberExists) {
            return res.status(400).json({ message: "This licenseNumber is already registered" });
        }
    }

    if (phone && phone !== user.phone) {
        const phoneNumberExists = await Doctor.findOne({
            "phone": phone,
        });
        if (phoneNumberExists) {
            return res.status(400).json({ message: "This phone number is already registered" });
        }
    }
    const hashedPassword = await bcrypt.hash(req.body.password_hash, salt);

    if (fullName) user.fullName = fullName;
    if (email) user.email = email;
    if (phone) user.phone = phone;
    if (workplacename) user.workplace.name = workplacename;
    if (workplacename) user.workplace.address = workplaceadress;
    if (specialization) user.specialization = specialization;
    if (licenseNumber) user.licenseNumber = licenseNumber;

    if (password) user.password_hash = hashedPassword;

    try {
        await user.save();

        res.status(200).json({
            message: "User profile updated successfully",
            user: {
                username: user.fullName,
                email: user.email,
                phone: user.phone ,
                password_hash :user.password_hash ,
                workplacename:user.workplace.name,
                workplaceadress : user.workplace.address ,
               specialization:user.specialization ,
                licenseNumber: user.licenseNumber ,
            
            },
        });
    } catch (error) {
        console.error("Error updating profile:", error);
        res.status(500).json({ message: "There was an error updating the profile." });
    }
});


/**
 * @desc add a new doctor by admin
 * @route /api/doctors/addDoctor/admin
 * @method POST
 * @access public
 */
module.exports.AddDoctorByAdmin = asyncHandler(async (req, res, next) => {
    const { error } = validateCreateDoctor(req.body);
    console.log(req.body);
    if (error) {
        return res.status(400).json({ message: error.details[0].message });
    }

    let doctor = await Doctor.findOne({ email: req.body.email });
    if (doctor) {
        return res.status(400).json({ message: "This email is already registered" });
    }

    doctor = await Doctor.findOne({ licenseNumber: req.body.licenseNumber });
    if (doctor) {
        return res.status(400).json({ message: "This license number is already registered" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(req.body.password_hash, salt);

    doctor = new Doctor({
        fullName: req.body.fullName,
        email: req.body.email,
        password_hash: hashedPassword,
        phone: req.body.phone,
        specialization: req.body.specialization,
        licenseNumber: req.body.licenseNumber,
        workplace: {
            name: req.body.workplaceName,
            address: req.body.workplaceAddress || '',
        },
    });

    try {
        const result = await doctor.save();

      

        const token = doctor.generateToken();

        const { password_hash, ...other } = result._doc;

        res.status(201).json({
            ...other,
            token,
            message: "Doctor registered successfully."
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "There was an error registering the doctor" });
    }
});