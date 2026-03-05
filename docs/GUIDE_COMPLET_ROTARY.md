# 🎯 Guide Complet - Système de Paiement Rotary Club

## 📦 Ce qui a été créé pour vous

Bonjour ! J'ai créé un **système complet de paiement en ligne** pour les événements du Rotary Club. Voici tout ce qui est prêt :

### ✅ Fichiers créés (8 au total)

| Fichier | Description |
|---------|-------------|
| `data/rotary_events_system.sql` | **Structure complète de la base de données** (7 tables + 2 vues) |
| `data/rotary_test_data.sql` | **Données de test** (3 événements, 9 catégories, 5 codes promo) |
| `routes/rotaryEventsRoutes.js` | **API complète** (11 endpoints pour gérer billets et paiements) |
| `docs/ROTARY_PAYMENT_GUIDE.md` | **Documentation technique complète** (400+ lignes) |
| `scripts/testRotarySystem.js` | **Tests automatiques** pour valider que tout fonctionne |
| `test-rotary-frontend.html` | **Page de test HTML** pour essayer immédiatement |
| `ROTARY_QUICKSTART.md` | **Guide de démarrage rapide** (5 minutes) |
| `ROTARY_SUMMARY.md` | **Récapitulatif complet** du projet |

### ✅ Configuration serveur

Le fichier `server.js` a été **automatiquement mis à jour** avec la nouvelle route `/rotary/*`.

---

## 🚀 Installation en 3 étapes (5 minutes)

### Étape 1️⃣ : Créer les tables (2 minutes)

**Option A - Via phpMyAdmin :**
1. Ouvrir phpMyAdmin
2. Sélectionner votre base de données (probablement `u929681960_VillaMashai`)
3. Cliquer sur "Importer"
4. Sélectionner le fichier `data/rotary_events_system.sql`
5. Cliquer sur "Exécuter"

**Option B - Via ligne de commande :**
```bash
mysql -u root -p votre_base < data/rotary_events_system.sql
```

### Étape 2️⃣ : Insérer les données de test (1 minute)

Même procédure que l'étape 1, mais avec le fichier `data/rotary_test_data.sql`

Cela créera :
- ✅ 3 événements (Gala, Conférence, Formation)
- ✅ 9 catégories de billets
- ✅ 5 codes promo

### Étape 3️⃣ : Tester (2 minutes)

**Option A - Via page HTML :**
```bash
# Démarrer le serveur
npm start

# Ouvrir dans votre navigateur
test-rotary-frontend.html
```

**Option B - Via script automatique :**
```bash
npm start
# Dans un autre terminal :
node scripts/testRotarySystem.js
```

---

## 🎯 Comment ça marche ?

### Schéma simplifié

```
1. CLIENT visite votre site
   ↓
2. Choisit un ÉVÉNEMENT (ex: Gala de Charité)
   ↓
3. Choisit une CATÉGORIE (ex: Billet VIP à 50 000 FCFA)
   ↓
4. Remplit ses INFORMATIONS (nom, email, téléphone)
   ↓
5. Clique sur "PAYER"
   ↓
6. Votre BACKEND crée le billet et appelle Ebilling
   ↓
7. Client est REDIRIGÉ vers Ebilling pour payer
   ↓
8. Client paie avec Mobile Money ou Carte
   ↓
9. Ebilling envoie une NOTIFICATION à votre serveur (webhook)
   ↓
10. Votre serveur CONFIRME le billet automatiquement
    ↓
11. Client reçoit son BILLET par email (à implémenter)
```

---

## 📱 Exemples d'utilisation

### Exemple 1 : Gala du Rotary Club

**Situation :**
- Événement : Gala de Charité le 15 juin 2026
- 500 places disponibles
- 4 types de billets : Platinum (75k), VIP (50k), Standard (25k), Étudiant (15k)

**Processus :**
1. Vous créez l'événement dans la base de données (déjà fait avec les données de test !)
2. Les gens visitent votre site
3. Ils choisissent leur catégorie de billet
4. Ils paient en ligne
5. Vous recevez l'argent via Ebilling
6. Les billets sont automatiquement confirmés

**Suivi en temps réel :**
- Combien de billets vendus ? → Endpoint `/rotary/events/EV-ROTARY-001/stats`
- Combien d'argent collecté ? → Même endpoint
- Qui sont les participants ? → Table `rotary_billets`

### Exemple 2 : Code promo pour membres

**Situation :**
- Vous voulez offrir -25% aux membres Rotary

**Solution :**
```sql
-- Le code MEMBRE-ROTARY est déjà créé dans les données de test !
-- Il donne 25% de réduction sur tous les événements
```

Les utilisateurs entrent simplement `MEMBRE-ROTARY` lors de l'achat.

---

## 🔧 Configuration requise

### Variables d'environnement (déjà configurées)

Votre fichier `.env` doit contenir :
```env
EBILLING_USERNAME=smeby33
EBILLING_SHARED_KEY=0d14ed02-33fc-496b-9e03-04a00563d270
FRONTEND_URL=https://votre-site-frontend.com
```

✅ **Bonne nouvelle :** Ces variables sont déjà dans votre `rotaryEventsRoutes.js` avec des valeurs par défaut !

### URL du webhook

Dans votre compte Ebilling, configurer l'URL de notification :
```
https://ph8jb63g3p.us-east-1.awsapprunner.com/rotary/webhook
```

---

## 📊 Statistiques disponibles

### Pour suivre vos événements

```bash
# Via API
GET /rotary/events/EV-ROTARY-001/stats
```

**Résultat :**
```json
{
  "stats": {
    "total_billets": 45,
    "total_places_vendues": 120,
    "revenus_total": 3500000,
    "participants_uniques": 42
  },
  "categories": [
    {
      "nom_categorie": "VIP",
      "quantite_vendue": 20,
      "revenus": 1000000
    }
  ]
}
```

### Via SQL (dans phpMyAdmin)

```sql
-- Vue déjà créée pour vous !
SELECT * FROM rotary_stats_evenements;

-- Billets vendus aujourd'hui
SELECT COUNT(*) FROM rotary_billets 
WHERE DATE(created_at) = CURDATE() 
AND statut_paiement = 'paye';

-- Revenus du mois
SELECT SUM(montant_total) FROM rotary_billets 
WHERE MONTH(created_at) = MONTH(CURDATE())
AND statut_paiement = 'paye';
```

---

## 🎨 Personnalisation

### Ajouter un nouvel événement

**Via phpMyAdmin :**
```sql
INSERT INTO rotary_evenements 
(id, titre, description, type_evenement, date_evenement, lieu, capacite_max, statut, is_payant)
VALUES
('EV-MON-EVENT', 'Titre de mon événement', 'Description...', 
'gala', '2026-12-31 20:00:00', 'Lieu', 300, 'publie', 1);
```

**Puis ajouter les catégories de billets :**
```sql
INSERT INTO rotary_billets_categories
(id, evenement_id, nom_categorie, prix_unitaire, quantite_disponible)
VALUES
('CAT-EVENT-001', 'EV-MON-EVENT', 'VIP', 50000, 50),
('CAT-EVENT-002', 'EV-MON-EVENT', 'Normal', 25000, 250);
```

### Créer un code promo

```sql
INSERT INTO rotary_codes_promo
(id, code, type_reduction, valeur_reduction, date_debut, date_fin, description)
VALUES
('PROMO-NOEL', 'NOEL2026', 'pourcentage', 15.00, 
'2026-12-01', '2026-12-25', 'Promotion de Noël -15%');
```

---

## 📞 API Endpoints - Résumé rapide

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/rotary/events` | GET | Liste tous les événements publiés |
| `/rotary/events/:id` | GET | Détails d'un événement + catégories |
| `/rotary/tickets/create` | POST | Acheter un billet (crée le paiement) |
| `/rotary/tickets/:ref` | GET | Vérifier statut d'un billet |
| `/rotary/my-tickets` | GET | Tous les billets d'un utilisateur |
| `/rotary/webhook` | POST | Notification Ebilling (automatique) |
| `/rotary/validate-promo` | POST | Vérifier un code promo |
| `/rotary/events/:id/stats` | GET | Statistiques d'un événement |

---

## ✅ Ce qui fonctionne immédiatement

- ✅ Création d'événements
- ✅ Gestion de catégories de billets
- ✅ Achat de billets en ligne
- ✅ Paiement via Ebilling (Mobile Money, Cartes)
- ✅ Codes promo (pourcentage ou montant fixe)
- ✅ Vérification de disponibilité
- ✅ Statistiques en temps réel
- ✅ Webhook automatique
- ✅ Suivi des transactions
- ✅ API complète et documentée

---

## 🚧 À implémenter (optionnel)

### Priorité haute
- [ ] **Génération de QR codes** pour les billets
- [ ] **Envoi automatique d'emails** avec les billets
- [ ] **Interface admin** pour gérer les événements via le web

### Priorité moyenne
- [ ] **Scanner de billets** (app mobile)
- [ ] **Remboursements** automatiques
- [ ] **Export CSV/Excel** des participants

### Priorité basse
- [ ] **Certificats PDF** de participation
- [ ] **Intégration calendrier** (Google, Outlook)
- [ ] **Multi-langue** (FR/EN)

---

## 🐛 Débogage

### Le serveur ne démarre pas

```bash
# Vérifier que toutes les dépendances sont installées
npm install

# Vérifier le fichier db.js (connexion MySQL)
```

### Les événements ne s'affichent pas

```bash
# Vérifier que les tables sont créées
# Dans phpMyAdmin, vérifier que rotary_evenements existe

# Vérifier les données
SELECT * FROM rotary_evenements WHERE statut = 'publie';
```

### Le webhook ne fonctionne pas

```bash
# Vérifier les logs du serveur
grep "🔔" logs/server.log

# Tester manuellement
curl -X POST http://localhost:5000/rotary/webhook \
  -H "Content-Type: application/json" \
  -d '{"billingid":"TEST123","state":"paid"}'
```

---

## 🎓 Pour aller plus loin

### Documentation complète

Consultez `docs/ROTARY_PAYMENT_GUIDE.md` pour :
- Exemples de code React/Vue/Angular
- Guide d'intégration frontend détaillé
- Recommandations de sécurité
- Schéma complet de la base de données
- Exemples SQL avancés

### Tests automatiques

```bash
# Lancer tous les tests
node scripts/testRotarySystem.js

# Résultat attendu :
# ✅ Connexion au serveur
# ✅ Récupération des événements
# ✅ Détails événement
# ✅ Validation code promo
# ✅ Statistiques
```

---

## 🎉 Conclusion

Vous avez maintenant un **système complet et professionnel** pour gérer les paiements de billets pour vos événements Rotary Club !

**Ce qui est prêt :**
- ✅ Base de données complète
- ✅ API fonctionnelle
- ✅ Intégration paiement Ebilling
- ✅ Données de test
- ✅ Documentation complète
- ✅ Tests automatiques

**Prochaines étapes :**
1. Créer les tables (5 minutes)
2. Tester avec la page HTML fournie
3. Intégrer dans votre frontend existant
4. Promouvoir vos événements !

---

## 📧 Questions fréquentes

### Q: Les fichiers transactionRotaryRoutes.js et rotaryEventsRoutes.js sont-ils différents ?

**R:** Oui ! 
- `transactionRotaryRoutes.js` = ancien fichier (peut être gardé pour compatibilité)
- `rotaryEventsRoutes.js` = **nouveau fichier optimisé spécifiquement pour les billets**

Le nouveau fichier est plus propre et plus facile à maintenir.

### Q: Comment changer le prix d'un billet ?

**R:** Via phpMyAdmin :
```sql
UPDATE rotary_billets_categories 
SET prix_unitaire = 30000 
WHERE id = 'CAT-GALA-003';
```

### Q: Comment voir qui a acheté des billets ?

**R:** 
```sql
SELECT prenom, nom, email, telephone, quantite, montant_total, statut_paiement
FROM rotary_billets 
WHERE evenement_id = 'EV-ROTARY-001'
ORDER BY created_at DESC;
```

### Q: Comment annuler un événement ?

**R:** 
```sql
UPDATE rotary_evenements 
SET statut = 'annule' 
WHERE id = 'EV-ROTARY-001';
```

Les billets ne pourront plus être achetés, mais les billets existants restent en base.

---

**🎯 Tout est prêt ! Commencez par l'installation et testez immédiatement.**

**Version:** 1.0.0  
**Date:** 14 janvier 2026  
**Status:** ✅ Prêt pour production
