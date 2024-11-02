const express = require("express");
//const dotenv = require("dotenv");

//const usersPath =require("./routes/users");///for every route
const logger = require("./middlewares/logger");
const connectToDB=require("./config/db");
require("dotenv").config();

///conn to db
connectToDB();
// init app
const app = express();
//apply middlewares
app.use(express.json());//json
app.use(logger);

//routes

app.use("/api/users",require("./routes/users"))
app.use("/api/drugs",require("./routes/drugs"))

///

////
const port = process.env.PORT || 5000;
app.listen(port, () =>
  console.log(
    `Server is running in ${process.env.NODE_ENV} mode on port ${port}`
  )
);

  