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
  const firstName = asString(payload.studentFirstName, 'Etudiant');
  const submissionId = asString(payload.submissionId);
  const submissionTitle = asString(payload.submissionTitle);
  const customMessage = asString(
    payload.message,
    'Votre soumission a bien ete recue. Nous allons commencer le traitement.'
  );

  const subject = `Chaina Smart - Soumission recue (${submissionTitle})`;
  const text = [
    `Bonjour ${firstName},`,
    '',
    customMessage,
    '',
    `Soumission: ${submissionTitle}`,
    `ID: ${submissionId}`,
    '',
    'Cordialement,',
    'Equipe Chaina Smart'
  ].join('\n');

  const html = `
    <div style="font-family:Arial,sans-serif;color:#0f172a;line-height:1.5;max-width:640px;margin:0 auto;padding:20px;">
      <h2 style="margin:0 0 12px 0;color:#1d4ed8;">Soumission recue</h2>
      <p>Bonjour <strong>${escapeHtml(firstName)}</strong>,</p>
      <p>${escapeHtml(customMessage)}</p>
      <div style="margin:16px 0;padding:12px;border:1px solid #e2e8f0;border-radius:8px;background:#f8fafc;">
        <p style="margin:0 0 6px 0;"><strong>Soumission:</strong> ${escapeHtml(submissionTitle)}</p>
        <p style="margin:0;"><strong>ID:</strong> ${escapeHtml(submissionId)}</p>
      </div>
      <p style="margin-top:18px;">Cordialement,<br/>Equipe Chaina Smart</p>
    </div>
  `;

  return { subject, text, html };
}

function buildDocumentsReadyEmail(payload) {
  const firstName = asString(payload.studentFirstName, 'Etudiant');
  const submissionId = asString(payload.submissionId);
  const submissionTitle = asString(payload.submissionTitle);
  const customMessage = asString(
    payload.message,
    'Vos documents sont prets. Consultez votre soumission.'
  );
  const labels = asStringArray(payload.deliverableLabels);

  const subject = `Chaina Smart - Documents prets (${submissionTitle})`;
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
    'Equipe Chaina Smart'
  ].join('\n');

  const html = `
    <div style="font-family:Arial,sans-serif;color:#0f172a;line-height:1.5;max-width:640px;margin:0 auto;padding:20px;">
      <h2 style="margin:0 0 12px 0;color:#15803d;">Documents prets</h2>
      <p>Bonjour <strong>${escapeHtml(firstName)}</strong>,</p>
      <p>${escapeHtml(customMessage)}</p>
      <div style="margin:16px 0;padding:12px;border:1px solid #e2e8f0;border-radius:8px;background:#f8fafc;">
        <p style="margin:0 0 6px 0;"><strong>Soumission:</strong> ${escapeHtml(submissionTitle)}</p>
        <p style="margin:0;"><strong>ID:</strong> ${escapeHtml(submissionId)}</p>
      </div>
      <p style="margin:0 0 6px 0;"><strong>Livrables:</strong></p>
      <ul style="margin:0 0 14px 20px;padding:0;">${labelsHtml}</ul>
      <p style="margin-top:18px;">Cordialement,<br/>Equipe Chaina Smart</p>
    </div>
  `;

  return { subject, text, html };
}

async function sendAndRespond(res, emailPayload) {
  const result = await sendEmail(emailPayload);

  if (result.success) {
    return res.json({
      success: true,
      message: 'Email envoye avec succes',
      messageId: result.messageId || null
    });
  }

  return res.status(500).json({
    success: false,
    error: result.error || 'Echec envoi email'
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

module.exports = router;
