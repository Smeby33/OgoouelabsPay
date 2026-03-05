# 🎫 Système de Paiement Rotary Club - Guide Complet

## 📋 Vue d'ensemble

Ce système permet de gérer les paiements en ligne pour les événements du Rotary Club avec :
- Gestion des événements
- Vente de billets avec catégories (VIP, Standard, Étudiant, etc.)
- Paiement en ligne via Ebilling
- Codes promo
- QR codes pour validation
- Statistiques en temps réel

## 🗂️ Structure de la Base de Données

### Tables créées

1. **`rotary_evenements`** - Les événements organisés
2. **`rotary_billets_categories`** - Types de billets (VIP, Standard, etc.)
3. **`rotary_billets`** - Les billets/inscriptions des participants
4. **`rotary_transactions`** - Transactions de paiement
5. **`rotary_codes_promo`** - Codes promotionnels
6. **`rotary_email_logs`** - Historique emails envoyés

### Vues utiles

- **`rotary_stats_evenements`** - Statistiques par événement
- **`rotary_transactions_pending`** - Transactions en attente

## 🚀 Installation

### 1. Créer les tables

```bash
# Exécuter le fichier SQL
mysql -u votre_user -p votre_base < data/rotary_events_system.sql
```

Ou depuis phpMyAdmin, importer le fichier `rotary_events_system.sql`

### 2. Configurer le serveur

Dans votre fichier `server.js`, ajouter la route :

```javascript
const rotaryEventsRoutes = require('./routes/rotaryEventsRoutes');
app.use('/rotary', rotaryEventsRoutes);
```

### 3. Variables d'environnement

Vérifier que ces variables sont définies dans `.env` :

```env
EBILLING_USERNAME=smeby33
EBILLING_SHARED_KEY=0d14ed02-33fc-496b-9e03-04a00563d270
FRONTEND_URL=https://votre-frontend.com
```

## 📡 API Endpoints

### 🎪 Gestion des événements

#### 1. Liste des événements publiés
```http
GET /rotary/events
```

**Réponse :**
```json
{
  "success": true,
  "events": [
    {
      "id": "EV-ROTARY-001",
      "titre": "Gala de Charité 2026",
      "description": "...",
      "date_evenement": "2026-03-15T19:00:00",
      "lieu": "Hôtel Sarakawa",
      "capacite_max": 500,
      "statut": "publie",
      "billets_vendus": 45,
      "places_vendues": 120
    }
  ]
}
```

#### 2. Détails d'un événement
```http
GET /rotary/events/:eventId
```

**Réponse :**
```json
{
  "success": true,
  "event": { ... },
  "categories": [
    {
      "id": "CAT-001",
      "nom_categorie": "VIP",
      "description": "Accès complet + Dîner gastronomique",
      "prix_unitaire": 50000.00,
      "currency_code": "XOF",
      "places_restantes": 30,
      "couleur_badge": "gold",
      "avantages": "Table réservée, cadeau exclusif..."
    },
    {
      "id": "CAT-002",
      "nom_categorie": "Standard",
      "prix_unitaire": 25000.00,
      "places_restantes": 200
    }
  ]
}
```

### 🎫 Gestion des billets

#### 3. Créer un billet et initier le paiement
```http
POST /rotary/tickets/create
Content-Type: application/json
```

**Body :**
```json
{
  "evenement_id": "EV-ROTARY-001",
  "categorie_id": "CAT-001",
  "user_id": "USER123",  // Optionnel si utilisateur connecté
  "prenom": "Jean",
  "nom": "Dupont",
  "email": "jean.dupont@example.com",
  "telephone": "+22890123456",
  "quantite": 2,
  "code_promo": "ROTARY2026",  // Optionnel
  "notes_participant": "Table près de la scène",  // Optionnel
  "besoins_speciaux": "Régime végétarien"  // Optionnel
}
```

**Réponse :**
```json
{
  "success": true,
  "message": "Billet créé avec succès",
  "data": {
    "billet_id": "BILLET-1736876543-A1B2C3D4",
    "reference_billet": "BIL-20260115-ABC123",
    "transaction_id": "TRANS-1736876543-E5F6G7H8",
    "bill_id": "EB123456",
    "payment_url": "https://test.billing-easy.net?invoice=EB123456&redirect_url=...",
    "montant_total": 80000.00,
    "currency_code": "XOF",
    "event": {
      "titre": "Gala de Charité 2026",
      "date": "2026-03-15T19:00:00",
      "lieu": "Hôtel Sarakawa"
    }
  }
}
```

**Important :** Le frontend doit rediriger l'utilisateur vers `payment_url` pour effectuer le paiement.

#### 4. Vérifier le statut d'un billet
```http
GET /rotary/tickets/:reference
```

Exemple : `GET /rotary/tickets/BIL-20260115-ABC123`

**Réponse :**
```json
{
  "success": true,
  "ticket": {
    "id": "BILLET-...",
    "reference_billet": "BIL-20260115-ABC123",
    "prenom": "Jean",
    "nom": "Dupont",
    "email": "jean.dupont@example.com",
    "quantite": 2,
    "montant_total": 80000.00,
    "statut_paiement": "paye",  // en_attente | paye | echoue
    "statut_billet": "actif",   // actif | utilise | annule
    "evenement_titre": "Gala de Charité 2026",
    "date_evenement": "2026-03-15T19:00:00",
    "lieu": "Hôtel Sarakawa",
    "nom_categorie": "VIP",
    "transaction_statut": "success",
    "qr_code_url": "https://..."
  }
}
```

#### 5. Mes billets (tous les billets d'un utilisateur)
```http
GET /rotary/my-tickets?email=jean.dupont@example.com
GET /rotary/my-tickets?user_id=USER123
```

**Réponse :**
```json
{
  "success": true,
  "tickets": [
    {
      "reference_billet": "BIL-20260115-ABC123",
      "evenement_titre": "Gala de Charité 2026",
      "date_evenement": "2026-03-15T19:00:00",
      "statut_paiement": "paye",
      "montant_total": 80000.00
    },
    // ... autres billets
  ]
}
```

### 🎟️ Codes promo

#### 6. Valider un code promo
```http
POST /rotary/validate-promo
Content-Type: application/json
```

**Body :**
```json
{
  "code": "ROTARY2026",
  "evenement_id": "EV-ROTARY-001"  // Optionnel
}
```

**Réponse :**
```json
{
  "valid": true,
  "promo": {
    "code": "ROTARY2026",
    "type_reduction": "pourcentage",
    "valeur_reduction": 20.00,
    "description": "Promotion early bird - 20% de réduction"
  }
}
```

### 📊 Statistiques (Admin)

#### 7. Statistiques d'un événement
```http
GET /rotary/events/:eventId/stats
```

**Réponse :**
```json
{
  "success": true,
  "stats": {
    "evenement_id": "EV-ROTARY-001",
    "titre": "Gala de Charité 2026",
    "capacite_max": 500,
    "total_billets": 45,
    "total_places_vendues": 120,
    "places_payees": 110,
    "revenus_total": 3500000.00,
    "participants_uniques": 42
  },
  "categories": [
    {
      "nom_categorie": "VIP",
      "prix_unitaire": 50000.00,
      "quantite_disponible": 50,
      "quantite_vendue": 20,
      "places_restantes": 30,
      "nb_billets": 15,
      "total_places": 20,
      "revenus": 1000000.00
    }
  ]
}
```

### 🔔 Webhook (Automatique)

```http
POST /rotary/webhook
```

Cette route est appelée automatiquement par Ebilling quand un paiement change de statut.
**Ne pas appeler manuellement.**

## 🔄 Flux de paiement complet

### Schéma du processus

```
1. UTILISATEUR
   ↓ Choisit événement + catégorie
   
2. FRONTEND
   ↓ POST /rotary/tickets/create
   
3. BACKEND
   ↓ Crée billet (statut: en_attente)
   ↓ Crée transaction (statut: pending)
   ↓ Appelle API Ebilling
   ↓ Retourne payment_url
   
4. FRONTEND
   ↓ Redirige vers payment_url
   
5. EBILLING
   ↓ Utilisateur paie
   ↓ Webhook → POST /rotary/webhook
   
6. BACKEND
   ↓ Met à jour transaction (statut: success)
   ↓ Met à jour billet (statut_paiement: paye)
   ↓ Envoie email avec QR code
   
7. UTILISATEUR
   ↓ Reçoit email de confirmation
   ✓ Possède billet avec QR code
```

### Exemple d'intégration Frontend (React)

```javascript
// 1. Créer le billet et obtenir le lien de paiement
const handleAchatBillet = async (formData) => {
  try {
    const response = await fetch('/rotary/tickets/create', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        evenement_id: 'EV-ROTARY-001',
        categorie_id: 'CAT-001',
        prenom: formData.prenom,
        nom: formData.nom,
        email: formData.email,
        telephone: formData.telephone,
        quantite: formData.quantite,
        code_promo: formData.codePromo || null
      })
    });
    
    const data = await response.json();
    
    if (data.success) {
      // Sauvegarder la référence localement
      localStorage.setItem('current_ticket_ref', data.data.reference_billet);
      
      // Rediriger vers la page de paiement Ebilling
      window.location.href = data.data.payment_url;
    } else {
      alert('Erreur: ' + data.error);
    }
  } catch (error) {
    console.error('Erreur:', error);
  }
};

// 2. Page de retour après paiement
const PaymentResultPage = () => {
  const [ticket, setTicket] = useState(null);
  const ticketRef = new URLSearchParams(window.location.search).get('ref');
  
  useEffect(() => {
    // Vérifier le statut du billet
    const checkStatus = async () => {
      const response = await fetch(`/rotary/tickets/${ticketRef}`);
      const data = await response.json();
      
      if (data.success) {
        setTicket(data.ticket);
      }
    };
    
    if (ticketRef) {
      checkStatus();
      // Vérifier toutes les 3 secondes jusqu'à confirmation
      const interval = setInterval(checkStatus, 3000);
      return () => clearInterval(interval);
    }
  }, [ticketRef]);
  
  return (
    <div>
      {ticket?.statut_paiement === 'paye' ? (
        <div>
          <h2>✅ Paiement confirmé !</h2>
          <p>Référence: {ticket.reference_billet}</p>
          <p>Événement: {ticket.evenement_titre}</p>
          <p>Date: {new Date(ticket.date_evenement).toLocaleDateString()}</p>
          <img src={ticket.qr_code_url} alt="QR Code" />
        </div>
      ) : (
        <div>
          <h2>⏳ Vérification du paiement...</h2>
          <p>Veuillez patienter...</p>
        </div>
      )}
    </div>
  );
};
```

## 🎨 Personnalisation

### Ajouter un nouveau type d'événement

Dans la table `rotary_evenements`, modifier l'enum `type_evenement` :

```sql
ALTER TABLE rotary_evenements 
MODIFY COLUMN type_evenement ENUM(
  'conference',
  'gala',
  'formation',
  'collecte_fonds',
  'activite_sociale',
  'reunion',
  'webinaire',  -- NOUVEAU
  'autres'
) NOT NULL DEFAULT 'conference';
```

### Ajouter une méthode de paiement

Modifier l'enum `payment_method` dans `rotary_transactions` :

```sql
ALTER TABLE rotary_transactions 
ADD COLUMN payment_method VARCHAR(50) DEFAULT 'mobile_money' 
COMMENT 'mobile_money, carte, virement, especes, paypal';
```

## 🔒 Sécurité

### Recommandations

1. **Variables d'environnement** : Ne jamais commiter les credentials Ebilling
2. **Validation** : Toujours valider les données côté backend
3. **Webhook** : Vérifier la signature Ebilling (TODO)
4. **Rate limiting** : Limiter les appels API pour éviter les abus
5. **HTTPS** : Toujours utiliser HTTPS en production

### Exemple de middleware de protection

```javascript
// Middleware pour protéger les routes admin
const isAdmin = async (req, res, next) => {
  const userId = req.headers['x-user-id'];
  // Vérifier si l'utilisateur est admin
  const [users] = await db.query(
    'SELECT role FROM users WHERE id = ?', 
    [userId]
  );
  
  if (users[0]?.role === 'admin') {
    next();
  } else {
    res.status(403).json({ error: 'Accès refusé' });
  }
};

// Protéger la route des statistiques
router.get('/events/:eventId/stats', isAdmin, async (req, res) => {
  // ...
});
```

## 📧 Notifications Email (À implémenter)

### Intégration avec emailService.js

```javascript
const emailService = require('../emailService');

// Après confirmation de paiement
if (new_status === 'success') {
  const [billets] = await db.query(`
    SELECT b.*, e.titre, e.date_evenement, e.lieu
    FROM rotary_billets b
    INNER JOIN rotary_evenements e ON b.evenement_id = e.id
    WHERE b.id = ?
  `, [transaction.billet_id]);
  
  const billet = billets[0];
  
  await emailService.sendEmail({
    to: billet.email,
    subject: `✅ Votre billet pour ${billet.titre}`,
    html: `
      <h1>Confirmation de votre billet</h1>
      <p>Bonjour ${billet.prenom} ${billet.nom},</p>
      <p>Votre paiement a été confirmé !</p>
      <p><strong>Référence:</strong> ${billet.reference_billet}</p>
      <p><strong>Événement:</strong> ${billet.titre}</p>
      <p><strong>Date:</strong> ${new Date(billet.date_evenement).toLocaleString()}</p>
      <p><strong>Lieu:</strong> ${billet.lieu}</p>
      <img src="${billet.qr_code_url}" alt="QR Code" />
    `
  });
  
  // Logger l'envoi
  await db.query(`
    INSERT INTO rotary_email_logs 
    (id, billet_id, recipient_email, email_type, subject, sent_at, statut)
    VALUES (?, ?, ?, 'billet_envoye', ?, NOW(), 'sent')
  `, [
    generateId('EMAIL'),
    billet.id,
    billet.email,
    `✅ Votre billet pour ${billet.titre}`
  ]);
}
```

## 🐛 Débogage

### Logs utiles

Tous les logs sont préfixés avec `🎫 [ROTARY]` pour faciliter le filtrage.

```bash
# Filtrer les logs Rotary dans les logs du serveur
grep "ROTARY" server.log

# Voir uniquement les webhooks
grep "🔔 \[POST /webhook\]" server.log

# Voir les erreurs
grep "❌" server.log | grep "ROTARY"
```

### Vérifier manuellement le statut d'une transaction

```sql
SELECT 
  t.external_reference,
  t.montant,
  t.statut as transaction_statut,
  b.reference_billet,
  b.statut_paiement as billet_statut,
  e.titre as evenement
FROM rotary_transactions t
INNER JOIN rotary_billets b ON t.billet_id = b.id
INNER JOIN rotary_evenements e ON t.evenement_id = e.id
WHERE t.external_reference = 'REF-ROTARY-XXXXX';
```

## 📞 Support

Pour toute question :
- Consulter les logs avec les emojis de débogage
- Vérifier les données dans les tables
- Tester avec les données de test fournies dans `rotary_events_system.sql`

## 🚀 Améliorations futures

- [ ] Génération automatique de QR codes
- [ ] Envoi automatique d'emails
- [ ] Interface admin pour gérer les événements
- [ ] Scan des billets via app mobile
- [ ] Remboursements automatiques
- [ ] Export des participants (CSV/Excel)
- [ ] Rappels automatiques avant événement
- [ ] Certificats de participation PDF
- [ ] Intégration calendrier (Google Calendar, Outlook)

---

**Version:** 1.0.0  
**Date:** 14 janvier 2026  
**Auteur:** Système Rotary Club Payment
