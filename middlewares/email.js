const { options } = require('joi');
const dotenv = require("dotenv");
const nodemailer = require('nodemailer');

/*

const sendEmail = async(option)=> {


    // create a transporter (serves that send the email)
    
    const transporter = nodemailer.createTransport({
        service:'sandbox.smtp.mailtrap.io',
        host: "sandbox.smtp.mailtrap.io",
        port: 2525,//587,
        secure: false, // true for port 465, false for other ports
        auth: {
          user: process.env.USER,
          pass: process.env.APP_PASSWORD,
        },
      });
    const emailOptions ={
    
        from: '"APP support " <support@gmail.com>', // sender address
        to: option.email, // list of receivers
        subject: option.subject, // Subject line
        text: option.message, // plain text body
    }
    await transporter.sendMail(emailOptions);
    }
    module.exports = sendEmail;
    USER=60998f13ad2b17
APP_PASSWORD=033eb73f2cc3b5
    
    */

const sendEmail = async(option) => {

    // create a transporter (serves that send the email)
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      host: "smtp.gmail.com",
      port: 587,
      secure: false, // true for port 465, false for other ports
      auth: {
        user: process.env.USER,
        pass: process.env.APP_PASSWORD,
      },
    });
  
    const emailOptions = {
      from: '"APP support " <support@gmail.com>', // sender address
      to: option.email, // list of receivers
      subject: option.subject, // Subject line
      text: option.message, // Corrected from 'messeage' to 'message' (plain text body)
    };
  
    await transporter.sendMail(emailOptions);
  };
  
  module.exports = sendEmail;
  