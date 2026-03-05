# 🚀 Quick Start - Système Rotary Club

## Installation rapide (5 minutes)

### 1️⃣ Créer les tables

```bash
# Option A: Via MySQL CLI
mysql -u root -p votre_base < data/rotary_events_system.sql

# Option B: Via phpMyAdmin
# Ouvrir phpMyAdmin → Importer → Sélectionner rotary_events_system.sql
```

### 2️⃣ Vérifier l'installation

Le serveur est déjà configuré ! Les routes sont disponibles sur `/rotary/*`

### 3️⃣ Tester l'API

```bash
# Lancer le test automatique
node scripts/testRotarySystem.js
```

## 🎯 Utilisation Rapide

### Créer un événement (via SQL ou phpMyAdmin)

```sql
INSERT INTO rotary_evenements 
(id, titre, description, type_evenement, date_evenement, lieu, capacite_max, statut, is_payant, organisateur_nom, organisateur_email)
VALUES
('EV-001', 'Mon Premier Gala', 'Description', 'gala', '2026-06-15 19:00:00', 'Hôtel XYZ', 200, 'publie', 1, 'Rotary Club', 'contact@rotary.tg');
```

### Créer des catégories de billets

```sql
INSERT INTO rotary_billets_categories
(id, evenement_id, nom_categorie, prix_unitaire, quantite_disponible)
VALUES
('CAT-001', 'EV-001', 'VIP', 50000, 50),
('CAT-002', 'EV-001', 'Standard', 25000, 150);
```

### Test frontend simple

```javascript
// 1. Récupérer les événements
fetch('http://localhost:5000/rotary/events')
  .then(r => r.json())
  .then(data => console.log(data.events));

// 2. Acheter un billet
fetch('http://localhost:5000/rotary/tickets/create', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    evenement_id: 'EV-001',
    categorie_id: 'CAT-001',
    prenom: 'John',
    nom: 'Doe',
    email: 'john@example.com',
    telephone: '+22890123456',
    quantite: 2
  })
})
.then(r => r.json())
.then(data => {
  console.log('Billet créé:', data.data.reference_billet);
  // Rediriger vers payment_url
  window.location.href = data.data.payment_url;
});
```

## 📋 Checklist de déploiement

- [ ] Tables créées dans la base de données
- [ ] Événement de test créé
- [ ] Catégories de billets créées
- [ ] Variables d'environnement configurées (EBILLING_USERNAME, EBILLING_SHARED_KEY)
- [ ] URL de callback webhook configurée dans Ebilling
- [ ] Test de création de billet effectué
- [ ] Test de webhook effectué
- [ ] Emails configurés (optionnel)

## 🔗 Endpoints principaux

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/rotary/events` | GET | Liste des événements |
| `/rotary/events/:id` | GET | Détails d'un événement |
| `/rotary/tickets/create` | POST | Créer un billet |
| `/rotary/tickets/:ref` | GET | Statut d'un billet |
| `/rotary/my-tickets` | GET | Mes billets (email/user_id) |
| `/rotary/webhook` | POST | Webhook Ebilling (auto) |
| `/rotary/validate-promo` | POST | Valider code promo |
| `/rotary/events/:id/stats` | GET | Statistiques |

## 📞 Aide

- **Documentation complète**: `docs/ROTARY_PAYMENT_GUIDE.md`
- **Structure BDD**: `data/rotary_events_system.sql`
- **Tests**: `scripts/testRotarySystem.js`

## 🎉 C'est prêt !

Votre système de paiement Rotary est maintenant opérationnel. 
Consultez le guide complet pour les fonctionnalités avancées.
