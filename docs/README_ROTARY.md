# 🎫 Système de Paiement en Ligne - Événements Rotary Club

> **Système complet de billetterie en ligne avec paiement Mobile Money et Carte bancaire**

---

## 📚 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Installation rapide](#installation-rapide)
3. [Structure du projet](#structure-du-projet)
4. [Documentation](#documentation)
5. [Tests](#tests)
6. [Support](#support)

---

## 🎯 Vue d'ensemble

Ce système permet au **Rotary Club** de vendre des billets en ligne pour ses événements avec :

✅ **Gestion complète d'événements**
- Création d'événements (gala, conférence, formation, etc.)
- Catégories de billets multiples (VIP, Standard, Étudiant, etc.)
- Gestion de la capacité et disponibilité

✅ **Paiement en ligne sécurisé**
- Intégration Ebilling (Mobile Money + Cartes)
- Webhook automatique pour confirmation
- Traçabilité complète des transactions

✅ **Codes promotionnels**
- Réductions en pourcentage ou montant fixe
- Par événement ou global
- Limites d'utilisation configurables

✅ **Suivi et statistiques**
- Dashboard temps réel
- Export des participants
- Revenus par événement/catégorie

---

## 🚀 Installation rapide

### Prérequis
- Node.js (v14+)
- MySQL/MariaDB
- Compte Ebilling (pour paiements)

### Étape 1 : Créer les tables

```bash
# Via MySQL CLI
mysql -u root -p votre_base < data/rotary_events_system.sql

# Insérer les données de test
mysql -u root -p votre_base < data/rotary_test_data.sql
```

### Étape 2 : Démarrer le serveur

```bash
npm install
npm start
```

### Étape 3 : Tester

```bash
# Ouvrir dans votre navigateur
test-rotary-frontend.html

# Ou lancer les tests automatiques
node scripts/testRotarySystem.js
```

**✅ C'est tout ! Le système est opérationnel.**

---

## 📁 Structure du projet

```
VILLA MASHAÏ-back/
│
├── 📂 data/
│   ├── rotary_events_system.sql      # Structure BDD (7 tables + 2 vues)
│   └── rotary_test_data.sql          # Données de test (3 événements)
│
├── 📂 routes/
│   ├── rotaryEventsRoutes.js         # API complète (11 endpoints)
│   └── transactionRotaryRoutes.js    # Routes existantes (conservées)
│
├── 📂 docs/
│   └── ROTARY_PAYMENT_GUIDE.md       # Documentation technique complète
│
├── 📂 scripts/
│   └── testRotarySystem.js           # Tests automatiques
│
├── 📄 test-rotary-frontend.html      # Page de test HTML
├── 📄 GUIDE_COMPLET_ROTARY.md        # Guide utilisateur complet
├── 📄 ROTARY_QUICKSTART.md           # Guide de démarrage rapide
├── 📄 ROTARY_SUMMARY.md              # Récapitulatif du projet
├── 📄 README_ROTARY.md               # Ce fichier
└── 📄 server.js                       # Serveur (déjà configuré)
```

---

## 📡 API Endpoints

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/rotary/events` | GET | Liste des événements publiés |
| `/rotary/events/:id` | GET | Détails événement + catégories |
| `/rotary/tickets/create` | POST | Créer billet + initier paiement |
| `/rotary/tickets/:ref` | GET | Statut d'un billet |
| `/rotary/my-tickets` | GET | Billets d'un utilisateur |
| `/rotary/webhook` | POST | Notification Ebilling (auto) |
| `/rotary/validate-promo` | POST | Valider code promo |
| `/rotary/events/:id/stats` | GET | Statistiques événement |

**📖 Documentation complète :** `docs/ROTARY_PAYMENT_GUIDE.md`

---

## 🗄️ Base de données

### Tables créées

| Table | Description |
|-------|-------------|
| `rotary_evenements` | Événements organisés |
| `rotary_billets_categories` | Types de billets (VIP, Standard, etc.) |
| `rotary_billets` | Billets/inscriptions vendus |
| `rotary_transactions` | Transactions de paiement |
| `rotary_codes_promo` | Codes promotionnels |
| `rotary_email_logs` | Historique emails |

### Vues SQL

| Vue | Description |
|-----|-------------|
| `rotary_stats_evenements` | Statistiques par événement |
| `rotary_transactions_pending` | Transactions en attente |

---

## 📖 Documentation

### Pour démarrer rapidement
👉 **[ROTARY_QUICKSTART.md](ROTARY_QUICKSTART.md)** - Guide de démarrage 5 minutes

### Pour l'utilisation quotidienne
👉 **[GUIDE_COMPLET_ROTARY.md](GUIDE_COMPLET_ROTARY.md)** - Guide utilisateur complet

### Pour le développement
👉 **[docs/ROTARY_PAYMENT_GUIDE.md](docs/ROTARY_PAYMENT_GUIDE.md)** - Documentation technique

### Pour comprendre le projet
👉 **[ROTARY_SUMMARY.md](ROTARY_SUMMARY.md)** - Récapitulatif complet

---

## 🧪 Tests

### Tests automatiques

```bash
# Lancer tous les tests
node scripts/testRotarySystem.js
```

**Tests inclus :**
- ✅ Connexion serveur
- ✅ Récupération événements
- ✅ Détails événement
- ✅ Validation codes promo
- ✅ Statistiques

### Test manuel (interface HTML)

```bash
# Ouvrir dans votre navigateur
test-rotary-frontend.html
```

**Fonctionnalités testables :**
- Sélection d'événement
- Choix de catégorie
- Formulaire d'achat
- Calcul du total avec code promo

---

## 💡 Exemples d'utilisation

### Exemple 1 : Créer un événement

```sql
INSERT INTO rotary_evenements 
(id, titre, description, type_evenement, date_evenement, lieu, 
capacite_max, statut, is_payant)
VALUES
('EV-001', 'Mon Gala', 'Description', 'gala', 
'2026-12-31 19:00:00', 'Hôtel XYZ', 300, 'publie', 1);
```

### Exemple 2 : Ajouter des catégories

```sql
INSERT INTO rotary_billets_categories
(id, evenement_id, nom_categorie, prix_unitaire, quantite_disponible)
VALUES
('CAT-001', 'EV-001', 'VIP', 50000, 50),
('CAT-002', 'EV-001', 'Standard', 25000, 250);
```

### Exemple 3 : Créer un code promo

```sql
INSERT INTO rotary_codes_promo
(id, code, type_reduction, valeur_reduction, date_debut, date_fin)
VALUES
('PROMO-001', 'NOEL2026', 'pourcentage', 20, 
'2026-12-01', '2026-12-31');
```

### Exemple 4 : API - Acheter un billet

```javascript
const response = await fetch('http://localhost:5000/rotary/tickets/create', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    evenement_id: 'EV-001',
    categorie_id: 'CAT-001',
    prenom: 'Jean',
    nom: 'Dupont',
    email: 'jean@example.com',
    telephone: '+22890123456',
    quantite: 2,
    code_promo: 'NOEL2026'
  })
});

const data = await response.json();
// Rediriger vers data.data.payment_url pour payer
```

---

## 📊 Statistiques

### Via API

```bash
GET /rotary/events/EV-001/stats
```

### Via SQL

```sql
-- Vue déjà créée
SELECT * FROM rotary_stats_evenements;

-- Billets vendus aujourd'hui
SELECT COUNT(*) FROM rotary_billets 
WHERE DATE(created_at) = CURDATE() 
AND statut_paiement = 'paye';

-- Revenus totaux
SELECT SUM(montant_total) FROM rotary_billets 
WHERE statut_paiement = 'paye';
```

---

## 🔧 Configuration

### Variables d'environnement

Vérifier dans votre `.env` :

```env
# Ebilling (déjà configuré avec valeurs par défaut)
EBILLING_USERNAME=smeby33
EBILLING_SHARED_KEY=0d14ed02-33fc-496b-9e03-04a00563d270

# URL de votre frontend
FRONTEND_URL=https://votre-site.com
```

### Webhook Ebilling

Configurer dans votre compte Ebilling :
```
https://votre-serveur.com/rotary/webhook
```

---

## 🐛 Débogage

### Voir les logs Rotary

```bash
grep "🎫 \[ROTARY\]" logs/server.log
```

### Voir les webhooks reçus

```bash
grep "🔔" logs/server.log
```

### Vérifier les erreurs

```bash
grep "❌" logs/server.log | grep "ROTARY"
```

### Vérifier la base de données

```sql
-- Événements publiés
SELECT * FROM rotary_evenements WHERE statut = 'publie';

-- Billets en attente
SELECT * FROM rotary_billets WHERE statut_paiement = 'en_attente';

-- Transactions pending
SELECT * FROM rotary_transactions_pending;
```

---

## 🎯 Fonctionnalités principales

### ✅ Déjà implémenté

- [x] Gestion complète d'événements
- [x] Vente de billets en ligne
- [x] Paiement Ebilling (Mobile Money + Cartes)
- [x] Codes promotionnels
- [x] Webhook automatique
- [x] Statistiques en temps réel
- [x] Vérification disponibilité
- [x] API complète et documentée
- [x] Tests automatiques
- [x] Page de test HTML

### 🚧 À implémenter (optionnel)

- [ ] Génération QR codes
- [ ] Envoi automatique emails
- [ ] Interface admin web
- [ ] Scanner de billets (app mobile)
- [ ] Remboursements
- [ ] Export CSV/Excel participants

---

## 📞 Support

### Questions fréquentes

**Q: Comment ajouter un événement ?**  
R: Via SQL (voir Exemple 1 ci-dessus) ou créer une interface admin

**Q: Les paiements sont-ils sécurisés ?**  
R: Oui, via Ebilling (certifié pour Mobile Money au Togo)

**Q: Puis-je personnaliser les catégories ?**  
R: Oui, totalement flexible via la table `rotary_billets_categories`

**Q: Comment voir les statistiques ?**  
R: Via l'endpoint `/rotary/events/:id/stats` ou la vue SQL `rotary_stats_evenements`

### Aide supplémentaire

- 📖 Documentation technique : `docs/ROTARY_PAYMENT_GUIDE.md`
- 🚀 Guide rapide : `ROTARY_QUICKSTART.md`
- 📊 Récapitulatif : `ROTARY_SUMMARY.md`
- 💬 Guide complet : `GUIDE_COMPLET_ROTARY.md`

---

## 🎉 Conclusion

Vous disposez d'un **système professionnel et complet** pour gérer les paiements de billets d'événements pour le Rotary Club.

**Tout est prêt pour une utilisation immédiate !**

### Prochaines étapes

1. ✅ Créer les tables (5 min)
2. ✅ Insérer les données de test (2 min)
3. ✅ Tester avec la page HTML (2 min)
4. 🚀 Intégrer dans votre frontend
5. 📣 Promouvoir vos événements !

---

**Version:** 1.0.0  
**Date:** 14 janvier 2026  
**Status:** ✅ Production Ready  
**License:** Propriétaire - Rotary Club

---

**🎯 Commencez maintenant avec [ROTARY_QUICKSTART.md](ROTARY_QUICKSTART.md) !**
