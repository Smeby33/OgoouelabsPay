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
    console.log('\n🎫 [ROTARY] ==================');
    console.log('📍 URL:', req.url);
    console.log('📍 Méthode:', req.method);
    console.log('📦 Body:', req.body);
    console.log('🎫 [ROTARY] ==================\n');
    next();
});

//==================== CONFIGURATION EBILLING ====================
const EBILLING_USERNAME = process.env.EBILLING_USERNAME || 'ogoouelabs';
const EBILLING_SHARED_KEY = process.env.EBILLING_SHARED_KEY || '17c6f141-0478-48d8-9e56-198c5e79ef45';
const EBILLING_URL = 'https://stg.billing-easy.com/api/v1/merchant/e_bills';
// const EBILLING_USERNAME ='afup';
// const EBILLING_SHARED_KEY ='b3b8814e-4639-46a1-97c3-bf37401dc54b';
// const EBILLING_URL = 'https://lab.billing-easy.net/api/v1/merchant/e_bills';
const EB_CALLBACK_URL = process.env.EB_CALLBACK_URL || 'https://spy86grsmp.us-east-1.awsapprunner.com/rotary/webhook';
const FRONTEND_URL = process.env.FRONTEND_URL || 'https://rotary-port-gentil-65th-anniversary.vercel.app';

// Configuration email
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// ==================== FONCTIONS UTILITAIRES ====================

// Générer un ID unique
function generateId(prefix = 'ID') {
    return `${prefix}-${Date.now()}-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
}

// Générer une référence unique pour billet
function generateTicketRef() {
    const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const random = crypto.randomBytes(3).toString('hex').toUpperCase();
    return `BIL-${date}-${random}`;
}

// Générer une référence de paiement unique
function generatePaymentRef() {
    const random = crypto.randomBytes(6).toString('hex').toUpperCase();
    return `REF-ROTARY-${random}`;
}

// Fonction pour générer un QR code en base64
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

// Fonction pour envoyer un email de notification à l'admin
async function sendAdminNotification(type, billetData, eventData) {
    try {
        const adminEmail = process.env.ADMIN_EMAIL || process.env.EMAIL_USER;
        const adminEmail2 = process.env.ADMIN_EMAIL1;
        const adminEmails = adminEmail2 ? `${adminEmail}, ${adminEmail2}` : adminEmail;
        
        let subject = '';
        let message = '';
        
        if (type === 'payment_received') {
            subject = `🎉 Nouveau paiement reçu - ${eventData.titre}`;
            message = `
                <div style="font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5;">
                    <div style="max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px;">
                        <h2 style="color: #01579B;">💰 Nouveau Paiement Confirmé</h2>
                        <p>Un client vient de payer son billet :</p>
                        
                        <div style="background: #E3F2FD; padding: 20px; border-radius: 8px; margin: 20px 0;">
                            <p><strong>👤 Client :</strong> ${billetData.prenom} ${billetData.nom}</p>
                            <p><strong>📧 Email :</strong> ${billetData.email}</p>
                            <p><strong>📱 Téléphone :</strong> ${billetData.telephone || 'Non renseigné'}</p>
                            <p><strong>🎫 Référence :</strong> ${billetData.reference_billet}</p>
                            <p><strong>🎟️ Catégorie :</strong> ${billetData.nom_categorie}</p>
                            <p><strong>👥 Quantité :</strong> ${billetData.quantite} place(s)</p>
                            <p><strong>💰 Montant :</strong> ${billetData.montant_total.toLocaleString('fr-FR')} ${billetData.currency_code}</p>
                        </div>
                        
                        <div style="background: #FFF3CD; padding: 15px; border-radius: 8px; margin: 20px 0;">
                            <p><strong>📅 Événement :</strong> ${eventData.titre}</p>
                            <p><strong>📍 Date :</strong> ${new Date(eventData.date_evenement).toLocaleDateString('fr-FR', { 
                                weekday: 'long', 
                                year: 'numeric', 
                                month: 'long', 
                                day: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit'
                            })}</p>
                            <p><strong>🏠 Lieu :</strong> ${eventData.lieu}</p>
                        </div>
                        
                        <p style="color: #666; font-size: 12px; margin-top: 30px; text-align: center;">
                            Email automatique envoyé le ${new Date().toLocaleString('fr-FR')}
                        </p>
                    </div>
                </div>
            `;
        } else if (type === 'email_sent') {
            subject = `✅ Email de confirmation envoyé - ${billetData.reference_billet}`;
            message = `
                <div style="font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5;">
                    <div style="max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px;">
                        <h2 style="color: #4CAF50;">✅ Email de Confirmation Envoyé</h2>
                        <p>Le billet a été envoyé avec succès au client :</p>
                        
                        <div style="background: #E8F5E9; padding: 20px; border-radius: 8px; margin: 20px 0;">
                            <p><strong>👤 Client :</strong> ${billetData.prenom} ${billetData.nom}</p>
                            <p><strong>📧 Email :</strong> ${billetData.email}</p>
                            <p><strong>🎫 Référence :</strong> ${billetData.reference_billet}</p>
                            <p><strong>🎟️ Catégorie :</strong> ${billetData.nom_categorie}</p>
                        </div>
                        
                        <div style="background: #E3F2FD; padding: 15px; border-radius: 8px; margin: 20px 0;">
                            <p><strong>📅 Événement :</strong> ${eventData.titre}</p>
                            <p><strong>📍 Date :</strong> ${new Date(eventData.date_evenement).toLocaleDateString('fr-FR')}</p>
                        </div>
                        
                        <p style="margin-top: 20px;">✅ Le client a reçu :</p>
                        <ul style="line-height: 2;">
                            <li>Son billet électronique avec QR code</li>
                            <li>Les détails de l'événement</li>
                            <li>Les instructions d'accès</li>
                        </ul>
                        
                        <p style="color: #666; font-size: 12px; margin-top: 30px; text-align: center;">
                            Email automatique envoyé le ${new Date().toLocaleString('fr-FR')}
                        </p>
                    </div>
                </div>
            `;
        }
        
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: adminEmails,
            subject: subject,
            html: message
        };
        
        await transporter.sendMail(mailOptions);
        console.log(`✅ Notification admin envoyée (${type}) à:`, adminEmails);
        return true;
    } catch (err) {
        console.error('❌ Erreur envoi notification admin:', err);
        return false;
    }
}

// Fonction pour envoyer l'email de confirmation avec QR code
async function sendTicketEmail(billetData, eventData, qrCodeBase64) {
    try {
        console.log('📧 Préparation email pour:', billetData.email);
        
        const qrCodeImage = qrCodeBase64.replace(/^data:image\/png;base64,/, '');
        
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: billetData.email,
            subject: `✅ Votre billet pour ${eventData.titre}`,
            html: `
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { background: linear-gradient(135deg, #01579B 0%, #0277BD 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                        .ticket-info { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
                        .qr-code { text-align: center; margin: 30px 0; }
                        .qr-code img { max-width: 300px; border: 3px solid #01579B; border-radius: 8px; padding: 10px; background: white; }
                        .info-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #eee; }
                        .info-label { font-weight: bold; color: #01579B; }
                        .footer { text-align: center; color: #666; margin-top: 30px; font-size: 12px; }
                        .important { background: #FFF3CD; border-left: 4px solid #F9A825; padding: 15px; margin: 20px 0; border-radius: 4px; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h1>🎉 Paiement Confirmé !</h1>
                            <p>Votre billet est prêt</p>
                        </div>
                        
                        <div class="content">
                            <p>Bonjour <strong>${billetData.prenom} ${billetData.nom}</strong>,</p>
                            
                            <p>Nous avons le plaisir de confirmer votre inscription pour :</p>
                            
                            <div class="ticket-info">
                                <h2 style="color: #01579B; margin-top: 0;">${eventData.titre}</h2>
                                
                                <div class="info-row">
                                    <span class="info-label">📅 Date :</span>
                                    <span>${new Date(eventData.date_evenement).toLocaleDateString('fr-FR', { 
                                        weekday: 'long', 
                                        year: 'numeric', 
                                        month: 'long', 
                                        day: 'numeric',
                                        hour: '2-digit',
                                        minute: '2-digit'
                                    })}</span>
                                </div>
                                
                                <div class="info-row">
                                    <span class="info-label">📍 Lieu :</span>
                                    <span>${eventData.lieu}</span>
                                </div>
                                
                                <div class="info-row">
                                    <span class="info-label">🎫 Référence :</span>
                                    <span><strong>${billetData.reference_billet}</strong></span>
                                </div>
                                
                                <div class="info-row">
                                    <span class="info-label">🎟️ Catégorie :</span>
                                    <span>${billetData.nom_categorie}</span>
                                </div>
                                
                                <div class="info-row">
                                    <span class="info-label">👥 Quantité :</span>
                                    <span>${billetData.quantite} place(s)</span>
                                </div>
                                
                                <div class="info-row">
                                    <span class="info-label">💰 Montant payé :</span>
                                    <span><strong>${billetData.montant_total.toLocaleString('fr-FR')} ${billetData.currency_code}</strong></span>
                                </div>
                            </div>
                            
                            <div class="qr-code">
                                <h3 style="color: #01579B;">Votre QR Code d'Accès</h3>
                                <p>Présentez ce QR code à l'entrée</p>
                                <img src="cid:qrcode" alt="QR Code" />
                                <p style="color: #666; font-size: 14px; margin-top: 10px;">
                                    Référence : <strong>${billetData.reference_billet}</strong>
                                </p>
                            </div>
                            
                            <div class="important">
                                <strong>⚠️ Important :</strong>
                                <ul style="margin: 10px 0;">
                                    <li>Conservez ce QR code précieusement</li>
                                    <li>Présentez-le à l'entrée (format numérique ou imprimé)</li>
                                    <li>Arrivez 15 minutes avant le début de l'événement</li>
                                </ul>
                            </div>
                            
                            ${billetData.notes_participant ? `
                            <div style="background: #E3F2FD; padding: 15px; border-radius: 4px; margin: 20px 0;">
                                <strong>📝 Vos notes :</strong><br/>
                                ${billetData.notes_participant}
                            </div>
                            ` : ''}
                            
                            <p style="margin-top: 30px;">
                                Nous avons hâte de vous accueillir !<br/>
                                En cas de question, n'hésitez pas à nous contacter.
                            </p>
                            
                            <p style="margin-top: 20px;">
                                Cordialement,<br/>
                                <strong>L'équipe ${eventData.organisateur_nom || 'Rotary Club'}</strong>
                            </p>
                        </div>
                        
                        <div class="footer">
                            <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
                            <p>© ${new Date().getFullYear()} Rotary Club - Tous droits réservés</p>
                        </div>
                    </div>
                </body>
                </html>
            `,
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
        console.log('✅ Email envoyé avec succès:', info.messageId);
        
        // Envoyer notification à l'admin que l'email a été envoyé
        await sendAdminNotification('email_sent', billetData, eventData);
        
        // Enregistrer dans les logs
        await db.query(`
            INSERT INTO rotary_email_logs 
            (id, billet_id, recipient_email, email_type, subject, sent_at, statut)
            VALUES (?, ?, ?, 'billet_envoye', ?, NOW(), 'sent')
        `, [
            generateId('EMAIL'),
            billetData.id,
            billetData.email,
            mailOptions.subject
        ]);
        
        return true;
    } catch (err) {
        console.error('❌ Erreur envoi email:', err);
        
        // Enregistrer l'erreur dans les logs
        await db.query(`
            INSERT INTO rotary_email_logs 
            (id, billet_id, recipient_email, email_type, subject, statut, error_message)
            VALUES (?, ?, ?, 'billet_envoye', ?, 'failed', ?)
        `, [
            generateId('EMAIL'),
            billetData.id,
            billetData.email,
            `Billet ${billetData.reference_billet}`,
            err.message
        ]);
        
        return false;
    }
}

// ==================== ROUTES ÉVÉNEMENTS ====================

// 📋 Liste tous les événements publiés
router.get('/events', async (req, res) => {
    console.log('📋 [GET /events] Récupération des événements');
    
    try {
        const [events] = await db.query(`
            SELECT 
                e.*,
                (SELECT COUNT(*) FROM rotary_billets b WHERE b.evenement_id = e.id AND b.statut_paiement = 'paye') as billets_vendus,
                (SELECT SUM(quantite) FROM rotary_billets b WHERE b.evenement_id = e.id AND b.statut_paiement = 'paye') as places_vendues
            FROM rotary_evenements e
            WHERE e.statut = 'publie' 
            AND e.date_evenement >= NOW()
            ORDER BY e.date_evenement ASC
        `);
        
        console.log(`✅ [GET /events] ${events.length} événements trouvés`);
        res.json({ success: true, events });
    } catch (err) {
        console.error('❌ [GET /events] Erreur:', err);
        res.status(500).json({ error: 'Erreur lors de la récupération des événements', details: err.message });
    }
});

// 🔍 Détails d'un événement avec ses catégories de billets
router.get('/events/:eventId', async (req, res) => {
    const { eventId } = req.params;
    console.log(`🔍 [GET /events/${eventId}] Récupération détails événement`);
    
    try {
        const [events] = await db.query(`
            SELECT * FROM rotary_evenements WHERE id = ? AND statut = 'publie'
        `, [eventId]);
        
        if (events.length === 0) {
            return res.status(404).json({ error: 'Événement non trouvé' });
        }
        
        const [categories] = await db.query(`
            SELECT 
                id, 
                nom_categorie, 
                description, 
                prix_unitaire, 
                currency_code,
                quantite_disponible,
                quantite_vendue,
                (quantite_disponible - quantite_vendue) as places_restantes,
                couleur_badge,
                avantages
            FROM rotary_billets_categories 
            WHERE evenement_id = ? AND is_active = 1
            ORDER BY ordre_affichage ASC
        `, [eventId]);
        
        console.log(`✅ [GET /events/${eventId}] Événement trouvé avec ${categories.length} catégories`);
        res.json({ 
            success: true, 
            event: events[0], 
            categories 
        });
    } catch (err) {
        console.error(`❌ [GET /events/${eventId}] Erreur:`, err);
        res.status(500).json({ error: 'Erreur lors de la récupération de l\'événement', details: err.message });
    }
});

// 🎫 Créer un billet et initier le paiement
router.post('/tickets/create', async (req, res) => {
    console.log('\n🎫 ================================');
    console.log('🎫 [POST /tickets/create] CRÉATION DE BILLET');
    console.log('🎫 ================================');
    
    const {
        evenement_id,
        categorie_id,
        user_id,
        prenom,
        nom,
        email,
        telephone,
        quantite,
        code_promo,
        notes_participant,
        besoins_speciaux
    } = req.body;
    
    console.log('📦 Données reçues:', {
        evenement_id, categorie_id, prenom, nom, email, quantite
    });
    
    // Validation
    if (!evenement_id || !categorie_id || !prenom || !nom || !email || !quantite) {
        return res.status(400).json({ 
            error: 'Paramètres manquants', 
            required: ['evenement_id', 'categorie_id', 'prenom', 'nom', 'email', 'quantite']
        });
    }
    
    try {
        // 1. Vérifier que l'événement existe et est disponible
        const [events] = await db.query(
            'SELECT * FROM rotary_evenements WHERE id = ? AND statut = ?',
            [evenement_id, 'publie']
        );
        
        if (events.length === 0) {
            return res.status(404).json({ error: 'Événement non trouvé ou non disponible' });
        }
        
        const event = events[0];
        
        // 2. Récupérer la catégorie et vérifier la disponibilité
        const [categories] = await db.query(
            'SELECT * FROM rotary_billets_categories WHERE id = ? AND evenement_id = ? AND is_active = 1',
            [categorie_id, evenement_id]
        );
        
        if (categories.length === 0) {
            return res.status(404).json({ error: 'Catégorie de billet non trouvée' });
        }
        
        const categorie = categories[0];
        const placesRestantes = categorie.quantite_disponible ? 
            (categorie.quantite_disponible - categorie.quantite_vendue) : null;
        
        if (placesRestantes !== null && quantite > placesRestantes) {
            return res.status(400).json({ 
                error: 'Pas assez de places disponibles', 
                places_restantes: placesRestantes 
            });
        }
        
        // 3. Calculer le prix (avec réduction si code promo)
        let prix_unitaire = parseFloat(categorie.prix_unitaire);
        let montant_reduction = 0;
        let code_promo_valide = null;
        
        if (code_promo) {
            const [promos] = await db.query(`
                SELECT * FROM rotary_codes_promo 
                WHERE code = ? 
                AND is_active = 1
                AND NOW() BETWEEN date_debut AND date_fin
                AND (evenement_id IS NULL OR evenement_id = ?)
                AND (utilisation_max IS NULL OR utilisation_actuelle < utilisation_max)
            `, [code_promo, evenement_id]);
            
            if (promos.length > 0) {
                const promo = promos[0];
                if (promo.type_reduction === 'pourcentage') {
                    montant_reduction = (prix_unitaire * promo.valeur_reduction) / 100;
                } else {
                    montant_reduction = promo.valeur_reduction;
                }
                prix_unitaire -= montant_reduction;
                code_promo_valide = promo.id;
                
                await db.query(
                    'UPDATE rotary_codes_promo SET utilisation_actuelle = utilisation_actuelle + 1 WHERE id = ?',
                    [promo.id]
                );
            }
        }
        
        // 4. Calculer le montant total et générer les IDs
        // Si le frontend envoie un montant_total (avec activités optionnelles), on l'utilise
        // Sinon on calcule basé sur le prix de la catégorie
        let montant_total;
        if (req.body.montant_total && parseFloat(req.body.montant_total) > 0) {
            montant_total = parseFloat(req.body.montant_total);
            console.log('💰 Utilisation du montant_total du frontend:', montant_total);
        } else {
            montant_total = prix_unitaire * quantite;
            console.log('💰 Calcul du montant basé sur la catégorie:', montant_total);
        }
        
        const billet_id = generateId('BILLET');
        const reference_billet = generateTicketRef();
        const transaction_id = generateId('TRANS');
        const external_reference = generatePaymentRef();
        
        console.log('🆔 IDs générés:', { billet_id, reference_billet, transaction_id, external_reference });
        
        // 5. Créer le billet
        await db.query(`
            INSERT INTO rotary_billets 
            (id, reference_billet, evenement_id, categorie_id, user_id, prenom, nom, email, telephone, 
            quantite, prix_unitaire, montant_total, currency_code, statut_paiement, statut_billet,
            notes_participant, besoins_speciaux, code_promo, montant_reduction, source_achat)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'en_attente', 'actif', ?, ?, ?, ?, 'site_web')
        `, [
            billet_id, reference_billet, evenement_id, categorie_id, user_id, prenom, nom, email, telephone,
            quantite, prix_unitaire, montant_total, categorie.currency_code,
            notes_participant, besoins_speciaux, code_promo_valide, montant_reduction
        ]);
        
        console.log('✅ Billet créé:', billet_id);
        
        // 6. Créer la transaction
        await db.query(`
            INSERT INTO rotary_transactions 
            (id, billet_id, evenement_id, external_reference, montant, currency_code, 
            statut, payment_provider, payer_name, payer_email, payer_msisdn)
            VALUES (?, ?, ?, ?, ?, ?, 'pending', 'ebilling', ?, ?, ?)
        `, [
            transaction_id, billet_id, evenement_id, external_reference, 
            montant_total, categorie.currency_code,
            `${prenom} ${nom}`, email, telephone
        ]);
        
        console.log('✅ Transaction créée:', transaction_id);
        
        // 7. Incrémenter l'utilisation du code promo
        if (code_promo_valide) {
            await db.query(
                'UPDATE rotary_codes_promo SET utilisation_actuelle = utilisation_actuelle + 1 WHERE code = ?',
                [code_promo_valide]
            );
        }
        
        // 8. Créer la facture Ebilling
        const short_description = `${quantite} billet(s) ${categorie.nom_categorie} - ${event.titre}`;
        const return_url = `${FRONTEND_URL}/rotary/payment-result?ref=${reference_billet}`;
        
        // Nettoyer et formater le numéro de téléphone pour Ebilling
        let cleanedPhone = telephone ? telephone.trim().replace(/\s+/g, '') : '00000000';
        
        // Si le numéro commence par 0, remplacer par +241 (Gabon)
        if (cleanedPhone !== '00000000' && cleanedPhone.startsWith('0')) {
            cleanedPhone = '+241' + cleanedPhone.substring(1);
        }
        
        // S'assurer que le numéro commence par + (sauf si 00000000)
        if (cleanedPhone !== '00000000' && !cleanedPhone.startsWith('+')) {
            cleanedPhone = '+' + cleanedPhone;
        }
        
        const ebillingData = {
            payer_msisdn: cleanedPhone,
            payer_email: email,
            payer_name: `${prenom} ${nom}`,
            amount: Math.round(montant_total), // Ebilling n'accepte que des entiers
            external_reference: external_reference,
            short_description: short_description,
            expiry_period: '100',
            return_url: return_url,
            notification_url: EB_CALLBACK_URL
        };
        
        const auth = Buffer.from(`${EBILLING_USERNAME}:${EBILLING_SHARED_KEY}`).toString('base64');
        
        console.log('\n🌐 ==================== APPEL EBILLING ====================');
        console.log('🔗 URL:', EBILLING_URL);
        console.log('👤 Username:', EBILLING_USERNAME);
        console.log('🔑 Shared Key:', EBILLING_SHARED_KEY ? EBILLING_SHARED_KEY.substring(0, 8) + '...' : 'NON DÉFINI');
        console.log('📦 Données envoyées à Ebilling:', JSON.stringify(ebillingData, null, 2));
        console.log('🔐 Auth Header:', auth ? auth.substring(0, 20) + '...' : 'NON DÉFINI');
        console.log('🌐 ========================================================\n');
        
        let ebillingResponse;
        try {
            ebillingResponse = await axios.post(EBILLING_URL, ebillingData, {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': `Basic ${auth}`
                }
            });
            
            console.log('\n✅ ==================== RÉPONSE EBILLING ====================');
            console.log('📊 Status:', ebillingResponse.status);
            console.log('📦 Data:', JSON.stringify(ebillingResponse.data, null, 2));
            console.log('✅ ===========================================================\n');
        } catch (ebillingError) {
            console.error('\n❌ ==================== ERREUR EBILLING ====================');
            console.error('❌ Message:', ebillingError.message);
            console.error('❌ Status:', ebillingError.response?.status);
            console.error('❌ Response Data:', JSON.stringify(ebillingError.response?.data, null, 2));
            console.error('❌ Request Config:', JSON.stringify({
                url: ebillingError.config?.url,
                method: ebillingError.config?.method,
                headers: ebillingError.config?.headers,
                data: ebillingError.config?.data
            }, null, 2));
            console.error('❌ ===========================================================\n');
            throw ebillingError;
        }
        
        console.log('✅ Facture Ebilling créée:', ebillingResponse.data);
        
        if (ebillingResponse.data && ebillingResponse.data.e_bill) {
            const bill = ebillingResponse.data.e_bill;
            
            // Mettre à jour la transaction avec bill_id
            await db.query(
                'UPDATE rotary_transactions SET bill_id = ?, transaction_id = ? WHERE id = ?',
                [bill.bill_id, bill.bill_id, transaction_id]
            );
            
            console.log('🎉 Processus complet! Bill ID:', bill.bill_id);
            console.log('🎫 ================================\n');
            
            res.status(201).json({
                success: true,
                message: 'Billet créé avec succès',
                data: {
                    billet_id,
                    reference_billet,
                    transaction_id,
                    bill_id: bill.bill_id,
                    payment_url: bill.payment_url,
                    montant_total,
                    currency_code: categorie.currency_code,
                    event: {
                        titre: event.titre,
                        date: event.date_evenement,
                        lieu: event.lieu
                    }
                }
            });
        } else {
            throw new Error('Réponse Ebilling invalide');
        }
        
    } catch (err) {
        console.error('❌ Erreur création billet:', err);
        res.status(500).json({ 
            error: 'Erreur lors de la création du billet', 
            details: err.response?.data || err.message 
        });
    }
});

// 🔔 Webhook - Recevoir les notifications de paiement Ebilling
router.post('/webhook', async (req, res) => {
    console.log('\n🔔 ================================');
    console.log('🔔 [POST /webhook] NOTIFICATION EBILLING ROTARY');
    console.log('🔔 ================================');
    console.log('📦 Body complet:', JSON.stringify(req.body, null, 2));
    
    const bill_id = req.body.billingid || req.body.bill_id;
    const external_reference = req.body.reference || req.body.external_reference;
    const status = req.body.state || req.body.status;
    const amount = req.body.amount;
    const payment_method = req.body.paymentsystem || req.body.payment_method;
    
    console.log('📊 Données extraites:', { bill_id, external_reference, status, amount, payment_method });
    
    try {
        // 1. Trouver la transaction
        const [transactions] = await db.query(
            'SELECT * FROM rotary_transactions WHERE bill_id = ? OR external_reference = ?',
            [bill_id, external_reference]
        );
        
        if (transactions.length === 0) {
            console.warn('⚠️ Transaction non trouvée');
            return res.status(404).json({ error: 'Transaction non trouvée' });
        }
        
        const transaction = transactions[0];
        console.log('✅ Transaction trouvée:', transaction.id);
        
        // 2. Mettre à jour la transaction
        let new_status = 'pending';
        if (status === 'paid' || status === 'completed' || status === 'success') {
            new_status = 'success';
        } else if (status === 'failed' || status === 'cancelled') {
            new_status = 'failed';
        }
        
        await db.query(`
            UPDATE rotary_transactions 
            SET statut = ?, 
                payment_method = ?,
                payment_details = ?,
                webhook_received_at = NOW()
            WHERE id = ?
        `, [new_status, payment_method, JSON.stringify(req.body), transaction.id]);
        
        console.log(`✅ Transaction mise à jour: ${new_status}`);
        
        // 3. Si paiement réussi, mettre à jour le billet
        if (new_status === 'success') {
            console.log('💰 Paiement réussi détecté, traitement...');
            
            await db.query(
                'UPDATE rotary_billets SET statut_paiement = ? WHERE id = ?',
                ['paye', transaction.billet_id]
            );
            console.log('✅ Statut billet mis à jour en "paye"');
            
            // Récupérer les détails complets du billet pour l'email
            console.log('🔍 Récupération des détails du billet:', transaction.billet_id);
            const [billets] = await db.query(`
                SELECT 
                    b.*,
                    c.nom_categorie,
                    e.titre as evenement_titre,
                    e.date_evenement,
                    e.lieu,
                    e.organisateur_nom
                FROM rotary_billets b
                INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
                INNER JOIN rotary_evenements e ON b.evenement_id = e.id
                WHERE b.id = ?
            `, [transaction.billet_id]);
            
            console.log('📊 Nombre de billets trouvés:', billets.length);
            
            if (billets.length > 0) {
                const billet = billets[0];
                console.log('✅ Billet récupéré:', billet.reference_billet);
                console.log('📧 Email destinataire:', billet.email);
                
                // Incrémenter le compteur de billets vendus
                await db.query(
                    'UPDATE rotary_billets_categories SET quantite_vendue = quantite_vendue + ? WHERE id = ?',
                    [billet.quantite, billet.categorie_id]
                );
                console.log('✅ Compteur de billets vendus incrémenté');
                
                console.log('🎉 PAIEMENT CONFIRMÉ - Billet validé!');
                
                // Envoyer notification à l'admin du paiement reçu
                await sendAdminNotification('payment_received', billet, {
                    titre: billet.evenement_titre,
                    date_evenement: billet.date_evenement,
                    lieu: billet.lieu,
                    organisateur_nom: billet.organisateur_nom
                });
                
                try {
                    // Générer QR code avec les infos du billet
                    const qrData = JSON.stringify({
                        reference: billet.reference_billet,
                        evenement: billet.evenement_titre,
                        nom: `${billet.prenom} ${billet.nom}`,
                        date: billet.date_evenement,
                        categorie: billet.nom_categorie,
                        quantite: billet.quantite
                    });
                    
                    console.log('🔲 Génération du QR code...');
                    const qrCodeBase64 = await generateQRCodeBase64(qrData);
                    
                    if (qrCodeBase64) {
                        console.log('✅ QR code généré avec succès');
                        console.log('🔲 QR Code (longueur:', qrCodeBase64.length, 'caractères)');
                        console.log('🔲 QR Code (aperçu):', qrCodeBase64.substring(0, 100) + '...');
                        
                        // Mettre à jour le billet avec l'URL du QR code
                        await db.query(
                            'UPDATE rotary_billets SET qr_code_url = ? WHERE id = ?',
                            [qrCodeBase64, billet.id]
                        );
                        console.log('✅ QR code enregistré dans la base de données');
                        
                        // Envoyer l'email avec le QR code
                        console.log('📧 Préparation de l\'envoi de l\'email...');
                        const eventDataForEmail = {
                            titre: billet.evenement_titre,
                            date_evenement: billet.date_evenement,
                            lieu: billet.lieu,
                            organisateur_nom: billet.organisateur_nom
                        };
                        
                        const emailSent = await sendTicketEmail(
                            billet,
                            eventDataForEmail,
                            qrCodeBase64
                        );
                        
                        if (emailSent) {
                            console.log('✅ ✅ ✅ Email envoyé avec succès à:', billet.email);
                        } else {
                            console.error('⚠️ Échec envoi email, mais billet validé');
                        }
                    } else {
                        console.error('⚠️ Échec génération QR code');
                    }
                } catch (qrEmailError) {
                    console.error('❌ Erreur lors de la génération QR/envoi email:', qrEmailError);
                    console.error('Stack:', qrEmailError.stack);
                }
            } else {
                console.error('⚠️ Aucun billet trouvé pour l\'ID:', transaction.billet_id);
            }
        }
        
        console.log('🔔 ================================\n');
        res.status(200).json({ success: true, message: 'Notification traitée' });
        
    } catch (err) {
        console.error('❌ Erreur webhook:', err);
        res.status(500).json({ error: 'Erreur traitement webhook', details: err.message });
    }
});

// 🔍 Vérifier le statut d'un billet
router.get('/tickets/:reference', async (req, res) => {
    const { reference } = req.params;
    console.log(`🔍 [GET /tickets/${reference}] Vérification statut billet`);
    
    try {
        const [billets] = await db.query(`
            SELECT 
                b.*,
                e.titre as evenement_titre,
                e.date_evenement,
                e.lieu,
                e.statut as evenement_statut,
                e.organisateur_nom,
                c.nom_categorie,
                t.statut as transaction_statut,
                t.bill_id,
                t.payment_method
            FROM rotary_billets b
            INNER JOIN rotary_evenements e ON b.evenement_id = e.id
            INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
            LEFT JOIN rotary_transactions t ON b.id = t.billet_id
            WHERE b.reference_billet = ?
        `, [reference]);
        
        if (billets.length === 0) {
            return res.status(404).json({ error: 'Billet non trouvé' });
        }
        
        const billet = billets[0];
        console.log('✅ Billet trouvé:', billet.id, '- Statut:', billet.statut_paiement);
        
        // Si le billet est payé et qu'il n'a pas encore de QR code, générer et envoyer l'email
        if (billet.statut_paiement === 'paye' && !billet.qr_code_url) {
            console.log('🎉 Billet payé détecté - Envoi de l\'email avec QR code...');
            
            try {
                // Générer QR code
                const qrData = JSON.stringify({
                    reference: billet.reference_billet,
                    evenement: billet.evenement_titre,
                    nom: `${billet.prenom} ${billet.nom}`,
                    date: billet.date_evenement,
                    categorie: billet.nom_categorie,
                    quantite: billet.quantite
                });
                
                console.log('🔲 Génération du QR code...');
                const qrCodeBase64 = await generateQRCodeBase64(qrData);
                
                if (qrCodeBase64) {
                    console.log('✅ QR code généré avec succès');
                    console.log('🔲 QR Code (longueur:', qrCodeBase64.length, 'caractères)');
                    console.log('🔲 QR Code (aperçu):', qrCodeBase64.substring(0, 100) + '...');
                    
                    // Mettre à jour le billet avec l'URL du QR code
                    await db.query(
                        'UPDATE rotary_billets SET qr_code_url = ? WHERE id = ?',
                        [qrCodeBase64, billet.id]
                    );
                    console.log('✅ QR code enregistré dans la base de données');
                    
                    // Mettre à jour l'objet billet avec le QR code
                    billet.qr_code_url = qrCodeBase64;
                    
                    // Envoyer l'email avec le QR code
                    console.log('📧 Préparation de l\'envoi de l\'email...');
                    const eventDataForEmail = {
                        titre: billet.evenement_titre,
                        date_evenement: billet.date_evenement,
                        lieu: billet.lieu,
                        organisateur_nom: billet.organisateur_nom
                    };
                    
                    const emailSent = await sendTicketEmail(
                        billet,
                        eventDataForEmail,
                        qrCodeBase64
                    );
                    
                    if (emailSent) {
                        console.log('✅ ✅ ✅ Email envoyé avec succès à:', billet.email);
                    } else {
                        console.warn('⚠️ Échec envoi email, mais QR code généré');
                    }
                } else {
                    console.error('⚠️ Échec génération QR code');
                }
            } catch (qrEmailError) {
                console.error('❌ Erreur lors de la génération QR/envoi email:', qrEmailError);
                console.error('Stack:', qrEmailError.stack);
                // On continue quand même pour renvoyer les données du billet
            }
        } else if (billet.statut_paiement === 'paye' && billet.qr_code_url) {
            console.log('✅ Billet déjà traité (QR code existant)');
        } else {
            console.log('⏳ Billet en attente de paiement');
        }
        
        // Préparer la réponse avec toutes les informations incluant le QR code
        const response = {
            success: true,
            ticket: billet,
            qr_code: billet.qr_code_url || null, // QR code explicitement inclus
            has_qr_code: !!billet.qr_code_url,
            payment_status: billet.statut_paiement
        };
        
        console.log('📤 Envoi de la réponse avec QR code:', response.has_qr_code ? 'Oui' : 'Non');
        if (response.qr_code) {
            console.log('🔲 QR Code complet envoyé (longueur:', response.qr_code.length, 'caractères)');
            console.log('🔲 QR Code (aperçu):', response.qr_code.substring(0, 100) + '...');
        }
        res.json(response);
        
    } catch (err) {
        console.error('❌ Erreur récupération billet:', err);
        res.status(500).json({ error: 'Erreur lors de la récupération du billet', details: err.message });
    }
});

// 📊 Mes billets (par email ou user_id)
router.get('/my-tickets', async (req, res) => {
    const { email, user_id } = req.query;
    console.log('📊 [GET /my-tickets] Récupération billets:', { email, user_id });
    
    if (!email && !user_id) {
        return res.status(400).json({ error: 'email ou user_id requis' });
    }
    
    try {
        let query = `
            SELECT 
                b.*,
                e.titre as evenement_titre,
                e.date_evenement,
                e.lieu,
                e.image_url as evenement_image,
                c.nom_categorie,
                t.statut as transaction_statut
            FROM rotary_billets b
            INNER JOIN rotary_evenements e ON b.evenement_id = e.id
            INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
            LEFT JOIN rotary_transactions t ON b.id = t.billet_id
            WHERE 1=1
        `;
        
        const params = [];
        if (email) {
            query += ' AND b.email = ?';
            params.push(email);
        }
        if (user_id) {
            query += ' AND b.user_id = ?';
            params.push(user_id);
        }
        
        query += ' ORDER BY b.created_at DESC';
        
        const [billets] = await db.query(query, params);
        
        console.log(`✅ ${billets.length} billets trouvés`);
        res.json({ success: true, tickets: billets });
        
    } catch (err) {
        console.error('❌ Erreur récupération billets:', err);
        res.status(500).json({ error: 'Erreur lors de la récupération des billets', details: err.message });
    }
});

// 📈 Statistiques d'un événement (admin)
router.get('/events/:eventId/stats', async (req, res) => {
    const { eventId } = req.params;
    console.log(`📈 [GET /events/${eventId}/stats] Statistiques`);
    
    try {
        const [stats] = await db.query(`
            SELECT * FROM rotary_stats_evenements WHERE evenement_id = ?
        `, [eventId]);
        
        if (stats.length === 0) {
            return res.status(404).json({ error: 'Événement non trouvé' });
        }
        
        // Détail par catégorie
        const [categoriesStats] = await db.query(`
            SELECT 
                c.nom_categorie,
                c.prix_unitaire,
                c.quantite_disponible,
                c.quantite_vendue,
                (c.quantite_disponible - c.quantite_vendue) as places_restantes,
                COUNT(DISTINCT b.id) as nb_billets,
                SUM(b.quantite) as total_places,
                SUM(CASE WHEN b.statut_paiement = 'paye' THEN b.montant_total ELSE 0 END) as revenus
            FROM rotary_billets_categories c
            LEFT JOIN rotary_billets b ON c.id = b.categorie_id
            WHERE c.evenement_id = ?
            GROUP BY c.id
        `, [eventId]);
        
        console.log('✅ Statistiques récupérées');
        res.json({ 
            success: true, 
            stats: stats[0],
            categories: categoriesStats
        });
        
    } catch (err) {
        console.error('❌ Erreur statistiques:', err);
        res.status(500).json({ error: 'Erreur lors de la récupération des statistiques', details: err.message });
    }
});

// ✅ Valider un code promo
router.post('/validate-promo', async (req, res) => {
    const { code, evenement_id } = req.body;
    console.log('🎟️ [POST /validate-promo] Validation code:', code);
    
    if (!code) {
        return res.status(400).json({ error: 'Code requis' });
    }
    
    try {
        const [promos] = await db.query(`
            SELECT * FROM rotary_codes_promo 
            WHERE code = ? 
            AND is_active = 1
            AND NOW() BETWEEN date_debut AND date_fin
            AND (evenement_id IS NULL OR evenement_id = ?)
            AND (utilisation_max IS NULL OR utilisation_actuelle < utilisation_max)
        `, [code, evenement_id || null]);
        
        if (promos.length === 0) {
            return res.status(404).json({ 
                valid: false, 
                error: 'Code promo invalide ou expiré' 
            });
        }
        
        const promo = promos[0];
        console.log('✅ Code promo valide:', promo.id);
        
        res.json({
            valid: true,
            promo: {
                code: promo.code,
                type_reduction: promo.type_reduction,
                valeur_reduction: promo.valeur_reduction,
                description: promo.description
            }
        });
        
    } catch (err) {
        console.error('❌ Erreur validation promo:', err);
        res.status(500).json({ error: 'Erreur lors de la validation du code promo', details: err.message });
    }
});

// 📧 Envoyer manuellement l'email pour un billet payé (Admin)
router.post('/tickets/:reference/resend-email', async (req, res) => {
    const { reference } = req.params;
    console.log(`📧 [POST /tickets/${reference}/resend-email] Renvoi manuel email`);
    
    try {
        // Récupérer les détails du billet
        const [billets] = await db.query(`
            SELECT 
                b.*,
                c.nom_categorie,
                e.titre as evenement_titre,
                e.date_evenement,
                e.lieu,
                e.organisateur_nom
            FROM rotary_billets b
            INNER JOIN rotary_billets_categories c ON b.categorie_id = c.id
            INNER JOIN rotary_evenements e ON b.evenement_id = e.id
            WHERE b.reference_billet = ?
        `, [reference]);
        
        if (billets.length === 0) {
            return res.status(404).json({ error: 'Billet non trouvé' });
        }
        
        const billet = billets[0];
        
        // Vérifier que le billet est bien payé
        if (billet.statut_paiement !== 'paye') {
            return res.status(400).json({ 
                error: 'Le billet doit être payé pour envoyer l\'email',
                statut: billet.statut_paiement
            });
        }
        
        console.log('✅ Billet payé trouvé, génération QR code...');
        
        // Générer ou récupérer le QR code
        let qrCodeBase64 = billet.qr_code_url;
        
        if (!qrCodeBase64) {
            const qrData = JSON.stringify({
                reference: billet.reference_billet,
                evenement: billet.evenement_titre,
                nom: `${billet.prenom} ${billet.nom}`,
                date: billet.date_evenement,
                categorie: billet.nom_categorie,
                quantite: billet.quantite
            });
            
            qrCodeBase64 = await generateQRCodeBase64(qrData);
            
            if (qrCodeBase64) {
                console.log('🔲 QR Code généré (longueur:', qrCodeBase64.length, 'caractères)');
                console.log('🔲 QR Code (aperçu):', qrCodeBase64.substring(0, 100) + '...');
                // Enregistrer le QR code
                await db.query(
                    'UPDATE rotary_billets SET qr_code_url = ? WHERE id = ?',
                    [qrCodeBase64, billet.id]
                );
                console.log('✅ QR code généré et enregistré');
            } else {
                return res.status(500).json({ error: 'Échec génération QR code' });
            }
        } else {
            console.log('🔲 QR Code existant récupéré (longueur:', qrCodeBase64.length, 'caractères)');
            console.log('🔲 QR Code (aperçu):', qrCodeBase64.substring(0, 100) + '...');
        }
        
        // Envoyer l'email
        const eventData = {
            titre: billet.evenement_titre,
            date_evenement: billet.date_evenement,
            lieu: billet.lieu,
            organisateur_nom: billet.organisateur_nom
        };
        
        const emailSent = await sendTicketEmail(billet, eventData, qrCodeBase64);
        
        if (emailSent) {
            console.log('✅ Email renvoyé avec succès');
            res.json({ 
                success: true, 
                message: 'Email envoyé avec succès',
                recipient: billet.email
            });
        } else {
            res.status(500).json({ error: 'Échec lors de l\'envoi de l\'email' });
        }
        
    } catch (err) {
        console.error('❌ Erreur renvoi email:', err);
        res.status(500).json({ 
            error: 'Erreur lors du renvoi de l\'email', 
            details: err.message 
        });
    }
});

module.exports = router;
