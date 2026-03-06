const express = require('express');
const { sendEmail } = require('../emailService');

const router = express.Router();

function asString(value, fallback = '') {
  return typeof value === 'string' ? value.trim() : fallback;
}

function asStringArray(value) {
  if (!Array.isArray(value)) return [];
  return value
    .filter((item) => typeof item === 'string')
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function buildSubmissionReceivedEmail(payload) {
  const firstName = asString(payload.studentFirstName, 'Étudiant');
  const submissionId = asString(payload.submissionId);
  const submissionTitle = asString(payload.submissionTitle);
  const customMessage = asString(
    payload.message,
    'Votre soumission a bien été reçue. Nous allons commencer le traitement.'
  );

  const subject = `Chaina Smart - Soumission reçue (${submissionTitle})`;
  const text = [
    `Bonjour ${firstName},`,
    '',
    customMessage,
    '',
    `Soumission: ${submissionTitle}`,
    `ID: ${submissionId}`,
    '',
    'Cordialement,',
    'Équipe Chaina Smart'
  ].join('\n');

  const html = `
    <div style="font-family:Arial,sans-serif;color:#0f172a;line-height:1.5;max-width:640px;margin:0 auto;padding:20px;">
      <h2 style="margin:0 0 12px 0;color:#1d4ed8;">Soumission reçue</h2>
      <p>Bonjour <strong>${escapeHtml(firstName)}</strong>,</p>
      <p>${escapeHtml(customMessage)}</p>
      <div style="margin:16px 0;padding:12px;border:1px solid #e2e8f0;border-radius:8px;background:#f8fafc;">
        <p style="margin:0 0 6px 0;"><strong>Soumission:</strong> ${escapeHtml(submissionTitle)}</p>
        <p style="margin:0;"><strong>ID:</strong> ${escapeHtml(submissionId)}</p>
      </div>
      <p style="margin-top:18px;">Cordialement,<br/>Équipe Chaina Smart</p>
    </div>
  `;

  return { subject, text, html };
}

function buildDocumentsReadyEmail(payload) {
  const firstName = asString(payload.studentFirstName, 'Étudiant');
  const submissionId = asString(payload.submissionId);
  const submissionTitle = asString(payload.submissionTitle);
  const customMessage = asString(
    payload.message,
    'Vos documents sont prêts. Consultez votre soumission.'
  );
  const labels = asStringArray(payload.deliverableLabels);

  const subject = `Chaina Smart - Documents prêts (${submissionTitle})`;
  const labelsText = labels.length > 0 ? labels.map((label) => `- ${label}`).join('\n') : '- Livrable disponible';
  const labelsHtml = labels.length > 0
    ? labels.map((label) => `<li>${escapeHtml(label)}</li>`).join('')
    : '<li>Livrable disponible</li>';

  const text = [
    `Bonjour ${firstName},`,
    '',
    customMessage,
    '',
    `Soumission: ${submissionTitle}`,
    `ID: ${submissionId}`,
    '',
    'Livrables:',
    labelsText,
    '',
    'Cordialement,',
    'Équipe Chaina Smart'
  ].join('\n');

  const html = `
    <div style="font-family:Arial,sans-serif;color:#0f172a;line-height:1.5;max-width:640px;margin:0 auto;padding:20px;">
      <h2 style="margin:0 0 12px 0;color:#15803d;">Documents prêts</h2>
      <p>Bonjour <strong>${escapeHtml(firstName)}</strong>,</p>
      <p>${escapeHtml(customMessage)}</p>
      <div style="margin:16px 0;padding:12px;border:1px solid #e2e8f0;border-radius:8px;background:#f8fafc;">
        <p style="margin:0 0 6px 0;"><strong>Soumission:</strong> ${escapeHtml(submissionTitle)}</p>
        <p style="margin:0;"><strong>ID:</strong> ${escapeHtml(submissionId)}</p>
      </div>
      <p style="margin:0 0 6px 0;"><strong>Livrables:</strong></p>
      <ul style="margin:0 0 14px 20px;padding:0;">${labelsHtml}</ul>
      <p style="margin-top:18px;">Cordialement,<br/>Équipe Chaina Smart</p>
    </div>
  `;

  return { subject, text, html };
}

function mapFraisStatusLabel(status) {
  const value = asString(status).toLowerCase();
  if (value === 'paye') return 'Payé';
  return 'En attente';
}

function mapDemandeStatusLabel(status) {
  const value = asString(status).toLowerCase();
  if (value === 'validee') return 'Validée';
  if (value === 'rejetee') return 'Rejetée';
  return 'En cours';
}

function getAdminRecipients() {
  const candidates = [
    asString(process.env.ADMIN_EMAIL),
    asString(process.env.ADMIN_EMAIL1),
    asString(process.env.EMAIL_USER)
  ];

  const unique = [...new Set(candidates.filter((email) => email.length > 0))];
  return unique;
}

function buildBourseStatusChangedEmail(payload) {
  const parentName = asString(payload.parentName, 'Parent');
  const requestId = asString(payload.requestId);
  const studentName = asString(payload.studentName, 'Eleve');
  const classeActuelle = asString(payload.classeActuelle, '-');
  const fraisStatus = mapFraisStatusLabel(payload.fraisDossierStatus);
  const demandeStatus = mapDemandeStatusLabel(payload.demandeBourseStatus);
  const referenceBillet = asString(payload.paymentReferenceBillet, '-');
  const billId = asString(payload.paymentBillId, '-');
  const customMessage = asString(
    payload.message,
    'Le statut de votre demande de bourse Ecole 241 Kids a été mis à jour.'
  );

  const subject = `Ecole 241 Kids - Mise à jour dossier bourse (${requestId})`;

  const text = [
    `Bonjour ${parentName},`,
    '',
    customMessage,
    '',
    `Dossier ID: ${requestId}`,
    `Élève: ${studentName}`,
    `Classe: ${classeActuelle}`,
    `Frais de dossier: ${fraisStatus}`,
    `Statut demande: ${demandeStatus}`,
    `Référence paiement: ${referenceBillet}`,
    `Bill ID: ${billId}`,
    '',
    'Cordialement,',
    'Équipe Ecole 241 Kids'
  ].join('\n');

  const html = `
    <div style="font-family:Arial,sans-serif;color:#1f2937;line-height:1.5;max-width:640px;margin:0 auto;padding:20px;background:#f8fafc;">
      <div style="background:#1CBA7D;color:#ffffff;padding:16px 18px;border-radius:10px 10px 0 0;">
        <h2 style="margin:0;font-size:20px;">Mise à jour de votre dossier de bourse</h2>
      </div>
      <div style="background:#ffffff;border:1px solid #e5e7eb;border-top:0;border-radius:0 0 10px 10px;padding:18px;">
      <p>Bonjour <strong>${escapeHtml(parentName)}</strong>,</p>
      <p>${escapeHtml(customMessage)}</p>
      <div style="margin:16px 0;padding:12px;border:1px solid #DA8D6F;border-radius:8px;background:#fff7f3;">
        <p style="margin:0 0 6px 0;"><strong style="color:#3CA3C6;">Dossier ID:</strong> ${escapeHtml(requestId)}</p>
        <p style="margin:0 0 6px 0;"><strong style="color:#3CA3C6;">Élève:</strong> ${escapeHtml(studentName)}</p>
        <p style="margin:0;"><strong style="color:#3CA3C6;">Classe:</strong> ${escapeHtml(classeActuelle)}</p>
      </div>
      <div style="margin:16px 0;padding:12px;border:1px solid #C18708;border-radius:8px;background:#fffbeb;">
        <p style="margin:0 0 6px 0;"><strong style="color:#C18708;">Frais de dossier:</strong> ${escapeHtml(fraisStatus)}</p>
        <p style="margin:0 0 6px 0;"><strong style="color:#C18708;">Statut demande:</strong> ${escapeHtml(demandeStatus)}</p>
        <p style="margin:0 0 6px 0;"><strong style="color:#C18708;">Référence paiement:</strong> ${escapeHtml(referenceBillet)}</p>
        <p style="margin:0;"><strong style="color:#C18708;">Bill ID:</strong> ${escapeHtml(billId)}</p>
      </div>
      <p style="margin-top:18px;">Cordialement,<br/><strong style="color:#1CBA7D;">Équipe Ecole 241 Kids</strong></p>
      </div>
    </div>
  `;

  return { subject, text, html };
}

function buildBourseStatusChangedAdminEmail(payload) {
  const parentName = asString(payload.parentName, 'Parent');
  const requestId = asString(payload.requestId);
  const studentName = asString(payload.studentName, 'Eleve');
  const classeActuelle = asString(payload.classeActuelle, '-');
  const fraisStatus = mapFraisStatusLabel(payload.fraisDossierStatus);
  const demandeStatus = mapDemandeStatusLabel(payload.demandeBourseStatus);
  const referenceBillet = asString(payload.paymentReferenceBillet, '-');
  const billId = asString(payload.paymentBillId, '-');

  const subject = `Admin - Mise à jour dossier bourse (${requestId})`;

  const text = [
    'Bonjour Admin,',
    '',
    'Une mise à jour du dossier de bourse a été effectuée.',
    '',
    `Dossier ID: ${requestId}`,
    `Parent: ${parentName}`,
    `Élève: ${studentName}`,
    `Classe: ${classeActuelle}`,
    `Frais de dossier: ${fraisStatus}`,
    `Statut demande: ${demandeStatus}`,
    `Référence paiement: ${referenceBillet}`,
    `Bill ID: ${billId}`,
    '',
    'Cordialement,',
    'Système Ecole 241 Kids'
  ].join('\n');

  const html = `
    <div style="font-family:Arial,sans-serif;color:#1f2937;line-height:1.5;max-width:640px;margin:0 auto;padding:20px;background:#f8fafc;">
      <div style="background:#3CA3C6;color:#ffffff;padding:16px 18px;border-radius:10px 10px 0 0;">
        <h2 style="margin:0;font-size:20px;">Notification admin - Dossier bourse mis à jour</h2>
      </div>
      <div style="background:#ffffff;border:1px solid #e5e7eb;border-top:0;border-radius:0 0 10px 10px;padding:18px;">
      <p>Bonjour <strong>Admin</strong>,</p>
      <p>Une mise à jour du dossier de bourse a été effectuée.</p>
      <div style="margin:16px 0;padding:12px;border:1px solid #DA8D6F;border-radius:8px;background:#fff7f3;">
        <p style="margin:0 0 6px 0;"><strong style="color:#3CA3C6;">Dossier ID:</strong> ${escapeHtml(requestId)}</p>
        <p style="margin:0 0 6px 0;"><strong style="color:#3CA3C6;">Parent:</strong> ${escapeHtml(parentName)}</p>
        <p style="margin:0 0 6px 0;"><strong style="color:#3CA3C6;">Élève:</strong> ${escapeHtml(studentName)}</p>
        <p style="margin:0;"><strong style="color:#3CA3C6;">Classe:</strong> ${escapeHtml(classeActuelle)}</p>
      </div>
      <div style="margin:16px 0;padding:12px;border:1px solid #C18708;border-radius:8px;background:#fffbeb;">
        <p style="margin:0 0 6px 0;"><strong style="color:#C18708;">Frais de dossier:</strong> ${escapeHtml(fraisStatus)}</p>
        <p style="margin:0 0 6px 0;"><strong style="color:#C18708;">Statut demande:</strong> ${escapeHtml(demandeStatus)}</p>
        <p style="margin:0 0 6px 0;"><strong style="color:#C18708;">Référence paiement:</strong> ${escapeHtml(referenceBillet)}</p>
        <p style="margin:0;"><strong style="color:#C18708;">Bill ID:</strong> ${escapeHtml(billId)}</p>
      </div>
      <p style="margin-top:18px;">Cordialement,<br/><strong style="color:#1CBA7D;">Système Ecole 241 Kids</strong></p>
      </div>
    </div>
  `;

  return { subject, text, html };
}

async function sendAndRespond(res, emailPayload) {
  const result = await sendEmail(emailPayload);

  if (result.success) {
    return res.json({
      success: true,
      message: 'Email envoyé avec succès',
      messageId: result.messageId || null
    });
  }

  return res.status(500).json({
    success: false,
    error: result.error || 'Échec envoi email'
  });
}

router.post('/send', async (req, res) => {
  try {
    const to = asString(req.body.to);
    const subject = asString(req.body.subject);
    const text = asString(req.body.text);
    const html = asString(req.body.html);

    if (!to || !subject || (!text && !html)) {
      return res.status(400).json({
        success: false,
        error: 'Champs requis: to, subject, et text ou html'
      });
    }

    return await sendAndRespond(res, { to, subject, text, html });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Erreur serveur email'
    });
  }
});

router.post('/submission-received', async (req, res) => {
  try {
    const to = asString(req.body.to);
    const submissionId = asString(req.body.submissionId);
    const submissionTitle = asString(req.body.submissionTitle);

    if (!to || !submissionId || !submissionTitle) {
      return res.status(400).json({
        success: false,
        error: 'Champs requis: to, submissionId, submissionTitle'
      });
    }

    const template = buildSubmissionReceivedEmail(req.body);
    return await sendAndRespond(res, { to, ...template });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Erreur serveur email'
    });
  }
});

router.post('/documents-ready', async (req, res) => {
  try {
    const to = asString(req.body.to);
    const submissionId = asString(req.body.submissionId);
    const submissionTitle = asString(req.body.submissionTitle);

    if (!to || !submissionId || !submissionTitle) {
      return res.status(400).json({
        success: false,
        error: 'Champs requis: to, submissionId, submissionTitle'
      });
    }

    const template = buildDocumentsReadyEmail(req.body);
    return await sendAndRespond(res, { to, ...template });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Erreur serveur email'
    });
  }
});

router.post('/bourse-status-changed', async (req, res) => {
  try {
    const to = asString(req.body.to);
    const requestId = asString(req.body.requestId);
    const studentName = asString(req.body.studentName);

    if (!to || !requestId || !studentName) {
      return res.status(400).json({
        success: false,
        error: 'Champs requis: to, requestId, studentName'
      });
    }

    const template = buildBourseStatusChangedEmail(req.body);
    const parentResult = await sendEmail({ to, ...template });

    if (!parentResult.success) {
      return res.status(500).json({
        success: false,
        error: parentResult.error || 'Échec envoi email parent'
      });
    }

    const adminRecipients = getAdminRecipients();
    const adminTemplate = buildBourseStatusChangedAdminEmail(req.body);

    let adminNotified = false;
    let adminError = null;

    if (adminRecipients.length > 0) {
      const adminTo = adminRecipients.join(', ');
      console.log('📧 Notification admin dossier bourse ->', adminTo);
      const adminResult = await sendEmail({ to: adminTo, ...adminTemplate });

      if (adminResult.success) {
        adminNotified = true;
      } else {
        adminError = adminResult.error || 'Échec envoi notification admin';
        console.error('❌ Notification admin non envoyée:', adminError);
      }
    }

    return res.json({
      success: true,
      message: 'Email envoyé avec succès',
      messageId: parentResult.messageId || null,
      adminNotification: {
        sent: adminNotified,
        recipients: adminRecipients,
        error: adminError
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Erreur serveur email'
    });
  }
});

module.exports = router;
