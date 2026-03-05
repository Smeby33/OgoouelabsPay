const axios = require('axios');

// Configuration
const API_URL = 'http://localhost:5000';
const BILLET_REFERENCE = 'BIL-20260117-F7FB94'; // Changez par votre référence de billet

async function testEmailEnvoi() {
    console.log('\n🧪 ================================');
    console.log('🧪 TEST ENVOI EMAIL AUTOMATIQUE');
    console.log('🧪 ================================\n');
    
    try {
        // 1. Récupérer les infos du billet
        console.log('🔍 Récupération du billet:', BILLET_REFERENCE);
        const ticketResponse = await axios.get(`${API_URL}/rotary/tickets/${BILLET_REFERENCE}`);
        const ticket = ticketResponse.data.ticket;
        
        console.log('✅ Billet trouvé:', ticket.id);
        console.log('   Email:', ticket.email);
        console.log('   Statut actuel:', ticket.statut_paiement);
        console.log('   Transaction status:', ticket.transaction_statut);
        
        if (!ticket.bill_id) {
            console.error('❌ Pas de bill_id trouvé pour ce billet');
            return;
        }
        
        // 2. Simuler le webhook Ebilling avec confirmation de paiement
        console.log('\n📡 Simulation webhook Ebilling...');
        console.log('   Bill ID:', ticket.bill_id);
        
        const webhookData = {
            billingid: ticket.bill_id,
            reference: ticket.bill_id,
            state: 'paid',  // Paiement confirmé
            amount: ticket.montant_total,
            paymentsystem: 'tmoney',  // ou 'flooz', 'moov'
            timestamp: new Date().toISOString()
        };
        
        console.log('📤 Envoi webhook:', webhookData);
        
        const webhookResponse = await axios.post(`${API_URL}/rotary/webhook`, webhookData);
        
        console.log('\n✅ Webhook traité avec succès!');
        console.log('   Réponse:', webhookResponse.data);
        
        // 3. Vérifier le statut mis à jour
        console.log('\n🔍 Vérification du statut après webhook...');
        await new Promise(resolve => setTimeout(resolve, 2000)); // Attendre 2 secondes
        
        const updatedTicketResponse = await axios.get(`${API_URL}/rotary/tickets/${BILLET_REFERENCE}`);
        const updatedTicket = updatedTicketResponse.data.ticket;
        
        console.log('✅ Statut mis à jour:', updatedTicket.statut_paiement);
        console.log('   QR Code généré:', updatedTicket.qr_code_url ? 'OUI ✅' : 'NON ❌');
        
        console.log('\n🎉 ================================');
        console.log('🎉 TEST TERMINÉ!');
        console.log('🎉 ================================');
        console.log('\n📧 Vérifiez votre boîte email:', ticket.email);
        console.log('   (N\'oubliez pas de vérifier les spams!)\n');
        
    } catch (err) {
        console.error('\n❌ Erreur lors du test:', err.response?.data || err.message);
        if (err.response?.data) {
            console.error('   Détails:', JSON.stringify(err.response.data, null, 2));
        }
    }
}

// Exécuter le test
testEmailEnvoi();
