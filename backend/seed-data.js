/**
 * Seed Data Script
 * Run: node seed-data.js
 * 
 * This script populates the database with initial test users
 */

require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');

const seedUsers = [
    {
        name: 'Admin User',
        email: 'admin@xpressnepal.com',
        phone: '9841000001',
        password: 'admin123',
        role: 'admin'
    },
    {
        name: 'Test Customer',
        email: 'customer@test.com',
        phone: '9841000002',
        password: 'customer123',
        role: 'customer'
    },
    {
        name: 'Test Vendor',
        email: 'vendor@test.com',
        phone: '9841000003',
        password: 'vendor123',
        role: 'vendor'
    },
    {
        name: 'John Doe',
        email: 'john@example.com',
        phone: '9841000004',
        password: 'john123',
        role: 'customer'
    },
    {
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '9841000005',
        password: 'jane123',
        role: 'customer'
    }
];

const seedDatabase = async () => {
    try {
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGO_URI);
        console.log('✅ MongoDB connected');

        // Clear existing users (optional - comment out if you want to keep existing users)
        await User.deleteMany({});
        console.log('🗑️  Cleared existing users');

        // Hash passwords and create users
        const usersToInsert = await Promise.all(
            seedUsers.map(async (user) => {
                const hashedPassword = await bcrypt.hash(user.password, 10);
                return {
                    ...user,
                    password: hashedPassword
                };
            })
        );

        // Insert users
        const createdUsers = await User.insertMany(usersToInsert);
        console.log(`✅ Created ${createdUsers.length} users:`);
        
        createdUsers.forEach((user) => {
            console.log(`   - ${user.name} (${user.email}) - Role: ${user.role}`);
        });

        console.log('\n📋 Test Credentials:');
        console.log('   Admin: admin@xpressnepal.com / admin123');
        console.log('   Customer: customer@test.com / customer123');
        console.log('   Vendor: vendor@test.com / vendor123');

        // Disconnect from MongoDB
        await mongoose.disconnect();
        console.log('\n✅ Database seeded successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error seeding database:', error.message);
        process.exit(1);
    }
};

// Run the seed function
seedDatabase();
