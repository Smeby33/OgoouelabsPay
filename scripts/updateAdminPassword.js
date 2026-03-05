const bcrypt = require('bcryptjs');
const db = require('../db');

async function updatePassword() {
    const email = 'smebedoh33@gmail.com';
    const newPassword = 'admin123';
    
    console.log('\n🔄 Mise à jour du mot de passe...\n');
    
    try {
        // Générer le hash avec Node.js bcrypt
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        
        console.log('✅ Nouveau hash généré:', hashedPassword);
        console.log('   Format:', hashedPassword.substring(0, 4));
        
        // Mettre à jour dans la base
        await db.query(
            'UPDATE administrateurs SET mot_de_passe = ? WHERE email = ?',
            [hashedPassword, email]
        );
        
        console.log('\n✅ Mot de passe mis à jour avec succès!');
        console.log('📧 Email:', email);
        console.log('🔑 Mot de passe:', newPassword);
        console.log('\nVous pouvez maintenant vous connecter!\n');
        
    } catch (err) {
        console.error('❌ Erreur:', err.message);
    } finally {
        process.exit(0);
    }
}

updatePassword();
