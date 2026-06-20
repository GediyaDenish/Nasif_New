import admin from 'firebase-admin';
import serviceAccount from '../env/nasif-6de4b-firebase-adminsdk-fbsvc-7ce6be2ad6.json';

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

export default admin;