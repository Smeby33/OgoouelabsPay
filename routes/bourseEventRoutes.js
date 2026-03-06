const express = require('express');
const db = require('../db');
const rotaryEventsRoutes = require('./rotaryEventsRoutes');

const router = express.Router();

const SHAINA_EVENT_ID = process.env.SHAINA_EVENT_ID || 'EV-SHAINA-SMARTAPP-001';
const SHAINA_CATEGORY_BY_PACKAGE = {
    basic: 'CAT-SHAINA-BASIC',
    standard: 'CAT-SHAINA-STANDARD',
    premium: 'CAT-SHAINA-PREMIUM'
};

router.get('/config', (req, res) => {
    res.json({
        success: true,
        event_id: SHAINA_EVENT_ID,
        categories: SHAINA_CATEGORY_BY_PACKAGE
    });
});

router.get('/event', async (req, res) => {
    try {
        const [events] = await db.query(
            'SELECT * FROM rotary_evenements WHERE id = ? AND statut = ? LIMIT 1',
            [SHAINA_EVENT_ID, 'publie']
        );

        if (events.length === 0) {
            return res.status(404).json({
                success: false,
                error: `Evenement Shaina introuvable (${SHAINA_EVENT_ID})`
            });
        }

        const [categories] = await db.query(
            `SELECT
                id,
                nom_categorie,
                description,
                prix_unitaire,
                currency_code,
                quantite_disponible,
                quantite_vendue,
                (quantite_disponible - quantite_vendue) AS places_restantes,
                couleur_badge,
                avantages
             FROM rotary_billets_categories
             WHERE evenement_id = ?
               AND is_active = 1
             ORDER BY ordre_affichage ASC`,
            [SHAINA_EVENT_ID]
        );

        const packageByCategoryId = Object.entries(SHAINA_CATEGORY_BY_PACKAGE).reduce(
            (acc, [packageId, categoryId]) => {
                acc[categoryId] = packageId;
                return acc;
            },
            {}
        );

        res.json({
            success: true,
            event: events[0],
            categories: categories.map((cat) => ({
                ...cat,
                package_id: packageByCategoryId[cat.id] || null
            })),
            packages: SHAINA_CATEGORY_BY_PACKAGE
        });
    } catch (err) {
        console.error('[SHAINA][GET /event] Erreur:', err);
        res.status(500).json({
            success: false,
            error: 'Erreur lors de la recuperation de la configuration Shaina',
            details: err.message
        });
    }
});

// Reuse existing payment/ticket flow from Rotary routes.
router.use('/', rotaryEventsRoutes);

module.exports = router;
