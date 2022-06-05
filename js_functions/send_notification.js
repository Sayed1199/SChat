

var registerationToken = 'c1U8MHDaSwejtNNCGX3ggJ:APA91bEJg9BTjQUcVIEUfQdx0-1oqb4rSgvzhoYSrC1W9WDChvpBbznwFMGcEzhSN7t2mPzjSOLfBIm5T7RkEFADStsofrCgXlTmS3cT9fFGgY5d__sqY2bSNG7FSqiNON2HNJoTE-4Z';



var admin = require("firebase-admin");

var serviceAccount = require("D:\\AndroidStoreProjects\\schat\\schat-a5874-firebase-adminsdk-zkgjm-d612a96f10.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});



var message={

    data: {
        
        'title':'sample notification',
        'body':'test background notification....'

    },
    token: registerationToken

};



admin.messaging().send(message).then((response) => {
        console.log('successfully sent a msg',response);
        }).catch((error)=>{
            console.log('error sending a msg',error);
        });

























