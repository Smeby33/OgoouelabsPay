const axios = require('axios');

// Configuration
const API_BASE_URL = 'http://localhost:5000';

// Couleurs pour les logs
const colors = {
    reset: '\x1b[0m',
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
    console.log(colors[color] + message + colors.reset);
}

// Tests
async function testRotaryAPI() {
    log('\n🧪 ========================================', 'cyan');
    log('🧪 TEST SYSTÈME PAIEMENT ROTARY CLUB', 'cyan');
    log('🧪 ========================================\n', 'cyan');

    try {
        // Test 1: Liste des événements
        log('📋 TEST 1: Récupération des événements...', 'blue');
        const eventsResponse = await axios.get(`${API_BASE_URL}/rotary/events`);
        log(`✅ ${eventsResponse.data.events.length} événements trouvés`, 'green');
        
        if (eventsResponse.data.events.length === 0) {
            log('⚠️  Aucun événement disponible - Tests suivants impossibles', 'yellow');
            return;
        }
        
        const event = eventsResponse.data.events[0];
        log(`   📌 Événement test: ${event.titre}`, 'reset');
        log(`   📅 Date: ${event.date_evenement}`, 'reset');
        
        // Test 2: Détails d'un événement
        log('\n🔍 TEST 2: Récupération détails événement...', 'blue');
        const eventDetailsResponse = await axios.get(`${API_BASE_URL}/rotary/events/${event.id}`);
        log(`✅ Événement: ${eventDetailsResponse.data.event.titre}`, 'green');
        log(`✅ ${eventDetailsResponse.data.categories.length} catégories de billets`, 'green');
        
        if (eventDetailsResponse.data.categories.length === 0) {
            log('⚠️  Aucune catégorie de billet - Tests suivants impossibles', 'yellow');
            return;
        }
        
        const categorie = eventDetailsResponse.data.categories[0];
        log(`   💳 Catégorie test: ${categorie.nom_categorie} - ${categorie.prix_unitaire} ${categorie.currency_code}`, 'reset');
        
        // Test 3: Validation code promo
        log('\n🎟️  TEST 3: Validation code promo...', 'blue');
        try {
            const promoResponse = await axios.post(`${API_BASE_URL}/rotary/validate-promo`, {
                code: 'ROTARY2026',
                evenement_id: event.id
            });
            
            if (promoResponse.data.valid) {
                log(`✅ Code promo valide: ${promoResponse.data.promo.code}`, 'green');
                log(`   💰 Réduction: ${promoResponse.data.promo.valeur_reduction}${promoResponse.data.promo.type_reduction === 'pourcentage' ? '%' : ' FCFA'}`, 'reset');
            }
        } catch (error) {
            if (error.response?.status === 404) {
                log('⚠️  Code promo invalide ou inexistant (normal si pas créé)', 'yellow');
            } else {
                throw error;
            }
        }
        
        // Test 4: Création d'un billet (SIMULATION - ne pas vraiment créer)
        log('\n🎫 TEST 4: Simulation création billet...', 'blue');
        log('   ℹ️  Ce test NE crée PAS réellement de billet', 'yellow');
        log('   ℹ️  Pour créer un vrai billet, décommenter le code ci-dessous', 'yellow');
        
        const billetData = {
            evenement_id: event.id,
            categorie_id: categorie.id,
            prenom: 'Test',
            nom: 'Rotary',
            email: 'test.rotary@example.com',
            telephone: '+22890000000',
            quantite: 1,
            notes_participant: 'Test automatique'
        };
        
        log(`   📦 Données du billet:`, 'reset');
        log(JSON.stringify(billetData, null, 2), 'reset');
        
        /* DÉCOMMENTER POUR CRÉER UN VRAI BILLET
        const billetResponse = await axios.post(`${API_BASE_URL}/rotary/tickets/create`, billetData);
        
        if (billetResponse.data.success) {
            log(`✅ Billet créé: ${billetResponse.data.data.reference_billet}`, 'green');
            log(`   💰 Montant: ${billetResponse.data.data.montant_total} ${billetResponse.data.data.currency_code}`, 'reset');
            log(`   🔗 URL paiement: ${billetResponse.data.data.payment_url}`, 'reset');
            
            // Test 5: Vérifier le statut du billet
            log('\n🔍 TEST 5: Vérification statut billet...', 'blue');
            await new Promise(resolve => setTimeout(resolve, 2000)); // Attendre 2s
            
            const ticketResponse = await axios.get(`${API_BASE_URL}/rotary/tickets/${billetResponse.data.data.reference_billet}`);
            log(`✅ Statut billet: ${ticketResponse.data.ticket.statut_paiement}`, 'green');
            log(`✅ Statut transaction: ${ticketResponse.data.ticket.transaction_statut}`, 'green');
        }
        */
        
        // Test 5: Mes billets (avec email de test)
        log('\n📊 TEST 5: Récupération mes billets...', 'blue');
        const myTicketsResponse = await axios.get(`${API_BASE_URL}/rotary/my-tickets?email=test.rotary@example.com`);
        log(`✅ ${myTicketsResponse.data.tickets.length} billet(s) trouvé(s)`, 'green');
        
        // Test 6: Statistiques événement
        log('\n📈 TEST 6: Statistiques événement...', 'blue');
        const statsResponse = await axios.get(`${API_BASE_URL}/rotary/events/${event.id}/stats`);
        log(`✅ Statistiques récupérées`, 'green');
        log(`   🎫 Total billets: ${statsResponse.data.stats.total_billets || 0}`, 'reset');
        log(`   👥 Places vendues: ${statsResponse.data.stats.total_places_vendues || 0}`, 'reset');
        log(`   💰 Revenus: ${statsResponse.data.stats.revenus_total || 0} FCFA`, 'reset');
        
        log('\n🎉 ========================================', 'green');
        log('🎉 TOUS LES TESTS SONT PASSÉS !', 'green');
        log('🎉 ========================================\n', 'green');
        
        log('📝 Prochaines étapes:', 'cyan');
        log('   1. Créer les tables dans la base de données', 'reset');
        log('   2. Insérer des données de test (événements, catégories)', 'reset');
        log('   3. Tester la création réelle d\'un billet', 'reset');
        log('   4. Tester le webhook avec un vrai paiement', 'reset');
        log('   5. Intégrer le frontend\n', 'reset');
        
    } catch (error) {
        log('\n❌ ========================================', 'red');
        log('❌ ERREUR DURANT LES TESTS', 'red');
        log('❌ ========================================', 'red');
        
        if (error.response) {
            log(`   📍 Status: ${error.response.status}`, 'red');
            log(`   📍 URL: ${error.config.url}`, 'red');
            log(`   📍 Erreur: ${JSON.stringify(error.response.data, null, 2)}`, 'red');
        } else if (error.request) {
            log(`   📍 Le serveur ne répond pas`, 'red');
            log(`   📍 Vérifiez que le serveur est démarré sur ${API_BASE_URL}`, 'red');
        } else {
            log(`   📍 Erreur: ${error.message}`, 'red');
        }
        
        log('\n💡 Conseils de débogage:', 'yellow');
        log('   1. Vérifiez que le serveur est démarré (npm start)', 'reset');
        log('   2. Vérifiez que les tables sont créées dans la BDD', 'reset');
        log('   3. Vérifiez les logs du serveur', 'reset');
        log('   4. Vérifiez la configuration CORS\n', 'reset');
    }
}

// Test de connexion simple
async function testConnection() {
    try {
        log('🔌 Test de connexion au serveur...', 'blue');
        await axios.get(`${API_BASE_URL}/rotary/events`);
        log('✅ Connexion réussie\n', 'green');
        return true;
    } catch (error) {
        log('❌ Connexion échouée', 'red');
        log(`   Assurez-vous que le serveur est démarré sur ${API_BASE_URL}\n`, 'yellow');
        return false;
    }
}

// Exécution
(async () => {
    const isConnected = await testConnection();
    if (isConnected) {
        await testRotaryAPI();
    }
})();

module.exports = { testRotaryAPI };
