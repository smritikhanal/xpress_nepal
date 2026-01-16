const http = require('http');

const BASE_URL = 'http://localhost:3000';

// Helper function to make HTTP requests
const makeRequest = (method, path, data = null) => {
    return new Promise((resolve, reject) => {
        const url = new URL(path, BASE_URL);
        const options = {
            hostname: url.hostname,
            port: url.port,
            path: url.pathname,
            method: method,
            headers: {
                'Content-Type': 'application/json',
            }
        };

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    const response = JSON.parse(body);
                    resolve({ status: res.statusCode, data: response });
                } catch (e) {
                    resolve({ status: res.statusCode, data: body });
                }
            });
        });

        req.on('error', (error) => reject(error));

        if (data) {
            req.write(JSON.stringify(data));
        }
        req.end();
    });
};

// Test functions
const testRegister = async () => {
    console.log('\n📝 Testing Registration...');
    const testUser = {
        name: 'Test User ' + Date.now(),
        email: `testuser${Date.now()}@test.com`,
        phone: '9841000099',
        password: 'test123',
        role: 'customer'
    };

    try {
        const response = await makeRequest('POST', '/api/auth/register', testUser);
        console.log(`   Status: ${response.status}`);
        console.log(`   Success: ${response.data.success}`);
        console.log(`   Message: ${response.data.message}`);
        if (response.data.user) {
            console.log(`   User ID: ${response.data.user.id}`);
            console.log(`   Email: ${response.data.user.email}`);
        }
        if (response.data.token) {
            console.log(`   Token: ${response.data.token.substring(0, 30)}...`);
        }
        return response.data;
    } catch (error) {
        console.log(`   ❌ Error: ${error.message}`);
        return null;
    }
};

const testLogin = async (email, password) => {
    console.log('\n🔐 Testing Login...');
    try {
        const response = await makeRequest('POST', '/api/auth/login', { email, password });
        console.log(`   Status: ${response.status}`);
        console.log(`   Success: ${response.data.success}`);
        console.log(`   Message: ${response.data.message}`);
        if (response.data.user) {
            console.log(`   User: ${response.data.user.name || 'N/A'} (${response.data.user.email})`);
            console.log(`   Role: ${response.data.user.role}`);
        }
        if (response.data.token) {
            console.log(`   Token: ${response.data.token.substring(0, 30)}...`);
        }
        return response.data;
    } catch (error) {
        console.log(`   ❌ Error: ${error.message}`);
        return null;
    }
};

const testInvalidLogin = async () => {
    console.log('\n🚫 Testing Invalid Login...');
    try {
        const response = await makeRequest('POST', '/api/auth/login', {
            email: 'nonexistent@test.com',
            password: 'wrongpassword'
        });
        console.log(`   Status: ${response.status}`);
        console.log(`   Success: ${response.data.success}`);
        console.log(`   Message: ${response.data.message}`);
        return response.data;
    } catch (error) {
        console.log(`   ❌ Error: ${error.message}`);
        return null;
    }
};

const testDuplicateRegistration = async (email) => {
    console.log('\n🔄 Testing Duplicate Registration...');
    try {
        const response = await makeRequest('POST', '/api/auth/register', {
            name: 'Duplicate User',
            email: email,
            password: 'test123',
            role: 'customer'
        });
        console.log(`   Status: ${response.status}`);
        console.log(`   Success: ${response.data.success}`);
        console.log(`   Message: ${response.data.message}`);
        return response.data;
    } catch (error) {
        console.log(`   ❌ Error: ${error.message}`);
        return null;
    }
};

// Run all tests
const runTests = async () => {
    console.log('🧪 Starting API Tests');
    console.log('='.repeat(50));
    console.log(`Base URL: ${BASE_URL}`);
    
    try {
        // Test 1: Register a new user
        const registerResult = await testRegister();
        
        if (registerResult && registerResult.success) {
            // Test 2: Login with the registered user
            await testLogin(registerResult.user.email, 'test123');
            
            // Test 3: Try duplicate registration
            await testDuplicateRegistration(registerResult.user.email);
        }
        
        // Test 4: Login with seeded user (if seed-data.js was run)
        await testLogin('customer@test.com', 'customer123');
        
        // Test 5: Invalid login
        await testInvalidLogin();
        
        console.log('\n' + '='.repeat(50));
        console.log('✅ All tests completed!');
        
    } catch (error) {
        console.error('\n❌ Test suite error:', error.message);
    }
};

// Execute tests
runTests();
