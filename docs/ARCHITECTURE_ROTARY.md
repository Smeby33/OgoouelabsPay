# 🏗️ Architecture du Système Rotary Club

## 📐 Schéma d'Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SYSTÈME DE PAIEMENT ROTARY CLUB                      │
│                              Architecture Complète                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                                  FRONTEND                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │  Page Accueil   │  │  Liste          │  │  Achat Billet   │            │
│  │  Événements     │→ │  Événements     │→ │  + Paiement     │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                      ↓                        │
│                                            ┌─────────────────┐               │
│                                            │  Confirmation   │               │
│                                            │  + QR Code      │               │
│                                            └─────────────────┘               │
│                                                                               │
└────────────────────────────────────┬──────────────────────────────────────────┘
                                     │
                                     │ HTTP/HTTPS
                                     ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                              BACKEND (Node.js)                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    routes/rotaryEventsRoutes.js                        │ │
│  ├────────────────────────────────────────────────────────────────────────┤ │
│  │                                                                        │ │
│  │  GET  /rotary/events              → Liste événements                 │ │
│  │  GET  /rotary/events/:id          → Détails + catégories             │ │
│  │  POST /rotary/tickets/create      → Créer billet + paiement          │ │
│  │  GET  /rotary/tickets/:ref        → Statut billet                    │ │
│  │  GET  /rotary/my-tickets          → Mes billets                      │ │
│  │  POST /rotary/webhook             → Notification Ebilling (auto)     │ │
│  │  POST /rotary/validate-promo      → Valider code promo               │ │
│  │  GET  /rotary/events/:id/stats    → Statistiques                     │ │
│  │                                                                        │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
└────────────────────┬────────────────────────────┬──────────────────────────────┘
                     │                            │
                     │                            │ Webhook
                     ↓                            ↓
┌──────────────────────────────────┐  ┌──────────────────────────────────┐
│        BASE DE DONNÉES           │  │      EBILLING API                │
│          (MySQL)                 │  │   (Paiement Mobile Money)        │
├──────────────────────────────────┤  ├──────────────────────────────────┤
│                                  │  │                                  │
│  📋 rotary_evenements            │  │  POST /e_bills                   │
│     └─ Gala, Conférence, etc.   │  │     └─ Créer facture             │
│                                  │  │                                  │
│  🎫 rotary_billets_categories    │  │  GET  /e_bills/:id               │
│     └─ VIP, Standard, Étudiant   │  │     └─ Vérifier statut           │
│                                  │  │                                  │
│  👤 rotary_billets               │  │  WEBHOOK (auto)                  │
│     └─ Billets vendus            │  │     └─ Notification paiement     │
│                                  │  │                                  │
│  💳 rotary_transactions          │  └──────────────────────────────────┘
│     └─ Paiements                 │                ↓
│                                  │    ┌──────────────────────────┐
│  🎟️ rotary_codes_promo           │    │   MOBILE MONEY TOGO      │
│     └─ Codes promo               │    │  (Tmoney, Flooz, etc.)   │
│                                  │    └──────────────────────────┘
│  📧 rotary_email_logs            │
│     └─ Historique emails         │
│                                  │
│  📊 VUES                         │
│     └─ rotary_stats_evenements   │
│     └─ rotary_transactions_pend. │
│                                  │
└──────────────────────────────────┘
```

## 🔄 Flux de Données - Achat de Billet

```
ÉTAPE 1: SÉLECTION
┌──────────┐
│ Client   │ Visite le site
└────┬─────┘
     │
     ↓ GET /rotary/events
┌────────────┐
│ Backend    │ Récupère événements depuis BDD
└────┬───────┘
     │
     ↓ JSON Response
┌──────────┐
│ Frontend │ Affiche liste événements
└────┬─────┘
     │
     ↓ Client choisit événement
     │
     ↓ GET /rotary/events/:id
┌────────────┐
│ Backend    │ Récupère catégories billets
└────┬───────┘
     │
     ↓ JSON Response
┌──────────┐
│ Frontend │ Affiche catégories + prix
└────┬─────┘
     │
     ↓ Client remplit formulaire

ÉTAPE 2: CRÉATION BILLET
     │
     ↓ POST /rotary/tickets/create
┌────────────┐
│ Backend    │ 1. Vérifie disponibilité places
└────┬───────┘ 2. Applique code promo si valide
     │         3. Crée billet (statut: en_attente)
     │         4. Crée transaction (statut: pending)
     │
     ↓ POST à Ebilling API
┌──────────────┐
│ Ebilling     │ Crée facture de paiement
└────┬─────────┘ Génère bill_id + payment_url
     │
     ↓ Response
┌────────────┐
│ Backend    │ Sauvegarde bill_id dans transaction
└────┬───────┘
     │
     ↓ JSON Response {payment_url}
┌──────────┐
│ Frontend │ Redirige vers payment_url
└────┬─────┘

ÉTAPE 3: PAIEMENT
     │
     ↓ Redirection
┌──────────────┐
│ Ebilling     │ Client paie (Mobile Money/Carte)
└────┬─────────┘
     │
     ↓ Paiement réussi

ÉTAPE 4: CONFIRMATION (AUTOMATIQUE)
     │
     ↓ POST /rotary/webhook (automatique)
┌────────────┐
│ Backend    │ 1. Reçoit notification Ebilling
└────┬───────┘ 2. Vérifie statut = "paid"
     │         3. Met à jour transaction → success
     │         4. Met à jour billet → payé
     │         5. Incrémente quantité_vendue
     │         6. (TODO) Envoie email + QR code
     │
     ↓ Sauvegarde BDD
┌──────────────┐
│ Base Données │ Billet confirmé, stats mises à jour
└──────────────┘

ÉTAPE 5: CONSULTATION
┌──────────┐
│ Client   │ GET /rotary/tickets/:ref
└────┬─────┘
     │
     ↓
┌────────────┐
│ Backend    │ Récupère statut billet
└────┬───────┘
     │
     ↓ JSON Response
┌──────────┐
│ Frontend │ Affiche billet + QR code
└──────────┘
```

## 🗄️ Structure de la Base de Données

```
┌─────────────────────────────────────────────────────────────────┐
│                    ROTARY CLUB DATABASE                          │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  rotary_evenements                                               │
├──────────────────────────────────────────────────────────────────┤
│  • id (PK)                    VARCHAR(50)                        │
│  • titre                      VARCHAR(255)                       │
│  • description                TEXT                               │
│  • type_evenement             ENUM (gala, conference, etc.)      │
│  • date_evenement             DATETIME                           │
│  • lieu                       VARCHAR(255)                       │
│  • capacite_max               INT                                │
│  • statut                     ENUM (publie, annule, etc.)        │
│  • is_payant                  BOOLEAN                            │
│  • created_at, updated_at     TIMESTAMP                          │
└─────────────────┬────────────────────────────────────────────────┘
                  │ 1:N
                  ↓
┌──────────────────────────────────────────────────────────────────┐
│  rotary_billets_categories                                       │
├──────────────────────────────────────────────────────────────────┤
│  • id (PK)                    VARCHAR(50)                        │
│  • evenement_id (FK)          VARCHAR(50)                        │
│  • nom_categorie              VARCHAR(100) (VIP, Standard, etc.) │
│  • prix_unitaire              DECIMAL(12,2)                      │
│  • quantite_disponible        INT                                │
│  • quantite_vendue            INT                                │
│  • couleur_badge              VARCHAR(20)                        │
│  • avantages                  TEXT                               │
└─────────────────┬────────────────────────────────────────────────┘
                  │ 1:N
                  ↓
┌──────────────────────────────────────────────────────────────────┐
│  rotary_billets                                                  │
├──────────────────────────────────────────────────────────────────┤
│  • id (PK)                    VARCHAR(50)                        │
│  • reference_billet (UNIQUE)  VARCHAR(30) (BIL-YYYYMMDD-XXX)    │
│  • evenement_id (FK)          VARCHAR(50)                        │
│  • categorie_id (FK)          VARCHAR(50)                        │
│  • user_id (FK, nullable)     VARCHAR(128)                       │
│  • prenom, nom                VARCHAR(100)                       │
│  • email                      VARCHAR(255)                       │
│  • telephone                  VARCHAR(20)                        │
│  • quantite                   INT                                │
│  • prix_unitaire              DECIMAL(12,2)                      │
│  • montant_total              DECIMAL(12,2)                      │
│  • statut_paiement            ENUM (en_attente, paye, echoue)    │
│  • statut_billet              ENUM (actif, utilise, annule)      │
│  • code_promo                 VARCHAR(50)                        │
│  • montant_reduction          DECIMAL(12,2)                      │
│  • qr_code_url                VARCHAR(500)                       │
│  • created_at, updated_at     TIMESTAMP                          │
└─────────────────┬────────────────────────────────────────────────┘
                  │ 1:N
                  ↓
┌──────────────────────────────────────────────────────────────────┐
│  rotary_transactions                                             │
├──────────────────────────────────────────────────────────────────┤
│  • id (PK)                    VARCHAR(50)                        │
│  • billet_id (FK)             VARCHAR(50)                        │
│  • evenement_id (FK)          VARCHAR(50)                        │
│  • bill_id                    VARCHAR(100) (Ebilling)            │
│  • external_reference         VARCHAR(100) (REF-ROTARY-XXX)     │
│  • montant                    DECIMAL(12,2)                      │
│  • statut                     ENUM (pending, success, failed)    │
│  • payment_method             VARCHAR(50)                        │
│  • payment_provider           VARCHAR(50) (ebilling, shap)       │
│  • payment_details            JSON                               │
│  • webhook_received_at        DATETIME                           │
│  • created_at, updated_at     TIMESTAMP                          │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  rotary_codes_promo                                              │
├──────────────────────────────────────────────────────────────────┤
│  • id (PK)                    VARCHAR(50)                        │
│  • code (UNIQUE)              VARCHAR(50) (ROTARY2026)           │
│  • evenement_id (FK, null)    VARCHAR(50)                        │
│  • type_reduction             ENUM (pourcentage, montant_fixe)   │
│  • valeur_reduction           DECIMAL(10,2)                      │
│  • date_debut, date_fin       DATETIME                           │
│  • utilisation_max            INT                                │
│  • utilisation_actuelle       INT                                │
│  • is_active                  BOOLEAN                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  rotary_email_logs                                               │
├──────────────────────────────────────────────────────────────────┤
│  • id (PK)                    VARCHAR(50)                        │
│  • billet_id (FK)             VARCHAR(50)                        │
│  • recipient_email            VARCHAR(255)                       │
│  • email_type                 ENUM (confirmation, billet, etc.)  │
│  • subject                    VARCHAR(255)                       │
│  • sent_at                    DATETIME                           │
│  • statut                     ENUM (pending, sent, failed)       │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  VUES SQL (pour statistiques)                                    │
├──────────────────────────────────────────────────────────────────┤
│  • rotary_stats_evenements          → Stats par événement        │
│  • rotary_transactions_pending      → Transactions en attente    │
└──────────────────────────────────────────────────────────────────┘
```

## 🔐 Sécurité et Validation

```
┌────────────────────────────────────────────────────────────────┐
│                      COUCHES DE SÉCURITÉ                        │
└────────────────────────────────────────────────────────────────┘

NIVEAU 1: FRONTEND
├─ Validation formulaire (HTML5)
├─ Vérification format email, téléphone
└─ HTTPS obligatoire

NIVEAU 2: BACKEND
├─ Validation des paramètres requis
├─ Vérification disponibilité places
│  └─ quantite_disponible - quantite_vendue >= quantite_demandée
├─ Validation code promo
│  ├─ Date validité
│  ├─ Utilisation max
│  └─ Événement concerné
├─ Prévention injection SQL (parameterized queries)
└─ Rate limiting (TODO)

NIVEAU 3: BASE DE DONNÉES
├─ Contraintes FOREIGN KEY
├─ UNIQUE sur reference_billet
├─ ENUM pour statuts
└─ Transactions ACID

NIVEAU 4: EBILLING
├─ Authentication Basic Auth
├─ HTTPS obligatoire
├─ Webhook signature (TODO)
└─ Timeout gestion
```

## 📊 Statistiques en Temps Réel

```
┌────────────────────────────────────────────────────────────────┐
│                   VUE: rotary_stats_evenements                  │
└────────────────────────────────────────────────────────────────┘

SELECT 
    e.id,
    e.titre,
    e.date_evenement,
    e.capacite_max,
    COUNT(DISTINCT b.id) as total_billets,           ← Nb achats
    SUM(b.quantite) as total_places_vendues,         ← Nb places
    SUM(CASE WHEN b.statut_paiement = 'paye' 
        THEN b.quantite ELSE 0 END) as places_payees,
    SUM(CASE WHEN b.statut_paiement = 'paye' 
        THEN b.montant_total ELSE 0 END) as revenus,  ← Argent
    COUNT(DISTINCT b.email) as participants_uniques  ← Personnes
FROM rotary_evenements e
LEFT JOIN rotary_billets b ON e.id = b.evenement_id
GROUP BY e.id;
```

## 🚀 Déploiement

```
┌────────────────────────────────────────────────────────────────┐
│                    ENVIRONNEMENTS                               │
└────────────────────────────────────────────────────────────────┘

DÉVELOPPEMENT (local)
├─ Database: MySQL local
├─ Backend:  localhost:5000
├─ Ebilling: Lab environment
└─ Test:     test-rotary-frontend.html

PRODUCTION (AWS)
├─ Database: RDS MySQL
├─ Backend:  App Runner (ph8jb63g3p.us-east-1.awsapprunner.com)
├─ Ebilling: Production API
└─ Frontend: Vercel (bantu-house-booking-pwa.vercel.app)

┌────────────────────────────────────────────────────────────────┐
│                    VARIABLES D'ENVIRONNEMENT                    │
└────────────────────────────────────────────────────────────────┘

.env.development
├─ EBILLING_USERNAME=smeby33
├─ EBILLING_SHARED_KEY=0d14ed02-33fc-496b-9e03-04a00563d270
├─ EBILLING_URL=https://lab.billing-easy.net/api/v1/merchant/e_bills
└─ FRONTEND_URL=http://localhost:5173

.env.production
├─ EBILLING_USERNAME=<production_user>
├─ EBILLING_SHARED_KEY=<production_key>
├─ EBILLING_URL=https://billing-easy.net/api/v1/merchant/e_bills
└─ FRONTEND_URL=https://bantu-house-booking-pwa.vercel.app
```

---

**📐 Architecture Version:** 1.0.0  
**🗓️ Date:** 14 janvier 2026  
**👨‍💻 Status:** Production Ready
