const express = require('express');
const QRCode = require('qrcode');
const { sendEmail } = require('../emailService');

const router = express.Router();

function sanitize(value) {
  return String(value || '').trim();
}

function isValidHttpUrl(value) {
  const raw = sanitize(value);
  if (!raw) return false;
  const normalized = /^https?:\/\//i.test(raw) ? raw : `https://${raw}`;
  try {
    const parsed = new URL(normalized);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch {
    return false;
  }
}

function normalizeHttpUrl(value) {
  const raw = sanitize(value);
  const normalized = /^https?:\/\//i.test(raw) ? raw : `https://${raw}`;
  return new URL(normalized).toString();
}

function escapeHtml(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function buildDeliveryHtml({
  brideName,
  groomName,
  payerFirstName,
  payerLastName,
  referencebillet,
  deliveryUrl,
  qrCodeDataUrl
}) {
  const customerName = [payerFirstName, payerLastName].filter(Boolean).join(' ').trim() || 'Cher client';
  const couple = [brideName, groomName].filter(Boolean).join(' & ');
  const referenceLine = referencebillet ? `<p><strong>Reference:</strong> ${escapeHtml(referencebillet)}</p>` : '';

  return `
    <div style="font-family: Arial, sans-serif; max-width: 640px; margin: 0 auto; color: #1f2937; line-height: 1.5;">
      <h2 style="margin-bottom: 8px; color: #be8c63;">Votre site mariage est livre</h2>
      <p>Bonjour ${escapeHtml(customerName)},</p>
      <p>Le site mariage de <strong>${escapeHtml(couple)}</strong> est pret.</p>
      ${referenceLine}
      <p style="margin: 20px 0;">
        <a href="${escapeHtml(deliveryUrl)}" style="display: inline-block; padding: 12px 18px; background: #be8c63; color: #fff; text-decoration: none; border-radius: 8px;">
          Ouvrir le site mariage
        </a>
      </p>
      <p>Vous pouvez aussi scanner ce QR code:</p>
      <p><img src="${qrCodeDataUrl}" alt="QR code lien site mariage" style="width: 200px; height: 200px;" /></p>
      <p style="font-size: 12px; color: #6b7280;">Ce message est automatique, merci de ne pas y repondre.</p>
    </div>
  `;
}

router.post('/wedding/deliveries/site-link', async (req, res) => {
  const orderId = sanitize(req.body?.orderId);
  const userId = sanitize(req.body?.userId);
  const referencebillet = sanitize(req.body?.referencebillet);
  const brideName = sanitize(req.body?.brideName);
  const groomName = sanitize(req.body?.groomName);
  const payerFirstName = sanitize(req.body?.payerFirstName);
  const payerLastName = sanitize(req.body?.payerLastName);
  const payerEmail = sanitize(req.body?.payerEmail).toLowerCase();
  const deliveryUrlRaw = sanitize(req.body?.deliveryUrl);

  if (!orderId || !userId || !brideName || !groomName || !payerEmail) {
    return res.status(400).json({
      success: false,
      error: 'orderId, userId, brideName, groomName et payerEmail sont requis'
    });
  }

  if (!isValidHttpUrl(deliveryUrlRaw)) {
    return res.status(400).json({ success: false, error: 'deliveryUrl invalide' });
  }

  const deliveryUrl = normalizeHttpUrl(deliveryUrlRaw);

  try {
    const qrPayload = JSON.stringify({
      orderId,
      userId,
      referencebillet,
      deliveryUrl,
      brideName,
      groomName
    });
    const qrCodeDataUrl = await QRCode.toDataURL(qrPayload, { margin: 1, width: 320 });

    const html = buildDeliveryHtml({
      brideName,
      groomName,
      payerFirstName,
      payerLastName,
      referencebillet,
      deliveryUrl,
      qrCodeDataUrl
    });

    const emailResult = await sendEmail({
      to: payerEmail,
      subject: `Votre site mariage est disponible (${brideName} & ${groomName})`,
      html,
      text: `Votre site mariage est disponible: ${deliveryUrl}`
    });

    if (!emailResult.success) {
      return res.status(500).json({
        success: false,
        error: 'Echec envoi email',
        details: emailResult.error || null
      });
    }

    return res.json({
      success: true,
      message: 'Email de livraison envoye.',
      data: {
        id: orderId,
        recipient: payerEmail,
        qrCodeDataUrl,
        messageId: emailResult.messageId || null
      }
    });
  } catch (err) {
    console.error('[POST /wedding/deliveries/site-link] failed:', err);
    return res.status(500).json({
      success: false,
      error: 'Erreur serveur livraison mariage',
      details: err?.message || String(err)
    });
  }
});

module.exports = router;