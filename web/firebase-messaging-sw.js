importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDiTBvIn7NofN026K_JLAdyL_XgEb6iylY",
  authDomain: "darpy-a247d.firebaseapp.com",
  projectId: "darpy-a247d",
  storageBucket: "darpy-a247d.firebasestorage.app",
  messagingSenderId: "745946017392",
  appId: "1:745946017392:web:fe4914a2eb42bcf9cf8eb5"
});

const messaging = firebase.messaging();

// استقبال ومعالجة الإشعار عندما تكون اللوحة في الخلفية أو مغلقة
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message: ', payload);
  
  const notificationTitle = payload.notification?.title || 'إشعار من نظام دربي';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/favicon.png',
    data: payload.data,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
