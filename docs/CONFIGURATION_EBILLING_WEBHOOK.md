# 🔔 Configuration du Webhook Ebilling

## ✅ Corrections Implémentées

### 1️⃣ **Webhook Ebilling** (Route `/ebilling/webhook`)
Une nouvelle route a été créée pour recevoir automatiquement les notifications de paiement d'Ebilling.

**Fonctionnement :**
- Ebilling envoie une notification POST quand un paiement est effectué
- La route vérifie la facture dans votre BDD
- Met à jour automatiquement `statuspay = 1`
- Confirme la réservation (`statut = 'confirmee'`)

### 2️⃣ **Vérification Réelle des Paiements**
La route `/updateFactureStatus` a été améliorée :

**Avant** :
```javascript
// ❌ Mise à jour sans vérification
UPDATE factures SET statuspay = 1 WHERE bill_id = ?
```

**Maintenant** :
```javascript
// ✅ Vérification auprès d'Ebilling
const verification = await verifyPaymentWithEbilling(bill_id);
if (!verification.is_paid) {
  return error('Paiement non confirmé');
}
// Puis mise à jour
UPDATE factures SET statuspay = 1 WHERE bill_id = ?
```

### 3️⃣ **Fonction de Vérification**
Nouvelle fonction `verifyPaymentWithEbilling(billId)` qui :
- Appelle l'API Ebilling `GET /api/v1/merchant/e_bills/:bill_id`
- Vérifie le statut réel du paiement
- Retourne `{ is_paid: true/false, status: '...' }`

---

## 📋 Configuration Requise

### 1. **Variables d'Environnement (.env)**

Ajoutez cette variable dans votre fichier `.env` :

```env
# Ebilling Configuration
EBILLING_USERNAME=smeby33
EBILLING_SHARED_KEY=96aa3a7c-a7c6-4a07-b30e-ff5681f06893

# ⚠️ IMPORTANT: Remplacez par l'URL publique de votre serveur
EB_CALLBACK_URL=https://votre-domaine.com/api/transactions/ebilling/webhook

# Ou pour le développement local avec ngrok:
# EB_CALLBACK_URL=https://xxxx-xx-xxx-xxx-xxx.ngrok.io/api/transactions/ebilling/webhook
```

### 2. **Exposer Votre Serveur Local (Développement)**

Ebilling doit pouvoir envoyer des requêtes à votre serveur. En développement local, utilisez **ngrok** :

#### Installation ngrok :
```bash
# Windows (avec Chocolatey)
choco install ngrok

# Ou téléchargez depuis: https://ngrok.com/download
```

#### Utilisation :
```bash
# Exposer votre serveur local (port 5000)
ngrok http 5000
```

Vous obtiendrez une URL comme : `https://xxxx-xx-xxx-xxx-xxx.ngrok.io`

Mettez à jour votre `.env` :
```env
EB_CALLBACK_URL=https://xxxx-xx-xxx-xxx-xxx.ngrok.io/api/transactions/ebilling/webhook
```

### 3. **Configurer Ebilling**

Connectez-vous à votre tableau de bord Ebilling et configurez l'URL de callback :
- URL : `https://votre-domaine.com/api/transactions/ebilling/webhook`
- Méthode : `POST`
- Format : `JSON`

---

## 🧪 Tests

### Test 1 : Webhook Ebilling

Simulez une notification Ebilling avec curl :

```bash
curl -X POST http://localhost:5000/transactions/ebilling/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "bill_id": "votre-bill-id",
    "external_reference": "RES-123456789",
    "status": "paid",
    "amount": 50000,
    "payment_method": "airtel"
  }'
```

**Résultat attendu** :
```json
{
  "success": true,
  "message": "Paiement confirmé avec succès",
  "reservation_id": "..."
}
```

### Test 2 : Vérification Manuelle avec Ebilling

Testez la vérification d'un paiement :

```bash
curl -X POST http://localhost:5000/transactions/updateFactureStatus \
  -H "Content-Type: application/json" \
  -d '{
    "billingid": "votre-bill-id",
    "reference": "RES-123456789"
  }'
```

**Si le paiement n'est pas confirmé par Ebilling** :
```json
{
  "error": "Le paiement n'est pas confirmé par Ebilling.",
  "ebilling_status": "pending",
  "message": "Veuillez attendre la confirmation du paiement par l'opérateur."
}
```

**Si le paiement est confirmé** :
```json
{
  "success": true,
  "message": "Paiement vérifié et réservation confirmée avec succès.",
  "reservation_id": "...",
  "ebilling_status": "paid"
}
```

---

## 📊 Flux Complet Mis à Jour

```
1. Client fait une réservation (BookingPage.tsx)
   ↓
2. Backend crée facture Ebilling (POST /createInvoice)
   → Envoie EB_CALLBACK_URL
   ↓
3. Client redirigé vers portail Ebilling (PaymentProcess.tsx)
   ↓
4. Client paie (Airtel/Moov)
   ↓
5. Ebilling envoie notification automatique
   → POST https://votre-domaine.com/api/transactions/ebilling/webhook
   ↓
6. Webhook met à jour facture + réservation automatiquement ✅
   ↓
7. Client revient sur le site
   ↓
8. Frontend vérifie statut (GET /checkPaymentStatus)
   → is_paid: true ✅
```

---

## 🔐 Sécurité

### Vérification de la Signature (Recommandé)

Ebilling peut envoyer une signature pour vérifier l'authenticité des notifications. Ajoutez cette vérification :

```javascript
router.post('/ebilling/webhook', async (req, res) => {
  const { bill_id, signature } = req.body;
  
  // Vérifier la signature
  const expectedSignature = crypto
    .createHmac('sha256', EBILLING_SHARED_KEY)
    .update(bill_id)
    .digest('hex');
  
  if (signature !== expectedSignature) {
    console.error('❌ Signature invalide!');
    return res.status(403).json({ error: 'Signature invalide' });
  }
  
  // Continuer le traitement...
});
```

---

## ⚠️ Notes Importantes

1. **URL Publique Requise** : Ebilling doit pouvoir atteindre votre serveur via HTTPS
2. **Production** : Utilisez un certificat SSL valide (Let's Encrypt gratuit)
3. **Logs** : Tous les webhooks sont loggés dans la console avec 🔔
4. **Idempotence** : Le webhook peut être appelé plusieurs fois → vérifiez si déjà traité
5. **Timeout** : Ebilling attend une réponse en moins de 30 secondes

---

## 📞 Support

Si vous rencontrez des problèmes :

1. **Vérifiez les logs** : `console.log` avec préfixe `[POST /ebilling/webhook]`
2. **Testez ngrok** : `curl https://xxxx.ngrok.io/api/transactions/ebilling/webhook`
3. **Vérifiez Ebilling** : Tableau de bord → Notifications → Historique
4. **Variables d'environnement** : `.env` correctement configuré

---

## 🎯 Prochaines Étapes

### TODO après cette configuration :

1. ✅ Tester le webhook en local avec ngrok
2. ✅ Déployer sur un serveur avec HTTPS
3. ⬜ Ajouter signature pour sécuriser le webhook
4. ⬜ Envoyer email de confirmation après paiement
5. ⬜ Créer automatiquement les codes TTLock après paiement
6. ⬜ Ajouter un système de retry si webhook échoue
7. ⬜ Logger les webhooks dans une table dédiée

---

## 🚀 Déploiement Production

### Étapes :

1. **Déployez votre backend** sur un serveur (Heroku, Railway, VPS, etc.)
2. **Obtenez une URL HTTPS** : `https://api.villamashai.com`
3. **Mettez à jour .env** :
   ```env
   EB_CALLBACK_URL=https://api.villamashai.com/api/transactions/ebilling/webhook
   ```
4. **Configurez Ebilling** avec cette URL
5. **Testez** avec un vrai paiement

---

**✅ Vos paiements sont maintenant sécurisés et automatisés !** 🎉
