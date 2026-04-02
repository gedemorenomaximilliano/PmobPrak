const { testConnection } = require('./config/database');

async function test() {
    console.log('Testing database connection...');
    const connected = await testConnection();
    
    if (connected) {
        console.log('✅ Success! Ready to start the API server');
        console.log('Run: npm run dev');
    } else {
        console.log('❌ Please check your database credentials in .env file');
    }
}

test();