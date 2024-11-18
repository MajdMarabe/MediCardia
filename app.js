const express = require("express");
//const dotenv = require("dotenv");

//const usersPath =require("./routes/users");///for every route
const logger = require("./middlewares/logger");
const bodyParser = require('body-parser');

const connectToDB=require("./config/db");
require("dotenv").config();

///conn to db
connectToDB();
// init app
const app = express();
//apply middlewares
app.use(express.json({ limit: '10mb' }));//json
app.use(logger);
app.use(express.urlencoded({ limit: '10mb', extended: true })); // For URL-encoded data


//routes

app.use("/api/users",require("./routes/users"))
app.use("/api/drugs",require("./routes/drugs"))

///

////
const port = process.env.PORT || 5001;
app.listen(port, '0.0.0.0', () =>
  console.log(
    `Server is running in ${process.env.NODE_ENV} mode on port ${port}`
  )
);


  