const express = require('express');
const router = express.Router();
const axios = require('axios');
const db = require('../db');
const crypto = require('crypto');
const QRCode = require('qrcode');
const nodemailer = require('nodemailer');

// 🔍 Middleware pour capturer les données brutes
router.use(express.json());
router.use(express.urlencoded({ extended: true }));

// Middleware de diagnostic
router.use((req, res, next) => {
    console.log('\n🎫 [BROCANTE] ==================');
    console.log('📍 URL:', req.url);
    console.log('📍 Méthode:', req.method);
    console.log('📦 Body:', req.body);
    console.log('🎫 [BROCANTE] ==================\n');
    next();
});

// ==================== CONFIGURATION EBILLING ====================
// 🎯 IMPORTANT: Deux URL différentes pour Ebilling
// 1️⃣ API (Backend) - POUR CREER LA FACTURE SEULEMENT:
const EBILLING_URL = 'https://lab.billing-easy.net/api/v1/merchant/e_bills';
// ⚠️ Cette URL n'est utilisée QUE pour créer la facture (POST /tickets/create)
// Elle retourne un bill_id que le frontend utilisera pour redirection

// 2️⃣ PORTAIL (Frontend) - POUR LA REDIRECTION UTILISATEUR:
// https://test.billing-easy.net?invoice={bill_id}&redirect_url={return_url}
// Ce lien est construit dans le frontend React (brocante.md)
// ⚠️ NE JAMAIS utiliser EBILLING_URL pour la redirection utilisateur

const EBILLING_USERNAME ='afup';
const EBILLING_SHARED_KEY ='b3b8814e-4639-46a1-97c3-bf37401dc54b';
const EB_CALLBACK_URL = process.env.EB_CALLBACK_URL || 'https://fwwm7ch7se.us-east-1.awsapprunner.com/brocante/webhook';
const FRONTEND_URL = process.env.FRONTEND_URL || 'https://africa-brocante.vercel.app';

// Event constant for brocante
const EVENT_ID = process.env.BROCANTE_EVENT_ID || 'EV-BROCANTE-2026-001';
const BROCANTE_STAND_CATEGORIE_ID = process.env.BROCANTE_STAND_CATEGORIE_ID || null;

// Configuration email
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,   
        pass: process.env.EMAIL_PASS
    }
});

// ==================== UTILITAIRES ====================
function generateId(prefix = 'ID') {
    return `${prefix}-${Date.now()}-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
}

function generateTicketRef() {
    const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const random = crypto.randomBytes(3).toString('hex').toUpperCase();
    return `BIL-${date}-${random}`;
}

function generatePaymentRef() {
    const random = crypto.randomBytes(6).toString('hex').toUpperCase();
    return `REF-BROCANTE-${random}`;
}

function normalizeNotesParticipant(value) {
    if (typeof value !== 'string') return null;

    const normalized = value
        .replace(/\r\n/g, '\n')
        .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, '')
        .replace(/\n{3,}/g, '\n\n')
        .trim();

    return normalized || null;
}

function maskEmail(email) {
    if (!email || typeof email !== 'string' || !email.includes('@')) return email || null;
    const [local, domain] = email.split('@');
    if (!local) return `***@${domain}`;
    return `${local.slice(0, 2)}***@${domain}`;
}

function maskPhone(phone) {
    if (!phone || typeof phone !== 'string') return phone || null;
    const cleaned = phone.replace(/\s+/g, '');
    if (cleaned.length <= 4) return '****';
    return `${cleaned.slice(0, 2)}****${cleaned.slice(-2)}`;
}

function normalizePhoneForSearch(phone) {
    if (!phone || typeof phone !== 'string') return null;
    return phone
        .trim()
        .replace(/[\s+\-()]/g, '');
}

function logTicketStep(requestId, step, details = null) {
    const prefix = `🎫 [BROCANTE][${requestId}] ${step}`;
    if (details) {
        console.log(prefix, details);
        return;
    }
    console.log(prefix);
}

function maskSecret(secret) {
    if (!secret || typeof secret !== 'string') return null;
    if (secret.length <= 6) return '***';
    return `${secret.slice(0, 3)}***${secret.slice(-3)}`;
}

async function generateQRCodeBase64(data) {
    try {
        const qrCodeDataURL = await QRCode.toDataURL(data, {
            errorCorrectionLevel: 'H',
            type: 'image/png',
            width: 300,
            margin: 2
        });
        return qrCodeDataURL;
    } catch (err) {
        console.error('❌ Erreur génération QR code:', err);
        return null;
    }
}

function escapeHtml(value) {
    if (value === null || value === undefined) return '';
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function formatDateTimeFr(value) {
    if (!value) return 'Non renseigne';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return 'Non renseigne';
    return date.toLocaleString('fr-FR', {
        day: '2-digit',
        month: 'long',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function formatMoney(value, currency = 'XAF') {
    const amount = Number.parseFloat(value);
    if (!Number.isFinite(amount)) return `0 ${currency}`;
    return `${amount.toLocaleString('fr-FR')} ${currency}`;
}

function buildClientTicketEmailHtml(billetData, eventData) {
    const fullName = `${billetData.prenom || ''} ${billetData.nom || ''}`.trim() || 'Participant';
    const eventTitle = escapeHtml(eventData.titre || 'Brocante');
    const eventDate = escapeHtml(formatDateTimeFr(eventData.date_evenement));
    const eventLocation = escapeHtml(eventData.lieu || 'Lieu a confirmer');
    const reference = escapeHtml(billetData.reference_billet || '-');
    const category = escapeHtml(billetData.nom_categorie || 'Stand');
    const quantity = escapeHtml(billetData.quantite || 1);
    const total = escapeHtml(formatMoney(billetData.montant_total, billetData.currency_code || 'XAF'));

    return `
        <div style="margin:0;padding:0;background:#f5f7fb;font-family:Arial,sans-serif;color:#1f2937;">
            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="padding:24px 0;background:#f5f7fb;">
                <tr><td align="center">
                    <table role="presentation" width="640" cellspacing="0" cellpadding="0" style="max-width:640px;background:#ffffff;border:1px solid #e5e7eb;border-radius:14px;overflow:hidden;">
                        <tr><td style="padding:26px 30px;background:#0f766e;color:#ffffff;">
                            <h1 style="margin:0;font-size:24px;line-height:1.25;">Billet confirme</h1>
                            <p style="margin:8px 0 0 0;font-size:14px;opacity:0.95;">Votre inscription est confirmee. Conservez ce message pour le jour J.</p>
                        </td></tr>
                        <tr><td style="padding:26px 30px;">
                            <p style="margin:0 0 12px 0;font-size:15px;">Bonjour <strong>${escapeHtml(fullName)}</strong>,</p>
                            <p style="margin:0 0 18px 0;font-size:14px;color:#4b5563;">Voici le recapitulatif de votre reservation Brocante :</p>
                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="border:1px solid #e5e7eb;background:#f8fafc;border-radius:10px;">
                                <tr><td style="padding:11px 12px;font-size:13px;color:#6b7280;width:40%;">Reference billet</td><td style="padding:11px 12px;font-size:14px;font-weight:700;">${reference}</td></tr>
                                <tr><td style="padding:11px 12px;font-size:13px;color:#6b7280;">Evenement</td><td style="padding:11px 12px;font-size:14px;">${eventTitle}</td></tr>
                                <tr><td style="padding:11px 12px;font-size:13px;color:#6b7280;">Date</td><td style="padding:11px 12px;font-size:14px;">${eventDate}</td></tr>
                                <tr><td style="padding:11px 12px;font-size:13px;color:#6b7280;">Lieu</td><td style="padding:11px 12px;font-size:14px;">${eventLocation}</td></tr>
                                <tr><td style="padding:11px 12px;font-size:13px;color:#6b7280;">Categorie</td><td style="padding:11px 12px;font-size:14px;">${category}</td></tr>
                                <tr><td style="padding:11px 12px;font-size:13px;color:#6b7280;">Quantite</td><td style="padding:11px 12px;font-size:14px;">${quantity}</td></tr>
                                <tr><td style="padding:11px 12px;font-size:13px;color:#6b7280;">Montant total</td><td style="padding:11px 12px;font-size:14px;font-weight:700;color:#0f766e;">${total}</td></tr>
                            </table>
                            <div style="margin-top:18px;padding:14px;border-left:4px solid #0f766e;background:#ecfeff;border-radius:10px;">
                                <p style="margin:0;font-size:13px;color:#0f172a;">Statut: <strong>Paiement confirme</strong></p>
                                <p style="margin:6px 0 0 0;font-size:12px;color:#475569;">Presentez votre QR code a l'accueil pour verification.</p>
                            </div>
                            <div style="margin-top:20px;padding:16px;border:1px dashed #cbd5e1;border-radius:10px;text-align:center;">
                                <p style="margin:0 0 10px 0;font-size:13px;color:#6b7280;">QR code de verification</p>
                                <img src="cid:qrcode" alt="QR code billet" style="display:inline-block;width:180px;height:180px;" />
                                <p style="margin:10px 0 0 0;font-size:12px;color:#6b7280;">Si l'image n'apparait pas, affichez ce message a l'entree.</p>
                            </div>
                            <p style="margin:18px 0 0 0;font-size:12px;color:#6b7280;">Besoin d'aide ? Repondez a cet email.</p>
                        </td></tr>
                        <tr><td style="padding:14px 30px;background:#f9fafb;border-top:1px solid #e5e7eb;font-size:12px;color:#6b7280;">Brocante - Billetterie en ligne | Reference: ${reference}</td></tr>
                    </table>
                </td></tr>
            </table>
        </div>
    `;
}

function buildAdminNotificationHtml(type, billetData, eventData) {
    const label = type === 'payment_received' ? 'Paiement recu' : `Notification: ${escapeHtml(type)}`;
    const reference = escapeHtml(billetData.reference_billet || '-');
    const eventTitle = escapeHtml(eventData.titre || billetData.evenement_titre || 'Brocante');
    const fullName = escapeHtml(`${billetData.prenom || ''} ${billetData.nom || ''}`.trim() || billetData.payer_name || 'Client');
    const email = escapeHtml(billetData.email || billetData.payer_email || '-');
    const phone = escapeHtml(billetData.telephone || billetData.payer_msisdn || '-');
    const quantity = escapeHtml(billetData.quantite || 1);
    const amount = escapeHtml(formatMoney(billetData.montant_total || billetData.montant, billetData.currency_code || 'XAF'));
    const eventDate = escapeHtml(formatDateTimeFr(eventData.date_evenement || billetData.date_evenement));
    const eventLocation = escapeHtml(eventData.lieu || billetData.lieu || 'Lieu a confirmer');

    return `
        <div style="margin:0;padding:0;background:#f3f4f6;font-family:Arial,sans-serif;color:#111827;">
            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="padding:20px 0;">
                <tr><td align="center">
                    <table role="presentation" width="620" cellspacing="0" cellpadding="0" style="max-width:620px;background:#ffffff;border:1px solid #e5e7eb;border-radius:12px;overflow:hidden;">
                        <tr><td style="padding:20px 24px;background:#111827;color:#ffffff;">
                            <h2 style="margin:0;font-size:20px;">${label}</h2>
                            <p style="margin:6px 0 0 0;font-size:12px;opacity:0.9;">Reference: ${reference}</p>
                        </td></tr>
                        <tr><td style="padding:20px 24px;">
                            <div style="margin:0 0 16px 0;padding:12px 14px;background:#f8fafc;border:1px solid #e5e7eb;border-radius:10px;">
                                <p style="margin:0;font-size:12px;color:#6b7280;">Evenement</p>
                                <p style="margin:4px 0 0 0;font-size:15px;font-weight:700;">${eventTitle}</p>
                            </div>
                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="border-collapse:collapse;">
                                <tr><td style="padding:8px 0;color:#6b7280;font-size:13px;width:40%;">Reference billet</td><td style="padding:8px 0;font-size:14px;font-weight:700;">${reference}</td></tr>
                                <tr><td style="padding:8px 0;color:#6b7280;font-size:13px;">Client</td><td style="padding:8px 0;font-size:14px;">${fullName}</td></tr>
                                <tr><td style="padding:8px 0;color:#6b7280;font-size:13px;">Email</td><td style="padding:8px 0;font-size:14px;">${email}</td></tr>
                                <tr><td style="padding:8px 0;color:#6b7280;font-size:13px;">Telephone</td><td style="padding:8px 0;font-size:14px;">${phone}</td></tr>
                                <tr><td style="padding:8px 0;color:#6b7280;font-size:13px;">Evenement</td><td style="padding:8px 0;font-size:14px;">${eventTitle}</td></tr>
                                <tr><td style="padding:8px 0;color:#6b7280;font-size:13px;">Date/Lieu</td><td style="padding:8px 0;font-size:14px;">${eventDate} - ${eventLocation}</td></tr>
                                <tr><td style="padding:8px 0;color:#6b7280;font-size:13px;">Quantite</td><td style="padding:8px 0;font-size:14px;">${quantity}</td></tr>
                                <tr><td style="padding:8px 0;color:#6b7280;font-size:13px;">Montant</td><td style="padding:8px 0;font-size:14px;font-weight:700;color:#0f766e;">${amount}</td></tr>
                            </table>
                        </td></tr>
                    </table>
                </td></tr>
            </table>
        </div>
    `;
}

async function sendAdminNotification(type, billetData, eventData) {
    try {
        const adminEmail = process.env.ADMIN_EMAIL || process.env.EMAIL_USER;
        const subject = type === 'payment_received'
            ? `Nouveau paiement recu - ${eventData.titre} | ${billetData.reference_billet}`
            : `Notification - ${billetData.reference_billet}`;
        const message = buildAdminNotificationHtml(type, billetData, eventData);

        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: adminEmail,
            subject: subject,
            html: message
        };

        await transporter.sendMail(mailOptions);
        console.log(`Notification admin envoyee (${type}) a:`, adminEmail);
        return true;
    } catch (err) {
        console.error('Erreur envoi notification admin:', err);
        return false;
    }
}

async function sendTicketEmail(billetData, eventData, qrCodeBase64) {
    try {
        const qrCodeImage = qrCodeBase64.replace(/^data:image\/png;base64,/, '');
        const subject = `Billet confirme - ${eventData.titre} | ${billetData.reference_billet}`;
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: billetData.email,
            subject,
            html: buildClientTicketEmailHtml(billetData, eventData),
            attachments: [
                {
                    filename: 'qrcode.png',
                    content: qrCodeImage,
                    encoding: 'base64',
                    cid: 'qrcode'
                }
            ]
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('Email envoye avec succes:', info.messageId);

        await db.query(`
            INSERT INTO rotary_email_logs 
            (id, billet_id, recipient_email, email_type, subject, sent_at, statut)
            VALUES (?, ?, ?, 'billet_envoye', ?, NOW(), 'sent')
        `, [
            generateId('EMAIL'),
            billetData.id,
            billetData.email,
            subject
        ]);

        await sendAdminNotification('email_sent', billetData, eventData);
        return true;
    } catch (err) {
        console.error('Erreur envoi email brocante:', err);
        return false;
    }
}

// ==================== ROUTES BROCANTE ====================

// Liste des événements (filtrer sur le future et publie)
router.get('/events', async (req, res) => {
    try {
        const [events] = await db.query(`
            SELECT 
                e.*,
                (SELECT COUNT(*) FROM rotary_billets b WHERE b.evenement_id = e.id AND b.statut_paiement = 'paye') as billets_vendus
            FROM rotary_evenements e
            WHERE e.statut = 'publie' 
            AND e.date_evenement >= NOW()
            ORDER BY e.date_evenement ASC
        `);
        res.json({ success: true, events });
    } catch (err) {
        console.error('❌ [BROCANTE GET /events] Erreur:', err);
        res.status(500).json({ error: 'Erreur lors de la récupération des événements', details: err.message });
    }
});

// Détails d'un événement
router.get('/events/:eventId', async (req, res) => {
    const { eventId } = req.params;
    try {
        const [events] = await db.query(`SELECT * FROM rotary_evenements WHERE id = ? AND statut = 'publie'`, [eventId]);
        if (events.length === 0) return res.status(404).json({ error: 'Événement non trouvé' });
        const [categories] = await db.query(`SELECT id, nom_categorie, prix_unitaire, currency_code FROM rotary_billets_categories WHERE evenement_id = ? AND is_active = 1 ORDER BY ordre_affichage ASC`, [eventId]);
        res.json({ success: true, event: events[0], categories });
    } catch (err) {
        console.error('❌ [BROCANTE GET /events/:eventId] Erreur:', err);
        res.status(500).json({ error: 'Erreur lors de la récupération de l\'événement', details: err.message });
    }
});

// Créer un billet et initier paiement (réutilise les mêmes tables rotary_ pour centralisation)
router.post('/tickets/create', async (req, res) => {
    const requestId = generateId('REQ');
    const startTime = Date.now();
    console.log(`\n🎫 [BROCANTE][${requestId}] Création billet`);
    const { evenement_id, categorie_id, prenom, nom, email, telephone, quantite, notes_participant } = req.body;
    const effectiveCategorieId = categorie_id || BROCANTE_STAND_CATEGORIE_ID;

    logTicketStep(requestId, 'Payload reçu', {
        evenement_id,
        categorie_id,
        categorie_id_effective: effectiveCategorieId,
        prenom,
        nom,
        email: maskEmail(email),
        telephone: maskPhone(telephone),
        quantite,
        notes_length: typeof notes_participant === 'string' ? notes_participant.length : 0
    });

    if (!evenement_id || !effectiveCategorieId || !prenom || !nom || !email || !quantite) {
        logTicketStep(requestId, 'Validation échouée: paramètres manquants', {
            evenement_id: !!evenement_id,
            categorie_id: !!effectiveCategorieId,
            prenom: !!prenom,
            nom: !!nom,
            email: !!email,
            quantite: !!quantite
        });
        return res.status(400).json({ error: 'Paramètres manquants' });
    }

    try {
        logTicketStep(requestId, 'Recherche événement');
        const [events] = await db.query('SELECT * FROM rotary_evenements WHERE id = ? AND statut = ?', [evenement_id, 'publie']);
        logTicketStep(requestId, 'Résultat événement', { total: events.length });
        if (events.length === 0) {
            logTicketStep(requestId, 'Événement non trouvé', { evenement_id });
            return res.status(404).json({ error: 'Événement non trouvé' });
        }
        const event = events[0];

        logTicketStep(requestId, 'Recherche catégorie');
        const [categories] = await db.query('SELECT * FROM rotary_billets_categories WHERE id = ? AND evenement_id = ? AND is_active = 1', [effectiveCategorieId, evenement_id]);
        logTicketStep(requestId, 'Résultat catégorie', { total: categories.length });
        if (categories.length === 0) {
            logTicketStep(requestId, 'Catégorie non trouvée', { categorie_id: effectiveCategorieId, evenement_id });
            return res.status(404).json({
                error: 'Catégorie non trouvée',
                details: 'Vérifiez que la catégorie existe pour cet événement et que is_active = 1',
                categorie_id: effectiveCategorieId
            });
        }
        const categorie = categories[0];

        const prix_unitaire = Number.parseFloat(categorie.prix_unitaire);
        const montant_total_calcule = prix_unitaire * quantite;
        const montant_total_recu = Number.parseFloat(req.body?.montant_total);
        const montant_total = Number.isFinite(montant_total_recu) && montant_total_recu > 0
            ? montant_total_recu
            : montant_total_calcule;
        logTicketStep(requestId, 'Montant calculé', {
            prix_unitaire,
            quantite,
            montant_total_calcule,
            montant_total_recu,
            montant_total_final: montant_total,
            currency_code: categorie.currency_code
        });

        const billet_id = generateId('BILLET');
        const reference_billet = generateTicketRef();
        const transaction_id = generateId('TRANS');
        const external_reference = generatePaymentRef();
        const cleanNotesParticipant = normalizeNotesParticipant(notes_participant);

        logTicketStep(requestId, 'Identifiants générés', {
            billet_id,
            reference_billet,
            transaction_id,
            external_reference,
            notes_length_before: typeof notes_participant === 'string' ? notes_participant.length : 0,
            notes_length_after: cleanNotesParticipant ? cleanNotesParticipant.length : 0
        });

        const [insertBilletResult] = await db.query(`
            INSERT INTO rotary_billets 
            (id, reference_billet, evenement_id, categorie_id, prenom, nom, email, telephone, quantite, prix_unitaire, montant_total, currency_code, statut_paiement, statut_billet, notes_participant, source_achat)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'en_attente', 'actif', ?, 'site_web')
        `, [
            billet_id, reference_billet, evenement_id, categorie.id, prenom, nom, email, telephone, quantite, prix_unitaire, montant_total, categorie.currency_code, cleanNotesParticipant
        ]);
        logTicketStep(requestId, 'Billet inséré', {
            affectedRows: insertBilletResult.affectedRows,
            insertId: insertBilletResult.insertId || null
        });

        const [insertTransactionResult] = await db.query(`
            INSERT INTO rotary_transactions 
            (id, billet_id, evenement_id, external_reference, montant, currency_code, statut, payment_provider, payer_name, payer_email, payer_msisdn)
            VALUES (?, ?, ?, ?, ?, ?, 'pending', 'ebilling', ?, ?, ?)
        `, [
            transaction_id, billet_id, evenement_id, external_reference, montant_total, categorie.currency_code, `${prenom} ${nom}`, email, telephone
        ]);
        logTicketStep(requestId, 'Transaction insérée', {
            affectedRows: insertTransactionResult.affectedRows,
            insertId: insertTransactionResult.insertId || null
        });

        // Préparer Ebilling
        let cleanedPhone = telephone ? telephone.trim().replace(/\s+/g, '') : '00000000';
        if (cleanedPhone !== '00000000' && cleanedPhone.startsWith('0')) cleanedPhone = '+241' + cleanedPhone.substring(1);
        if (cleanedPhone !== '00000000' && !cleanedPhone.startsWith('+')) cleanedPhone = '+' + cleanedPhone;

        const ebillingData = {
            payer_msisdn: cleanedPhone,
            payer_email: email,
            payer_name: `${prenom} ${nom}`,
            amount: Math.round(montant_total),
            external_reference: external_reference,
            short_description: `${quantite} billet(s) - ${event.titre}`,
            expiry_period: '100',
            return_url: `${FRONTEND_URL}/brocante/payment-result?ref=${reference_billet}`,
            notification_url: EB_CALLBACK_URL
        };

        logTicketStep(requestId, 'Appel Ebilling - payload', {
            payer_msisdn: maskPhone(ebillingData.payer_msisdn),
            payer_email: maskEmail(ebillingData.payer_email),
            payer_name: ebillingData.payer_name,
            amount: ebillingData.amount,
            external_reference: ebillingData.external_reference,
            short_description: ebillingData.short_description,
            return_url: ebillingData.return_url,
            notification_url: ebillingData.notification_url
        });

        if (!EBILLING_USERNAME || !EBILLING_SHARED_KEY) {
            logTicketStep(requestId, 'Configuration Ebilling manquante', {
                hasUsername: !!EBILLING_USERNAME,
                hasSharedKey: !!EBILLING_SHARED_KEY
            });
            return res.status(500).json({
                error: 'Configuration Ebilling incomplète',
                details: 'Définissez EBILLING_USERNAME et EBILLING_SHARED_KEY dans les variables d\'environnement',
                request_id: requestId
            });
        }

        logTicketStep(requestId, 'Auth Ebilling utilisée', {
            username: EBILLING_USERNAME,
            shared_key_masked: maskSecret(EBILLING_SHARED_KEY)
        });

        // 🎫 APPEL API EBILLING - CRÉER LA FACTURE UNIQUEMENT
        // Cette requête POST crée une facture dans Ebilling et retourne un bill_id
        // ⚠️ Cet appel API n'est PAS une redirection utilisateur
        // Le bill_id retourné sera utilisé par le frontend pour construire l'URL de redirection
        const auth = Buffer.from(`${EBILLING_USERNAME}:${EBILLING_SHARED_KEY}`).toString('base64');
        const ebillingResponse = await axios.post(EBILLING_URL, ebillingData, {
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': `Basic ${auth}` }
        });

        // 🔍 LOG BRUT DE LA RÉPONSE EBILLING
        console.log('🔍 [BROCANTE] RÉPONSE BRUTE EBILLING - TYPE:', typeof ebillingResponse.data);
        console.log('🔍 [BROCANTE] RÉPONSE BRUTE EBILLING - STATUS:', ebillingResponse.status);
        console.log('🔍 [BROCANTE] RÉPONSE BRUTE EBILLING - HEADERS:', ebillingResponse.headers);
        
        if (typeof ebillingResponse.data === 'string') {
            console.log('🔍 [BROCANTE] RÉPONSE EST STRING - PREMIERS 500 CHARS:', ebillingResponse.data.substring(0, 500));
        } else {
            console.log('🔍 [BROCANTE] RÉPONSE EST OBJET - CONTENU COMPLET:', JSON.stringify(ebillingResponse.data, null, 2));
        }

        logTicketStep(requestId, 'Réponse Ebilling reçue', {
            hasData: !!ebillingResponse.data,
            hasBill: !!(ebillingResponse.data && ebillingResponse.data.e_bill),
            keys: ebillingResponse.data ? Object.keys(ebillingResponse.data) : []
        });

        if (ebillingResponse.data && ebillingResponse.data.e_bill) {
            const bill = ebillingResponse.data.e_bill;
            
            // LOG DÉTAILLÉ de la réponse Ebilling
            console.log('🔍 [BROCANTE] Contenu complet e_bill:', JSON.stringify(bill, null, 2));
            console.log('🔗 [BROCANTE] payment_url dans e_bill:', bill.payment_url || 'UNDEFINED');
            
            await db.query('UPDATE rotary_transactions SET bill_id = ?, transaction_id = ? WHERE id = ?', [bill.bill_id, bill.bill_id, transaction_id]);
            logTicketStep(requestId, 'Mise à jour transaction avec bill_id', { bill_id: bill.bill_id, transaction_id });
            const durationMs = Date.now() - startTime;
            logTicketStep(requestId, 'Création billet terminée avec succès', { durationMs, reference_billet });
            
            // ✅ RETOURNER LES DONNEES AU FRONTEND
            // ⚠️ IMPORTANT: On retourne le bill_id, PAS une URL de redirection
            // Le frontend construira l'URL de redirection vers le portail Ebilling
            // URL portail = https://test.billing-easy.net?invoice={bill_id}&redirect_url={return_url}
            res.status(201).json({ 
                success: true, 
                // ❌ PAS de payment_url ici - le frontend la construit avec test.billing-easy.net
                bill_id: bill.bill_id,  // ✅ Le frontend utilisera ce bill_id
                reference_billet, 
                montant_total, 
                currency_code: categorie.currency_code, 
                request_id: requestId 
            });
        } else {
            throw new Error('Réponse Ebilling invalide');
        }

    } catch (err) {
        const durationMs = Date.now() - startTime;
        console.error(`❌ [BROCANTE][${requestId}] Erreur création billet brocante:`, err);
        console.error(`❌ [BROCANTE][${requestId}] Contexte erreur:`, {
            durationMs,
            evenement_id,
            categorie_id: effectiveCategorieId,
            email: maskEmail(email),
            telephone: maskPhone(telephone),
            quantite,
            notes_length: typeof notes_participant === 'string' ? notes_participant.length : 0
        });
        if (err.sqlMessage) {
            console.error(`❌ [BROCANTE][${requestId}] SQL Message:`, err.sqlMessage);
            console.error(`❌ [BROCANTE][${requestId}] SQL Code:`, err.code);
            console.error(`❌ [BROCANTE][${requestId}] SQL Errno:`, err.errno);
            if (err.sqlState) console.error(`❌ [BROCANTE][${requestId}] SQL State:`, err.sqlState);
        }
        if (err.response) {
            console.error(`❌ [BROCANTE][${requestId}] Ebilling status:`, err.response.status);
            console.error(`❌ [BROCANTE][${requestId}] Ebilling headers:`, err.response.headers);
            console.error(`❌ [BROCANTE][${requestId}] Ebilling data TYPE:`, typeof err.response.data);
            
            if (typeof err.response.data === 'string') {
                console.error(`❌ [BROCANTE][${requestId}] Ebilling data (500 premiers chars):`, err.response.data.substring(0, 500));
            } else {
                console.error(`❌ [BROCANTE][${requestId}] Ebilling data:`, err.response.data);
            }
            
            if (err.response.status === 401) {
                return res.status(502).json({
                    error: 'Authentification Ebilling refusée',
                    details: 'Identifiants invalides: vérifiez EBILLING_USERNAME et EBILLING_SHARED_KEY',
                    request_id: requestId
                });
            }
        }
        res.status(500).json({ error: 'Erreur lors de la création du billet', details: err.message, request_id: requestId });
    }
});

// Recherche billets + transactions par email et téléphone
router.get('/tickets/search-by-contact', async (req, res) => {
    const email = typeof req.query.email === 'string' ? req.query.email.trim() : '';
    const telephone = typeof req.query.telephone === 'string' ? req.query.telephone.trim() : '';

    if (!email || !telephone) {
        return res.status(400).json({
            error: 'email et telephone sont requis'
        });
    }

    const normalizedTelephone = normalizePhoneForSearch(telephone);
    const normalizedEmail = email.toLowerCase();

    try {
        const [rows] = await db.query(`
            SELECT
                b.id AS billet_id,
                b.reference_billet,
                b.evenement_id,
                b.categorie_id,
                b.prenom,
                b.nom,
                b.email AS billet_email,
                b.telephone AS billet_telephone,
                b.quantite,
                b.prix_unitaire,
                b.montant_total,
                b.currency_code,
                b.statut_paiement,
                b.statut_billet,
                b.created_at AS billet_created_at,
                e.titre AS evenement_titre,
                e.date_evenement,
                e.lieu,
                c.nom_categorie,
                t.id AS transaction_id,
                t.bill_id,
                t.external_reference,
                t.transaction_id AS provider_transaction_id,
                t.montant AS transaction_montant,
                t.currency_code AS transaction_currency_code,
                t.statut AS transaction_statut,
                t.payment_method,
                t.payment_provider,
                t.payer_name,
                t.payer_email,
                t.payer_msisdn,
                t.created_at AS transaction_created_at
            FROM rotary_billets b
            INNER JOIN rotary_evenements e ON b.evenement_id = e.id
            INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
            LEFT JOIN rotary_transactions t ON t.billet_id = b.id
            WHERE LOWER(COALESCE(b.email, '')) = ?
              AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(b.telephone, ''), ' ', ''), '+', ''), '-', ''), '(', ''), ')', '') = ?
            UNION
            SELECT
                b.id AS billet_id,
                b.reference_billet,
                b.evenement_id,
                b.categorie_id,
                b.prenom,
                b.nom,
                b.email AS billet_email,
                b.telephone AS billet_telephone,
                b.quantite,
                b.prix_unitaire,
                b.montant_total,
                b.currency_code,
                b.statut_paiement,
                b.statut_billet,
                b.created_at AS billet_created_at,
                e.titre AS evenement_titre,
                e.date_evenement,
                e.lieu,
                c.nom_categorie,
                t.id AS transaction_id,
                t.bill_id,
                t.external_reference,
                t.transaction_id AS provider_transaction_id,
                t.montant AS transaction_montant,
                t.currency_code AS transaction_currency_code,
                t.statut AS transaction_statut,
                t.payment_method,
                t.payment_provider,
                t.payer_name,
                t.payer_email,
                t.payer_msisdn,
                t.created_at AS transaction_created_at
            FROM rotary_billets b
            INNER JOIN rotary_evenements e ON b.evenement_id = e.id
            INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
            INNER JOIN rotary_transactions t ON t.billet_id = b.id
            WHERE LOWER(COALESCE(t.payer_email, '')) = ?
              AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(t.payer_msisdn, ''), ' ', ''), '+', ''), '-', ''), '(', ''), ')', '') = ?
            ORDER BY billet_created_at DESC, transaction_created_at DESC
        `, [normalizedEmail, normalizedTelephone, normalizedEmail, normalizedTelephone]);

        res.json({
            success: true,
            filters: {
                email: normalizedEmail,
                telephone: normalizedTelephone
            },
            total: rows.length,
            results: rows
        });
    } catch (err) {
        console.error('❌ [BROCANTE GET /tickets/search-by-contact] Erreur:', err);
        res.status(500).json({
            error: 'Erreur lors de la récupération des billets et transactions',
            details: err.message
        });
    }
});

// Webhook Ebilling pour brocante
router.post('/webhook', async (req, res) => {
    console.log('\n🔔 [BROCANTE WEBHOOK] Body:', JSON.stringify(req.body, null, 2));
    const bill_id = req.body.billingid || req.body.bill_id;
    const external_reference = req.body.reference || req.body.external_reference;
    const status = req.body.state || req.body.status;

    try {
        const [transactions] = await db.query('SELECT * FROM rotary_transactions WHERE bill_id = ? OR external_reference = ?', [bill_id, external_reference]);
        if (transactions.length === 0) return res.status(404).json({ error: 'Transaction non trouvée' });
        const transaction = transactions[0];

        let new_status = 'pending';
        if (status === 'paid' || status === 'completed' || status === 'success') new_status = 'success';
        else if (status === 'failed' || status === 'cancelled') new_status = 'failed';

        await db.query(`UPDATE rotary_transactions SET statut = ?, payment_method = ?, payment_details = ?, webhook_received_at = NOW() WHERE id = ?`, [new_status, req.body.paymentsystem || req.body.payment_method, JSON.stringify(req.body), transaction.id]);

        if (new_status === 'success') {
            await db.query('UPDATE rotary_billets SET statut_paiement = ? WHERE id = ?', ['paye', transaction.billet_id]);
            const [billets] = await db.query(`SELECT b.*, c.nom_categorie, e.titre as evenement_titre, e.date_evenement, e.lieu, e.organisateur_nom FROM rotary_billets b INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id INNER JOIN rotary_evenements e ON b.evenement_id = e.id WHERE b.id = ?`, [transaction.billet_id]);
            if (billets.length > 0) {
                const billet = billets[0];
                await db.query('UPDATE rotary_billets_categories SET quantite_vendue = quantite_vendue + ? WHERE id = ?', [billet.quantite, billet.categorie_id]);

                await sendAdminNotification('payment_received', billet, { titre: billet.evenement_titre, date_evenement: billet.date_evenement, lieu: billet.lieu });

                try {
                    const qrData = JSON.stringify({ reference: billet.reference_billet, evenement: billet.evenement_titre, nom: `${billet.prenom} ${billet.nom}`, date: billet.date_evenement, categorie: billet.nom_categorie, quantite: billet.quantite });
                    const qrCodeBase64 = await generateQRCodeBase64(qrData);
                    if (qrCodeBase64) {
                        await db.query('UPDATE rotary_billets SET qr_code_url = ? WHERE id = ?', [qrCodeBase64, billet.id]);
                        await sendTicketEmail(billet, { titre: billet.evenement_titre, date_evenement: billet.date_evenement, lieu: billet.lieu, organisateur_nom: billet.organisateur_nom }, qrCodeBase64);
                    }
                } catch (err) {
                    console.error('❌ Erreur QR/email brocante:', err);
                }
            }
        }

        res.status(200).json({ success: true, message: 'Notification traitée' });
    } catch (err) {
        console.error('❌ Erreur webhook brocante:', err);
        res.status(500).json({ error: 'Erreur traitement webhook', details: err.message });
    }
});

// Export
module.exports = router;

