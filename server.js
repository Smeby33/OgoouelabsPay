const express = require('express');
const app = express();
const cors = require('cors');
const dotenv = require('dotenv');
const db = require('./db');
const emailRoutes = require('./routes/emailRoutes');
const rotaryEventsRoutes = require('./routes/rotaryEventsRoutes');
const weddingEventRoutes = require('./routes/weddingEventRoutes');
const shainaEventRoutes = require('./routes/shainaEventRoutes');
const brocanteEventsRoutes = require('./routes/brocanteEventsRoute');
const adminRoutes = require('./routes/adminRoutes');

dotenv.config();

app.use((req, res, next) => {
    console.log(`Nouvelle requete: ${req.method} ${req.url}`);
    next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
    if (req.url.includes('/updateFactureStatus')) {
        console.log('[DIAGNOSTIC] Route updateFactureStatus detectee');
        console.log('Body apres parsing:', JSON.stringify(req.body, null, 2));
        console.log('Keys disponibles:', Object.keys(req.body));
    }
    next();
});

const corsOrigins = [
    'http://localhost:5174',
    'http://localhost:5173',
    'https://alouk.afup-tech.com',
    'https://shaina-smart-app.afup-tech.com',
    'https://africa-brocante.vercel.app',
    'https://rotary-port-gentil-65th-anniversary.vercel.app',
    'https://www.portaileventogoouelabs.online',
    'https://portaileventogoouelabs.online',
    'https://simu.billing-easy.net',
    'https://lab.billing-easy.net'
];

if (process.env.SHAINA_FRONTEND_URL) {
    corsOrigins.push(process.env.SHAINA_FRONTEND_URL);
}

app.use(cors({ origin: corsOrigins }));

// Routes
app.use('/emails', emailRoutes);
app.use('/notifications', emailRoutes);
app.use('/rotary', rotaryEventsRoutes);
app.use('/weddin', weddingEventRoutes);
app.use('/shaina', shainaEventRoutes);
app.use('/brocante', brocanteEventsRoutes);
app.use('/admin', adminRoutes);

app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        routes: {
            emails: '/emails',
            notifications: '/notifications',
            rotary: '/rotary',
            wedding: '/weddin/wedding/deliveries/site-link',
            shaina: '/shaina',
            brocante: '/brocante',
            admin: '/admin'
        }
    });
});

app.get('/routes', (req, res) => {
    const routes = [];
    app._router.stack.forEach((middleware) => {
        if (middleware.route) {
            routes.push({
                path: middleware.route.path,
                methods: Object.keys(middleware.route.methods)
            });
        } else if (middleware.name === 'router') {
            middleware.handle.stack.forEach((handler) => {
                if (handler.route) {
                    const path = middleware.regexp.source
                        .replace('\\/?', '')
                        .replace('(?=\\/|$)', '')
                        .replace(/\\\//g, '/');
                    routes.push({
                        path: path + handler.route.path,
                        methods: Object.keys(handler.route.methods)
                    });
                }
            });
        }
    });
    res.json({ success: true, routes });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Serveur demarre sur http://localhost:${PORT}`);
});
