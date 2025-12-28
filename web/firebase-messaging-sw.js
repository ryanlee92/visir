importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyD1kBy4mvHzhygq381ueCpe0Ydq8nJ9Xuw",
  authDomain: "fillin-cd65f.firebaseapp.com",
  projectId: "fillin-cd65f",
  storageBucket: "fillin-cd65f.appspot.com",
  messagingSenderId: "939046847033",
  appId: "1:939046847033:web:b90f4c7e9f7add8b4603e8",
  measurementId: "G-YPMWTYJZ2N",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
