const mongoose = require("mongoose");

function connectToDB(){
    mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("connected.."))
  .catch((error) => console.log("failed ", error));

}
module.exports = connectToDB ;