importScripts('https://www.gstatic.com/firebasejs/10.3.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.3.0/firebase-messaging.js');

// Initialize Firebase
firebase.initializeApp({
  apiKey: "AIzaSyDGdj78Dpqa7YKTj3flLtewNRnTVUaJTiM",
  authDomain: "majd-726c9.firebaseapp.com",
  databaseURL: "https://majd-726c9-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "majd-726c9",
  storageBucket: "majd-726c9.appspot.com",
  messagingSenderId: "645330668025",
  appId: "1:645330668025:web:aae846640ed5ea31ab5528",
  measurementId: "G-2CC2LT453B",
  vapidKey: "BOaWKc1t4Xr-PGiHPOaiUPoNspxgHsv-a0EmXPknX0O07pTGKYl4YI85mn52sNCoVWWM7IfSMRsi55vTgLyg1EE"
});

// Retrieve an instance of Firebase Messaging so that it can handle background messages
const messaging = firebase.messaging();

// Background message handler
messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: payload.notification.icon,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
