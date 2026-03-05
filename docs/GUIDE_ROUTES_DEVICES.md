# 📖 Guide des Routes pour les Dispositifs Tuya

## ⚠️ IMPORTANT : Différence entre les IDs

### Types d'identifiants :

1. **ID Base de Données (UUID)** 
   - Format : `550e8400-e29b-41d4-a716-446655440000`
   - Utilisation : Routes de gestion en BD (CRUD local)

2. **Device ID Tuya** 
   - Format : `bfd2ad0df4da17682btk1o`
   - Utilisation : Routes API Tuya (vérification, commandes)

---

## 🔄 Routes Disponibles

### 📊 **Gestion Base de Données (Local)**

#### `GET /tuya/devicesdb`
Liste tous les dispositifs depuis votre base de données locale.
```bash
curl http://localhost:5000/tuya/devicesdb
```

#### `GET /tuya/devicesdb/:id` ✨ NOUVEAU
Récupère un dispositif par son **UUID de BD** et le synchronise avec Tuya.
```bash
# Exemple avec UUID
curl http://localhost:5000/tuya/devicesdb/550e8400-e29b-41d4-a716-446655440000
```
**Ce qu'il fait :**
- ✅ Récupère le dispositif depuis la BD (par UUID)
- ✅ Appelle l'API Tuya avec le `device_id` associé
- ✅ Met à jour les infos (online, model, category) dans la BD
- ✅ Retourne les données combinées

#### `POST /tuya/devices/adddevicesbd`
Ajoute un dispositif manuellement dans la BD.
```bash
curl -X POST http://localhost:5000/tuya/devices/adddevicesbd \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "bfd2ad0df4da17682btk1o",
    "device_name": "Serrure principale",
    "device_type": "lock",
    "location": "Entrée villa"
  }'
```

#### `PATCH /tuya/devices/:id`
Modifie un dispositif dans la BD (par UUID).
```bash
curl -X PATCH http://localhost:5000/tuya/devices/{UUID} \
  -H "Content-Type: application/json" \
  -d '{
    "device_name": "Nouveau nom",
    "location": "Nouvelle localisation"
  }'
```

#### `DELETE /tuya/devices/:id`
Supprime un dispositif de la BD (par UUID).
```bash
curl -X DELETE http://localhost:5000/tuya/devices/{UUID}
```

---

### 🌐 **API Tuya (Temps Réel)**

#### `GET /tuya/devices/:deviceId` ⚠️ ATTENTION
Vérifie l'existence d'un dispositif directement sur Tuya (par **device_id Tuya**).
```bash
# ✅ CORRECT - Device ID Tuya
curl http://localhost:5000/tuya/devices/bfd2ad0df4da17682btk1o

# ❌ ERREUR - UUID de BD
curl http://localhost:5000/tuya/devices/550e8400-e29b-41d4-a716-446655440000

# ❌ ERREUR - ID numérique
curl http://localhost:5000/tuya/devices/1
```

**Erreur typique :**
```json
{
  "code": 1106,
  "msg": "permission deny",
  "success": false
}
```
→ Signifie que le device_id n'existe pas dans votre compte Tuya.

#### `GET /tuya/devices/:deviceId/status`
Récupère le statut en temps réel (par **device_id Tuya**).
```bash
curl http://localhost:5000/tuya/devices/bfd2ad0df4da17682btk1o/status
```

#### `POST /tuya/door/unlock`
Déverrouille une serrure (par **device_id Tuya**).
```bash
curl -X POST http://localhost:5000/tuya/door/unlock \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "bfd2ad0df4da17682btk1o",
    "reservationId": 123,
    "reservationType": "appartement"
  }'
```

#### `POST /tuya/door/temp-password`
Crée un code PIN temporaire (par **device_id Tuya**).
```bash
curl -X POST http://localhost:5000/tuya/door/temp-password \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "bfd2ad0df4da17682btk1o",
    "password": "123456",
    "guestName": "Villa Mashaï - Réservation #001",
    "effectiveTime": 1764642911,
    "invalidTime": 1764902111
  }'
```

---

## 🎯 Workflow Recommandé

### 1️⃣ Vérifier un dispositif existe dans Tuya
```bash
GET /tuya/devices/bfd2ad0df4da17682btk1o
```
Si succès → dispositif existe, vous pouvez l'ajouter en BD.

### 2️⃣ Ajouter le dispositif dans votre BD
```bash
POST /tuya/devices/adddevicesbd
```

### 3️⃣ Lister vos dispositifs en BD
```bash
GET /tuya/devicesdb
```
Récupérez l'UUID généré.

### 4️⃣ Synchroniser un dispositif avec Tuya
```bash
GET /tuya/devicesdb/{UUID}
```
Met à jour online, model, category depuis Tuya.

### 5️⃣ Envoyer des commandes
```bash
POST /tuya/door/unlock
POST /tuya/door/temp-password
```

---

## 🔑 Obtenir votre Device ID Tuya

Si vous ne connaissez pas le `device_id` de vos dispositifs :

1. **Via Tuya Smart Life App** :
   - Ouvrir l'app
   - Aller dans le dispositif
   - Paramètres → Informations → Device ID

2. **Via API Tuya (liste tous les dispositifs)** :
   ```bash
   # Créer un script pour lister tous vos dispositifs
   node scripts/tuyaListDevices.js
   ```

---

## 📝 Exemples Complets

### Ajouter une nouvelle serrure

```bash
# 1. Vérifier qu'elle existe dans Tuya
curl http://localhost:5000/tuya/devices/nouveauDeviceId123

# 2. Si OK, l'ajouter en BD
curl -X POST http://localhost:5000/tuya/devices/adddevicesbd \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "nouveauDeviceId123",
    "device_name": "Serrure Appartement 2",
    "device_type": "lock",
    "location": "Étage 2 - Gauche"
  }'

# 3. Récupérer la liste avec UUID
curl http://localhost:5000/tuya/devicesdb

# 4. Synchroniser avec Tuya
curl http://localhost:5000/tuya/devicesdb/{UUID-récupéré}
```

---

## 🚨 Erreurs Courantes

### Erreur 1106 : "permission deny"
**Cause :** Device ID invalide ou inexistant dans votre compte Tuya.

**Solution :**
- Vérifier le device_id dans Tuya Smart Life app
- Utiliser le bon format (ex: `bfd2ad0df4da17682btk1o`)
- Ne pas confondre avec l'UUID de BD

### Erreur 404 : "Dispositif non trouvé"
**Cause :** UUID n'existe pas dans votre base de données.

**Solution :**
- Lister tous les dispositifs : `GET /tuya/devicesdb`
- Vérifier l'UUID utilisé

### Erreur 1010 : "token invalid"
**Cause :** Token Tuya expiré.

**Solution :**
```bash
# Régénérer le token
node scripts/tuyaAuth.js
# ou
curl -X POST http://localhost:5000/tuya/auth/token
```

---

## 💡 Résumé Rapide

| Action | Route | Paramètre |
|--------|-------|-----------|
| Lister dispositifs BD | `GET /tuya/devicesdb` | - |
| Voir détails + sync | `GET /tuya/devicesdb/:id` | **UUID BD** |
| Vérifier dans Tuya | `GET /tuya/devices/:deviceId` | **Device ID Tuya** |
| Ajouter en BD | `POST /tuya/devices/adddevicesbd` | Device ID Tuya |
| Déverrouiller | `POST /tuya/door/unlock` | Device ID Tuya |
| Créer PIN | `POST /tuya/door/temp-password` | Device ID Tuya |

**Règle d'or :** 
- Routes `/devicesdb/*` → **UUID de BD**
- Routes `/devices/:deviceId` → **Device ID Tuya**
