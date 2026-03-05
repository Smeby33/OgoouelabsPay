const nodemailer = require('nodemailer');

// 🧪 Fonction utilitaire pour tester un PDF base64
const testPDFBase64 = (base64, filename = 'test.pdf') => {
  try {
    console.log("🧪 === TEST PDF BASE64 ===");
    console.log("📄 Longueur base64 :", base64.length);
    
    // Nettoyer le base64
    const cleanBase64 = base64.replace(/[^A-Za-z0-9+/=]/g, '');
    console.log("📄 Base64 nettoyé - Longueur :", cleanBase64.length);
    
    const buffer = Buffer.from(cleanBase64, 'base64');
    console.log("📄 Taille du buffer :", buffer.length, "bytes");
    console.log("📄 Début (10 premiers bytes) :", buffer.slice(0, 10).toString());
    console.log("📄 Début (hex) :", buffer.slice(0, 10).toString('hex'));
    console.log("📄 Fin (10 derniers bytes) :", buffer.slice(-10).toString());
    
    // Vérifier signature PDF
    const signature = buffer.slice(0, 4).toString();
    console.log("📄 Signature :", signature);
    console.log("📄 Est un PDF :", signature === '%PDF');
    
    // Vérifier fin PDF
    const hasEOF = buffer.slice(-10).includes(Buffer.from('%%EOF'));
    console.log("📄 Contient %%EOF :", hasEOF);
    
    // Sauvegarder pour test (optionnel)
    try {
      require('fs').writeFileSync(filename, buffer);
      console.log(`📄 Fichier de test créé : ${filename}`);
    } catch (fsError) {
      console.log("⚠️ Impossible de créer le fichier de test :", fsError.message);
    }
    
    return {
      valid: signature === '%PDF',
      size: buffer.length,
      signature: signature,
      hasEOF: hasEOF
    };
    
  } catch (error) {
    console.error("❌ Erreur test PDF :", error.message);
    return {
      valid: false,
      error: error.message
    };
  }
};

// Configuration du transporteur
const transporter = nodemailer.createTransport({
  service: 'gmail', // ou autre service
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Fonction pour envoyer un email
const sendEmail = async (emailData) => {
  try {
    console.log("📧 === DÉBUT ENVOI EMAIL ===");
    console.log("📧 Destinataire :", emailData.to);
    console.log("📧 Sujet :", emailData.subject);
    
    // AMÉLIORATION : Validation des pièces jointes
    if (emailData.attachments && emailData.attachments.length > 0) {
      console.log("📎 Nombre de pièces jointes :", emailData.attachments.length);
      
      emailData.attachments.forEach((attachment, index) => {
        console.log(`📎 Pièce jointe ${index + 1} :`);
        console.log(`   - Nom : ${attachment.filename}`);
        console.log(`   - Type : ${attachment.contentType}`);
        console.log(`   - Taille : ${attachment.content ? attachment.content.length : 'N/A'} bytes`);
        
        // Validation supplémentaire pour les PDFs
        if (attachment.contentType === 'application/pdf' && attachment.content) {
          const signature = attachment.content.slice(0, 4).toString();
          console.log(`   - Signature PDF : ${signature}`);
          
          if (signature !== '%PDF') {
            console.warn(`   ⚠️ ATTENTION : Signature PDF invalide pour ${attachment.filename}`);
          } else {
            console.log(`   ✅ Signature PDF valide pour ${attachment.filename}`);
          }
          
          // Vérifier la fin du PDF
          const endCheck = attachment.content.slice(-10).includes(Buffer.from('%%EOF'));
          console.log(`   - Fin PDF (%%EOF) : ${endCheck}`);
        }
      });
    }
    
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: emailData.to,
      subject: emailData.subject,
      text: emailData.text,
      html: emailData.html,
      attachments: emailData.attachments || []
    };
    
    console.log("📧 Configuration email préparée");
    console.log("📧 Envoi en cours...");
    
    const result = await transporter.sendMail(mailOptions);
    
    console.log("✅ Email envoyé avec succès");
    console.log("📧 Message ID :", result.messageId);
    console.log("📧 Response :", result.response);
    
    return { success: true, messageId: result.messageId, response: result.response };
    
  } catch (error) {
    console.error("❌ Erreur lors de l'envoi de l'email :", error);
    console.error("📧 Type d'erreur :", error.constructor.name);
    console.error("📧 Message :", error.message);
    
    return { success: false, error: error.message };
  }
};

module.exports = { sendEmail, testPDFBase64 };