const { options } = require('joi');
const dotenv = require("dotenv");
const nodemailer = require('nodemailer');

const sendEmail = async (option) => {
  // إعداد النقل
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    host: "smtp.gmail.com",
    port: 587,
    secure: false,
    auth: {
      user: process.env.USER,
      pass: process.env.APP_PASSWORD,
    },
  });

  const emailHTML = `
    <html>
      <head>
        <style>
          body {
            font-family: 'Poppins', Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f2f3f8;
            color: #333333;
          }
          .email-wrapper {
            max-width: 600px;
            margin: 20px auto;
            background: linear-gradient(to right, #613089, #8b49d6);
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
          }
          .email-container {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 20px;
          }
          .email-header {
            text-align: center;
            margin-bottom: 20px;
          }
          .email-header h1 {
            color: #613089;
            font-size: 24px;
            margin: 0;
          }
          .email-header img {
            width: 120px;
            margin: 10px 0;
          }
          .email-content {
            font-size: 16px;
            line-height: 1.8;
            color: #555555;
          }
          .verification-code {
            display: inline-block;
            background-color: #f7f7f7;
            color: #613089;
            font-size: 28px;
            font-weight: bold;
            padding: 10px 20px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
          }
          .footer {
            text-align: center;
            font-size: 12px;
            color: #888888;
            margin-top: 20px;
          }
          .footer a {
            color: #613089;
            text-decoration: none;
          }
        </style>
      </head>
      <body>
        <div class="email-wrapper">
          <div class="email-container">
            <div class="email-header">
              <h1>Welcome to MediCardia</h1>
            </div>
            <div class="email-content">
              <p>Hello,</p>
              <p>Thank you for joining MediCardia! To verify your email address, please use the verification code below.  This code is valid for <strong>10 minutes</strong>.</p>
           <p style="font-size: 16px; color: #555; line-height: 1.8; text-align: center;">
  <span style="
    font-size: 24px; 
    font-weight: bold; 
    color: #ffffff; 
    background: linear-gradient(90deg, #8b49d6, #613089); 
    padding: 5px 10px; 
    border-radius: 8px; 
    display: inline-block; 
    margin: 5px 0;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
  ">
    ${option.message}
  </span>
  <br />
  


           
            </div>
          </div>
       
        </div>
      </body>
    </html>
  `;

  const emailOptions = {
    from: '"MediCardia" <medicardia@gmail.com>',
    to: option.email,
    subject: option.subject,
    html: emailHTML,
  };

  try {
    await transporter.sendMail(emailOptions);
    console.log('Email sent successfully');
  } catch (error) {
    console.error('Error sending email:', error);
  }
};

module.exports = sendEmail;
