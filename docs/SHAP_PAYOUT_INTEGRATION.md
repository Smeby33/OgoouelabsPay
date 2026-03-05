# 💰 Système de Remboursement de Caution (SHAP Payout)

## 📋 Vue d'ensemble

Ce système permet de rembourser automatiquement les cautions versées par les clients à la fin de leur séjour via l'API SHAP Merchant.

## 🏗️ Architecture

```
┌─────────────────┐
│  Frontend PWA   │
└────────┬────────┘
         │
         │ POST /shap/refund-caution
         ▼
┌─────────────────┐
│  Backend API    │ ◄─── POST /shap/webhook ◄─── SHAP
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Base de données│
│  - payouts      │
│  - reservations │
└─────────────────┘
```

## 🔧 Configuration requise

### 1. Variables d'environnement

Ajouter dans votre fichier `.env` :

```bash
# SHAP Payout Configuration
SHAP_API_ID=votre_api_id
SHAP_API_SECRET=votre_api_secret
SHAP_BASE_URL=https://test.billing-easy.net/shap/api/v1/merchant
SHAP_CALLBACK_URL=https://votre-domaine.com/transactions/shap/webhook
```

### 2. Migration base de données

Exécuter le fichier SQL :

```bash
mysql -u root -p villa_db < data/payouts_migration.sql
```

## 📡 API Endpoints

### 1. Vérifier le solde SHAP

```http
GET /transactions/shap/check-balance
```

**Réponse:**
```json
{
  "balance": {
    "airtelmoney": 50000,
    "moovmoney": 30000
  }
}
```

### 2. Rembourser une caution

```http
POST /transactions/shap/refund-caution
Content-Type: application/json

{
  "reservation_id": 123,
  "reservation_type": "evenement",
  "payment_system_name": "airtelmoney"
}
```

**Réponse:**
```json
{
  "success": true,
  "message": "Remboursement de caution initié avec succès",
  "payout": {
    "transaction_id": "SHAP-123456",
    "status": "pending"
  },
  "external_reference": "REFUND-CAUTION-123-1703779200000",
  "amount": 50000,
  "beneficiary": {
    "name": "Jean Dupont",
    "phone": "+24106123456"
  }
}
```

### 3. Webhook SHAP (Callback)

```http
POST /transactions/shap/webhook
Content-Type: application/json

{
  "external_reference": "REFUND-CAUTION-123-1703779200000",
  "status": "success",
  "transaction_id": "SHAP-123456"
}
```

### 4. Consulter l'état des remboursements

```http
GET /transactions/caution-refunds/:reservation_id
```

**Réponse:**
```json
{
  "reservation_id": 123,
  "refunds_count": 1,
  "refunds": [
    {
      "id": 1,
      "external_reference": "REFUND-CAUTION-123-1703779200000",
      "amount": 50000,
      "status": "completed",
      "created_at": "2025-12-28T10:00:00",
      "completed_at": "2025-12-28T10:05:00"
    }
  ]
}
```

## 🔄 Flux de remboursement

### Scénario 1: Remboursement automatique (via Cron)

```
1. Cron job vérifie les réservations terminées (date_fin < aujourd'hui)
2. Filtre: cautionStatus = 'versé' ET caution_refund_status IS NULL
3. Pour chaque réservation éligible:
   a. Appelle POST /shap/refund-caution
   b. Met à jour caution_refund_status = 'pending'
4. SHAP traite le payout
5. SHAP envoie callback POST /shap/webhook
6. Backend met à jour:
   - payouts.status = 'completed'
   - reservations.caution_refund_status = 'refunded'
7. Email de confirmation envoyé au client
```

### Scénario 2: Remboursement manuel (Admin)

```
1. Admin accède au dashboard
2. Consulte la liste des cautions à rembourser
3. Clique sur "Rembourser" pour une réservation
4. Frontend appelle POST /shap/refund-caution
5. Suite du flux identique au scénario 1 (étapes 4-7)
```

## 🧪 Tests

### Tests manuels

```bash
# Test 1: Vérifier le solde
curl http://localhost:5000/transactions/shap/check-balance

# Test 2: Initier un remboursement
curl -X POST http://localhost:5000/transactions/shap/refund-caution \
  -H "Content-Type: application/json" \
  -d '{
    "reservation_id": 1,
    "reservation_type": "evenement",
    "payment_system_name": "airtelmoney"
  }'

# Test 3: Consulter l'état
curl http://localhost:5000/transactions/caution-refunds/1
```

### Tests automatisés

```bash
node scripts/testShapPayout.js
```

## 📊 Requêtes SQL utiles

### Voir toutes les cautions à rembourser

```sql
SELECT * FROM vue_cautions_a_rembourser;
```

### Statistiques des remboursements

```sql
SELECT 
    status,
    COUNT(*) as nombre,
    SUM(amount) as montant_total
FROM payouts
GROUP BY status;
```

### Cautions en échec (à traiter manuellement)

```sql
SELECT 
    p.*,
    r.date_fin,
    u.full_name,
    u.phone_number,
    u.email
FROM payouts p
JOIN reservations_evenements r ON p.reservation_id = r.id
JOIN users u ON r.user_id = u.id
WHERE p.status = 'failed'
  AND p.reservation_type = 'evenement';
```

## ⚠️ Gestion des erreurs

### Erreurs courantes

| Code | Erreur | Solution |
|------|--------|----------|
| SP0011 | Montant non numérique | Vérifier que cautionMontant est un nombre |
| SP0014 | Type de payout manquant | Vérifier que `payout_type = 'refund'` est bien envoyé |
| SP0016 | Solde insuffisant | Recharger le compte marchand SHAP |
| 401 | Token invalide | Le token sera automatiquement rafraîchi |

### Retry automatique

Le système ne fait pas de retry automatique. En cas d'échec :

1. Le statut passe à `failed`
2. Un admin doit intervenir manuellement
3. Consulter `payouts.error_message` pour diagnostiquer
4. Relancer le remboursement si nécessaire

## 🔐 Sécurité

- ✅ Token OAuth 2.0 avec expiration 2h
- ✅ Refresh automatique du token
- ✅ Validation des montants (minimum 100 FCFA)
- ✅ Vérification du statut avant remboursement
- ✅ Logs détaillés de toutes les opérations
- ✅ Callback sécurisé via URL dédiée

## 📅 Cron Job (À implémenter)

Créer un fichier `jobs/refundCautionsCron.js` :

```javascript
const cron = require('node-cron');
const axios = require('axios');

// Exécuter tous les jours à 3h du matin
cron.schedule('0 3 * * *', async () => {
    console.log('🕒 [CRON] Vérification des cautions à rembourser...');
    
    try {
        const response = await axios.get('http://localhost:5000/api/cautions-eligibles');
        const reservations = response.data;
        
        for (const reservation of reservations) {
            await axios.post('http://localhost:5000/transactions/shap/refund-caution', {
                reservation_id: reservation.id,
                reservation_type: reservation.type
            });
        }
        
        console.log(`✅ [CRON] ${reservations.length} remboursements initiés`);
    } catch (err) {
        console.error('❌ [CRON] Erreur:', err.message);
    }
});
```

Lancer le cron :

```bash
node jobs/refundCautionsCron.js
```

Ou avec PM2 :

```bash
pm2 start jobs/refundCautionsCron.js --name "caution-refund-cron"
```

## 📧 Notifications

### Email client (remboursement réussi)

TODO: Implémenter dans le webhook après `status = 'completed'`

```javascript
await sendEmail({
    to: reservation.payer_email,
    subject: '✅ Votre caution a été remboursée - Villa Mashaï',
    html: `...`
});
```

### Email admin (échec de remboursement)

TODO: Implémenter dans le webhook après `status = 'failed'`

```javascript
await sendEmail({
    to: 'admin@villamashai.com',
    subject: '⚠️ Échec remboursement caution - Réservation #' + reservation_id,
    html: `...`
});
```

## 🚀 Prochaines étapes

- [ ] Implémenter le cron job automatique
- [ ] Ajouter les emails de notification
- [ ] Créer l'interface admin pour gestion manuelle
- [ ] Ajouter des statistiques dans le dashboard
- [ ] Implémenter le retry automatique (max 3 tentatives)
- [ ] Ajouter des alertes Slack/Discord pour les admins

## 📞 Support

Pour toute question concernant l'API SHAP :
- Documentation : https://test.billing-easy.net/docs
- Support : support@billing-easy.net

---

**Date de création:** 28 décembre 2025  
**Version:** 1.0.0  
**Auteur:** Villa Mashaï Dev Team
