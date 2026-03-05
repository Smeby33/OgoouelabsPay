const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,  // Limite de connexions simultanées
    queueLimit: 0,
    acquireTimeout: 60000,
    timeout: 60000,
    // Éviter les connexions qui restent ouvertes
    idleTimeout: 300000,
    maxIdle: 10,
    // Configuration pour gérer les déconnexions
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
    // Retry automatique sur erreur de connexion
    connectTimeout: 60000
});

// Gestion des erreurs de pool
db.on('error', (err) => {
    console.error('❌ Erreur du pool MySQL:', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST' || err.code === 'ECONNRESET') {
        console.log('🔄 La connexion sera rétablie automatiquement par le pool');
    }
});

// Vérification de la connexion
(async () => {
    try {
        const connection = await db.getConnection();
        console.log('✅ Connexion MySQL réussie');
        connection.release(); // Libérer la connexion après vérification
    } catch (err) {
        console.error('❌ Erreur de connexion à la base de données:', err);
    }
})();

// Ping périodique pour maintenir la connexion active (toutes les 5 minutes)
setInterval(async () => {
    try {
        const connection = await db.getConnection();
        await connection.ping();
        connection.release();
        console.log('🏓 Ping MySQL réussi - connexion active');
    } catch (err) {
        console.error('⚠️ Erreur ping MySQL:', err.message);
    }
}, 300000); // 5 minutes

module.exports = db;
