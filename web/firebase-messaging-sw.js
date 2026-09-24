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

// استقبال ومعالجة الإشعار عندما تكون اللوحة في الخلفية أو مغلقة (Background / Closed)
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message: ', payload);
  
  const notificationTitle = payload.notification?.title || payload.data?.title || 'إشعار من نظام دَربِي';
  const notificationBody = payload.notification?.body || payload.data?.body || payload.data?.message || '';

  const notificationOptions = {
    body: notificationBody,
    icon: '/favicon.png',
    badge: '/favicon.png',
    data: payload.data,
    vibrate: [200, 100, 200],
    requireInteraction: false
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// فتح وتركيز نافذة لوحة تحكم دَربِي فور النقر على الإشعار من الخلفية
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
