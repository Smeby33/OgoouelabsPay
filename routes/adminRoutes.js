const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');

// Configuration JWT
const JWT_SECRET = process.env.JWT_SECRET || 'votre_secret_jwt_super_securise_2026';
const JWT_EXPIRES_IN = '24h';

// ==================== MIDDLEWARE D'AUTHENTIFICATION ====================
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Token manquant' });
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Token invalide ou expiré' });
        }
        req.user = user;
        next();
    });
};

// ==================== ROUTES PUBLIQUES ====================

// 🔐 Connexion administrateur
router.post('/login', async (req, res) => {
    console.log('\n🔐 ================================');
    console.log('🔐 [POST /admin/login] CONNEXION ADMIN');
    console.log('🔐 ================================');
    
    const { email, mot_de_passe } = req.body;
    
    console.log('📧 Email:', email);
    
    if (!email || !mot_de_passe) {
        return res.status(400).json({ 
            error: 'Email et mot de passe requis' 
        });
    }
    
    try {
        // Récupérer l'admin
        const [admins] = await db.query(
            'SELECT * FROM administrateurs WHERE email = ?',
            [email]
        );
        
        if (admins.length === 0) {
            console.log('❌ Admin non trouvé');
            return res.status(401).json({ 
                error: 'Email ou mot de passe incorrect' 
            });
        }
        
        const admin = admins[0];
        
        // Vérifier le mot de passe
        const passwordMatch = await bcrypt.compare(mot_de_passe, admin.mot_de_passe);
        
        if (!passwordMatch) {
            console.log('❌ Mot de passe incorrect');
            return res.status(401).json({ 
                error: 'Email ou mot de passe incorrect' 
            });
        }
        
        // Générer le token JWT
        const token = jwt.sign(
            { 
                id: admin.id, 
                email: admin.email,
                nom: admin.nom,
                prenom: admin.prenom
            },
            JWT_SECRET,
            { expiresIn: JWT_EXPIRES_IN }
        );
        
        console.log('✅ Connexion réussie pour:', admin.email);
        console.log('🔐 ================================\n');
        
        res.json({
            success: true,
            message: 'Connexion réussie',
            token,
            admin: {
                id: admin.id,
                email: admin.email,
                nom: admin.nom,
                prenom: admin.prenom
            }
        });
        
    } catch (err) {
        console.error('❌ Erreur login:', err);
        res.status(500).json({ 
            error: 'Erreur lors de la connexion',
            details: err.message 
        });
    }
});

// 🔐 Créer un nouveau compte admin (première fois seulement)
router.post('/register', async (req, res) => {
    console.log('\n🆕 [POST /admin/register] CRÉATION ADMIN');
    
    const { nom, prenom, email, mot_de_passe } = req.body;
    
    if (!nom || !prenom || !email || !mot_de_passe) {
        return res.status(400).json({ 
            error: 'Tous les champs sont requis' 
        });
    }
    
    try {
        // Vérifier si l'email existe déjà
        const [existing] = await db.query(
            'SELECT id FROM administrateurs WHERE email = ?',
            [email]
        );
        
        if (existing.length > 0) {
            return res.status(400).json({ 
                error: 'Cet email est déjà utilisé' 
            });
        }
        
        // Hasher le mot de passe
        const hashedPassword = await bcrypt.hash(mot_de_passe, 10);
        
        // Créer l'admin
        await db.query(
            'INSERT INTO administrateurs (nom, prenom, email, mot_de_passe) VALUES (?, ?, ?, ?)',
            [nom, prenom, email, hashedPassword]
        );
        
        console.log('✅ Admin créé:', email);
        
        res.status(201).json({
            success: true,
            message: 'Compte administrateur créé avec succès'
        });
        
    } catch (err) {
        console.error('❌ Erreur création admin:', err);
        res.status(500).json({ 
            error: 'Erreur lors de la création du compte',
            details: err.message 
        });
    }
});

// ==================== ROUTES PROTÉGÉES ====================

// 📊 Dashboard - Statistiques générales
router.get('/dashboard', authenticateToken, async (req, res) => {
    console.log('📊 [GET /admin/dashboard] Chargement dashboard');
    
    try {
        // Total événements
        const [eventsCount] = await db.query(
            'SELECT COUNT(*) as total FROM rotary_evenements'
        );
        
        // Total billets vendus
        const [ticketsCount] = await db.query(
            'SELECT COUNT(*) as total FROM rotary_billets WHERE statut_paiement = "paye"'
        );
        
        // Revenus totaux
        const [revenue] = await db.query(
            'SELECT SUM(montant_total) as total FROM rotary_billets WHERE statut_paiement = "paye"'
        );
        
        // Transactions en attente
        const [pendingTransactions] = await db.query(
            'SELECT COUNT(*) as total FROM rotary_transactions WHERE statut = "pending"'
        );
        
        // Derniers billets vendus
        const [recentTickets] = await db.query(`
            SELECT 
                b.reference_billet,
                b.prenom,
                b.nom,
                b.email,
                b.montant_total,
                b.created_at,
                e.titre as evenement_titre,
                c.nom_categorie
            FROM rotary_billets b
            INNER JOIN rotary_evenements e ON b.evenement_id = e.id
            INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
            WHERE b.statut_paiement = 'paye'
            ORDER BY b.created_at DESC
            LIMIT 10
        `);
        
        res.json({
            success: true,
            stats: {
                total_evenements: eventsCount[0].total,
                total_billets_vendus: ticketsCount[0].total,
                revenus_totaux: revenue[0].total || 0,
                transactions_en_attente: pendingTransactions[0].total
            },
            recent_tickets: recentTickets
        });
        
    } catch (err) {
        console.error('❌ Erreur dashboard:', err);
        res.status(500).json({ 
            error: 'Erreur lors du chargement du dashboard',
            details: err.message 
        });
    }
});

// 📋 Liste tous les événements (admin)
router.get('/events', authenticateToken, async (req, res) => {
    console.log('📋 [GET /admin/events] Liste événements');
    
    try {
        const [events] = await db.query(`
            SELECT 
                e.*,
                (SELECT COUNT(*) FROM rotary_billets b WHERE b.evenement_id = e.id AND b.statut_paiement = 'paye') as billets_vendus,
                (SELECT SUM(b.montant_total) FROM rotary_billets b WHERE b.evenement_id = e.id AND b.statut_paiement = 'paye') as revenus
            FROM rotary_evenements e
            ORDER BY e.date_evenement DESC
        `);
        
        res.json({ success: true, events });
        
    } catch (err) {
        console.error('❌ Erreur liste événements:', err);
        res.status(500).json({ error: 'Erreur serveur', details: err.message });
    }
});

// 🎫 Liste tous les billets
router.get('/tickets', authenticateToken, async (req, res) => {
    const { evenement_id, statut } = req.query;
    console.log('🎫 [GET /admin/tickets] Liste billets');
    
    try {
        let query = `
            SELECT 
                b.*,
                e.titre as evenement_titre,
                c.nom_categorie,
                t.statut as transaction_statut
            FROM rotary_billets b
            INNER JOIN rotary_evenements e ON b.evenement_id = e.id
            INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
            LEFT JOIN rotary_transactions t ON b.id = t.billet_id
            WHERE 1=1
        `;
        
        const params = [];
        if (evenement_id) {
            query += ' AND b.evenement_id = ?';
            params.push(evenement_id);
        }
        if (statut) {
            query += ' AND b.statut_paiement = ?';
            params.push(statut);
        }
        
        query += ' ORDER BY b.created_at DESC';
        
        const [tickets] = await db.query(query, params);
        
        res.json({ success: true, tickets });
        
    } catch (err) {
        console.error('❌ Erreur liste billets:', err);
        res.status(500).json({ error: 'Erreur serveur', details: err.message });
    }
});

// 💳 Liste toutes les transactions
router.get('/transactions', authenticateToken, async (req, res) => {
    console.log('💳 [GET /admin/transactions] Liste transactions');
    
    try {
        const [transactions] = await db.query(`
            SELECT 
                t.*,
                b.reference_billet,
                b.prenom,
                b.nom,
                b.email,
                e.titre as evenement_titre
            FROM rotary_transactions t
            INNER JOIN rotary_billets b ON t.billet_id = b.id
            INNER JOIN rotary_evenements e ON t.evenement_id = e.id
            ORDER BY t.created_at DESC
        `);
        
        res.json({ success: true, transactions });
        
    } catch (err) {
        console.error('❌ Erreur liste transactions:', err);
        res.status(500).json({ error: 'Erreur serveur', details: err.message });
    }
});

// 📧 Historique des emails envoyés
router.get('/emails', authenticateToken, async (req, res) => {
    console.log('📧 [GET /admin/emails] Historique emails');
    
    try {
        const [emails] = await db.query(`
            SELECT 
                e.*,
                b.reference_billet,
                b.prenom,
                b.nom
            FROM rotary_email_logs e
            LEFT JOIN rotary_billets b ON e.billet_id = b.id
            ORDER BY e.created_at DESC
            LIMIT 100
        `);
        
        res.json({ success: true, emails });
        
    } catch (err) {
        console.error('❌ Erreur historique emails:', err);
        res.status(500).json({ error: 'Erreur serveur', details: err.message });
    }
});

// 🔍 Rechercher un billet par référence
router.get('/tickets/search/:reference', authenticateToken, async (req, res) => {
    const { reference } = req.params;
    console.log('🔍 Recherche billet:', reference);
    
    try {
        const [tickets] = await db.query(`
            SELECT 
                b.*,
                e.titre as evenement_titre,
                e.date_evenement,
                e.lieu,
                c.nom_categorie,
                t.statut as transaction_statut,
                t.payment_method
            FROM rotary_billets b
            INNER JOIN rotary_evenements e ON b.evenement_id = e.id
            INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
            LEFT JOIN rotary_transactions t ON b.id = t.billet_id
            WHERE b.reference_billet = ?
        `, [reference]);
        
        if (tickets.length === 0) {
            return res.status(404).json({ error: 'Billet non trouvé' });
        }
        
        res.json({ success: true, ticket: tickets[0] });
        
    } catch (err) {
        console.error('❌ Erreur recherche billet:', err);
        res.status(500).json({ error: 'Erreur serveur', details: err.message });
    }
});

module.exports = router;
