// Import and configure the Firebase SDK
// These scripts are made available when the app is served or deployed on Firebase Hosting
// If you're using a different hosting service, you might need to use absolute URLs
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: 'AIzaSyCW2UHbPuVs8-jNKceA0u8AtqYYJQch--o',
  appId: '1:888609703277:web:06f72f3461c06c5a860664',
  messagingSenderId: '888609703277',
  projectId: 'sria-cashora',
  authDomain: 'sria-cashora.firebaseapp.com',
  storageBucket: 'sria-cashora.firebasestorage.app',
});

const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/favicon.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
