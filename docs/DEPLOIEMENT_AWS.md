# 🚀 Guide de Déploiement AWS App Runner

## Problème actuel
- ❌ Les routes `/admin/*` renvoient 404
- ❌ Le code déployé sur `fwwm7ch7se.us-east-1.awsapprunner.com` est obsolète
- ✅ Le code a été poussé sur GitHub (commit 127db6a)

## Solution : Redéployer manuellement

### Option 1 : Via AWS Console (Recommandé)

1. **Aller sur AWS App Runner**
   ```
   https://console.aws.amazon.com/apprunner/
   ```

2. **Sélectionner votre service**
   - Chercher le service avec l'URL `fwwm7ch7se.us-east-1.awsapprunner.com`
   - Cliquer dessus

3. **Déclencher un déploiement manuel**
   - Cliquer sur l'onglet "Deployments"
   - Cliquer sur le bouton **"Deploy"** ou **"Start deployment"**
   - Attendre 3-5 minutes

4. **Vérifier le déploiement**
   ```bash
   curl https://fwwm7ch7se.us-east-1.awsapprunner.com/health
   curl https://fwwm7ch7se.us-east-1.awsapprunner.com/routes
   ```

### Option 2 : Via AWS CLI

```bash
# Lister vos services
aws apprunner list-services

# Déployer (remplacer SERVICE_ARN par votre ARN)
aws apprunner start-deployment --service-arn arn:aws:apprunner:us-east-1:XXXXXXXX:service/your-service-name/XXXXX
```

### Option 3 : Vérifier le déploiement automatique

1. **Vérifier les paramètres du service**
   - AWS Console → App Runner → Votre service → Configuration
   - Sous "Source and deployment", vérifier :
     - ✅ Auto-deployment: **Enabled**
     - ✅ Branch: **main**
     - ✅ Repository: **Smeby33/afuppay**

2. **Si auto-deployment est activé mais ne fonctionne pas**
   - Aller dans "Deployments" → voir les logs
   - Chercher des erreurs de build/deploy

## Vérifications après déploiement

### 1. Route health
```bash
curl https://fwwm7ch7se.us-east-1.awsapprunner.com/health
```
**Réponse attendue :**
```json
{
  "status": "OK",
  "timestamp": "2026-01-17T...",
  "routes": {
    "emails": "/emails",
    "rotary": "/rotary",
    "admin": "/admin"
  }
}
```

### 2. Liste des routes
```bash
curl https://fwwm7ch7se.us-east-1.awsapprunner.com/routes
```
**Réponse attendue :** Liste de toutes les routes incluant `/admin/login`, `/admin/tickets`, etc.

### 3. Test login admin
```bash
curl -X POST https://fwwm7ch7se.us-east-1.awsapprunner.com/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"smebedoh33@gmail.com","mot_de_passe":"admin123"}'
```
**Réponse attendue :**
```json
{
  "success": true,
  "message": "Connexion réussie",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "admin": { ... }
}
```

## Variables d'environnement à vérifier sur AWS

Assurez-vous que ces variables sont configurées sur AWS App Runner :

```env
PORT=5000
DB_HOST=srv1903.hstgr.io
DB_USER=u929681960_afuppay
DB_PASSWORD=AFUPpay@2
DB_NAME=u929681960_afuppay

EMAIL_USER=smebedoh33+22forumrotaryclubpog@gmail.com
EMAIL_PASS=swwn ktda lyuo xaqq
ADMIN_EMAIL=smebedoh33@gmail.com

JWT_SECRET=votre_secret_jwt_super_securise_2026

EB_CALLBACK_URL=https://fwwm7ch7se.us-east-1.awsapprunner.com/rotary/webhook
FRONTEND_URL=https://rotary-port-gentil-65th-anniversary.vercel.app
```

## Différence entre les deux services App Runner

Vous semblez avoir **2 services App Runner** :

1. **`ph8jb63g3p.us-east-1.awsapprunner.com`**
   - Utilisé dans les webhooks Rotary
   - Variable `EB_CALLBACK_URL`

2. **`fwwm7ch7se.us-east-1.awsapprunner.com`**
   - Utilisé par le frontend pour les appels API admin
   - Celui qui a le problème 404

### Solution : Utiliser le même service

**Mettre à jour le frontend pour utiliser :**
```typescript
const API_URL = 'https://ph8jb63g3p.us-east-1.awsapprunner.com';
```

**OU** redéployer le code sur `fwwm7ch7se.us-east-1.awsapprunner.com`

## Logs AWS App Runner

Pour voir les erreurs de déploiement :
1. AWS Console → App Runner → Votre service
2. Onglet "Logs"
3. Filtrer par "Application logs" ou "Deployment logs"

Chercher :
- Erreurs de build
- Erreurs au démarrage du serveur
- Port utilisé (doit être celui fourni par AWS)

## Troubleshooting

### Erreur : "Cannot GET /routes"
- ❌ Le serveur répond mais sans les routes Node.js
- ✅ Probablement un build frontend statique déployé
- **Solution :** Vérifier le Dockerfile ou le build command

### Erreur : 404 sur toutes les routes
- ❌ Le service ne démarre pas
- **Solution :** Vérifier les logs de déploiement

### Erreur : 502 Bad Gateway
- ❌ Le serveur crash au démarrage
- **Solution :** Vérifier les variables d'environnement (DB_*)

## Commandes utiles

```bash
# Voir le statut du déploiement
aws apprunner describe-service --service-arn <ARN>

# Voir les logs en temps réel
aws apprunner list-operations --service-arn <ARN>

# Forcer un nouveau déploiement
aws apprunner start-deployment --service-arn <ARN>
```

## Contact Support

Si le problème persiste après redéploiement :
1. Vérifier les logs AWS App Runner
2. Vérifier que le bon repository GitHub est connecté
3. Vérifier que la branche `main` est utilisée
4. Contacter le support AWS si nécessaire
