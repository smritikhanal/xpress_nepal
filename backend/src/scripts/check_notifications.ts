import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Notification from '../models/Notification.js';

dotenv.config();

const checkNotifications = async () => {
    try {
        if (!process.env.MONGODB_URI) {
            console.error('MONGODB_URI is not defined');
            process.exit(1);
        }

        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        const notifications = await Notification.find({}).sort({ createdAt: -1 });
        console.log(`\nTotal notifications in database: ${notifications.length}`);
        
        if (notifications.length > 0) {
            console.log('\nNotifications:');
            notifications.forEach((notif, index) => {
                console.log(`\n${index + 1}. ${notif.title}`);
                console.log(`   User ID: ${notif.userId}`);
                console.log(`   Message: ${notif.message}`);
                console.log(`   Type: ${notif.type}`);
                console.log(`   Read: ${notif.isRead}`);
                console.log(`   Created: ${notif.createdAt}`);
            });
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await mongoose.disconnect();
        process.exit(0);
    }
};

checkNotifications();
