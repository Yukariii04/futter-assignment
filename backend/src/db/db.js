const mongoose=require('mongoose');

async function connectdb(){
    await mongoose.connect(process.env.MONGO_URI)
    console.log("connect to database")
}

module.exports=connectdb;