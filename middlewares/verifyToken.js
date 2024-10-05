const jwt = require("jsonwebtoken");

// verify Token

function verifyToken(req,res,next) {
const token = req.headers.token;
if(token){
try {
   const decoded = jwt.verify(token,process.env.JWT_SECRET_KEY);
    req.user= decoded;
    next();
}
catch (error){
    res.status(401).json({message:"invalid token"});
}
}
else{
    res.status(401).json({message: "no token provided"});
}

}


//verifyToken & Authorized user
function verifyTokenAndAuthorization(req,res,next){
    verifyToken(req,res,()=>{
        if(req.user.id === req.params.id || req.user.isAdmin) {

            next(); 
            
        } 
        else {
            return res.status(403).json({ message: "you are not allowed" });
        }
    }) 

}


//verifyToken & Admin
function verifyTokenAndAdmin(req, res, next){
    verifyToken(req,res, () => {
        if( req.user.isAdmin){

            next(); 
            
        } 
        else {
//console.log( req.user.isAdmin );
            return res.status(403).json({ message: "you are not allowed , only Admin is allow" });
        }
    }) 

}




module.exports={
    verifyToken,
  verifyTokenAndAuthorization ,
    verifyTokenAndAdmin
}