# Integration Shaina sur le meme serveur

## Routes ajoutees
- Prefixe: `/shaina`
- Fichier: `routes/shainaEventRoutes.js`
- Reutilise le flow Rotary existant (paiement, ticket, webhook, etc.)

### Endpoints Shaina utilitaires
- `GET /shaina/config`
- `GET /shaina/event`

### Endpoints Rotary reutilises via /shaina
- `POST /shaina/tickets/create`
- `GET /shaina/tickets/:reference`
- `GET /shaina/my-tickets`
- `POST /shaina/webhook`

## Seed SQL (event + 3 categories)
```sql
INSERT INTO rotary_evenements (
  id, titre, description, type_evenement, date_evenement, date_fin_evenement,
  lieu, adresse_complete, capacite_max, image_url, organisateur_nom,
  organisateur_email, organisateur_telephone, statut, date_limite_inscription,
  is_payant, created_by_user_id
) VALUES (
  'EV-SHAINA-SMARTAPP-001',
  'Shaina Smart App - Commandes de documents',
  'Paiement des packs Basique, Standard, Premium.',
  'autres',
  '2099-12-31 23:59:59',
  NULL,
  'En ligne',
  'Service digital',
  NULL,
  NULL,
  'Shaina Smart',
  'support@shainasmart.app',
  NULL,
  'publie',
  NULL,
  1,
  'system'
)
ON DUPLICATE KEY UPDATE
  titre = VALUES(titre),
  description = VALUES(description),
  statut = 'publie',
  is_payant = 1;

INSERT INTO rotary_billets_categories (
  id, evenement_id, nom_categorie, description, prix_unitaire, currency_code,
  quantite_disponible, quantite_vendue, ordre_affichage, is_active, couleur_badge, avantages
) VALUES
(
  'CAT-SHAINA-BASIC',
  'EV-SHAINA-SMARTAPP-001',
  'Basique',
  'Pack Basique Shaina',
  2500,
  'XOF',
  NULL,
  0,
  1,
  1,
  'bronze',
  '{"features":["Resume structure","Format PDF simple","Livraison en 48h","Support par email"],"documentTypes":["resume"],"popular":false}'
),
(
  'CAT-SHAINA-STANDARD',
  'EV-SHAINA-SMARTAPP-001',
  'Standard',
  'Pack Standard Shaina',
  3500,
  'XOF',
  NULL,
  0,
  2,
  1,
  'silver',
  '{"features":["Document PDF academique","Mise en page professionnelle","Livraison en 24h","Support prioritaire","Revision incluse"],"documentTypes":["pdf","resume"],"popular":true}'
),
(
  'CAT-SHAINA-PREMIUM',
  'EV-SHAINA-SMARTAPP-001',
  'Premium',
  'Pack Premium Shaina',
  5000,
  'XOF',
  NULL,
  0,
  3,
  1,
  'gold',
  '{"features":["Presentation PowerPoint","Design personnalise","Livraison en 12h","Support 24/7","2 revisions incluses","Export multi-formats"],"documentTypes":["expose","pdf","resume"],"popular":false}'
)
ON DUPLICATE KEY UPDATE
  nom_categorie = VALUES(nom_categorie),
  description = VALUES(description),
  prix_unitaire = VALUES(prix_unitaire),
  currency_code = VALUES(currency_code),
  ordre_affichage = VALUES(ordre_affichage),
  is_active = 1,
  avantages = VALUES(avantages);
```

## Mapping package -> categorie
- `basic` -> `CAT-SHAINA-BASIC`
- `standard` -> `CAT-SHAINA-STANDARD`
- `premium` -> `CAT-SHAINA-PREMIUM`

## Exemple payload frontend (create ticket)
```json
{
  "evenement_id": "EV-SHAINA-SMARTAPP-001",
  "categorie_id": "CAT-SHAINA-STANDARD",
  "user_id": "firebase_uid_optional",
  "prenom": "Shaina",
  "nom": "Student",
  "email": "student@example.com",
  "telephone": "+2250700000000",
  "quantite": 1,
  "notes_participant": "Commande depuis shaina",
  "besoins_speciaux": null
}
```

## Notes
- Si ton provider ne supporte pas `XOF`, passer les categories en `XAF`.
- CORS: ajouter le domaine frontend Shaina dans `server.js` si besoin.
