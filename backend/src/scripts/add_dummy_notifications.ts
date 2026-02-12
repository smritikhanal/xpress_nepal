import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from '../models/User.js';
import Notification from '../models/Notification.js';

// Load environment variables
dotenv.config();

const addDummyNotifications = async () => {
    try {
        // Connect to Database
        if (!process.env.MONGODB_URI) {
            console.error('MONGODB_URI is not defined in environment variables');
            process.exit(1);
        }

        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        // Find the user
        const email = 'customer@gmail.com';
        const user = await User.findOne({ email });

        if (!user) {
            console.error(`User with email ${email} not found`);
            process.exit(1);
        }

        console.log(`Found user: ${user.name} (${user._id})`);

        // Dummy notifications data
        const notifications = [
            {
                userId: user._id,
                title: 'Welcome to Xpress Nepal!',
                message: 'Thank you for joining our platform. We are excited to have you here.',
                type: 'general',
                isRead: false,
                createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 2) // 2 days ago
            },
            {
                userId: user._id,
                title: 'Order Shipped',
                message: 'Your order #ORD-12345 has been shipped and is on its way.',
                type: 'order_shipped',
                isRead: false,
                createdAt: new Date(Date.now() - 1000 * 60 * 60 * 5) // 5 hours ago
            },
            {
                userId: user._id,
                title: 'Order Delivered',
                message: 'Your order #ORD-98765 has been delivered successfully. Enjoy your purchase!',
                type: 'order_delivered',
                isRead: true,
                createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 5) // 5 days ago
            },
            {
                userId: user._id,
                title: 'Flash Sale Alert!',
                message: 'Big discounts on electronics starting tomorrow. Don\'t miss out!',
                type: 'general',
                isRead: false,
                createdAt: new Date() // Just now
            }
        ];

        // Insert notifications
        await Notification.insertMany(notifications);
        console.log(`Successfully added ${notifications.length} dummy notifications for ${email}`);

    } catch (error) {
        console.error('Error adding dummy notifications:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Disconnected from MongoDB');
        process.exit(0);
    }
};

addDummyNotifications();
