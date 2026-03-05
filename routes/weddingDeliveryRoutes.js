const express = require('express');
const QRCode = require('qrcode');

function sanitize(value) {
  return String(value || '').trim();
}

function toNullable(value) {
  const normalized = sanitize(value);
  return normalized ? normalized : null;
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
  const referenceLine = referencebillet ? `<p><strong>Reference:</strong> ${referencebillet}</p>` : '';

  return `
    <div style="font-family: Arial, sans-serif; max-width: 640px; margin: 0 auto; color: #1f2937;">
      <h2 style="margin-bottom: 8px;">Votre site mariage est livre</h2>
      <p>Bonjour ${customerName},</p>
      <p>Le site mariage de <strong>${couple}</strong> est pret.</p>
      ${referenceLine}
      <p style="margin: 20px 0;">
        <a href="${deliveryUrl}" style="display:inline-block; padding: 12px 18px; background:#be8c63; color:#fff; text-decoration:none; border-radius:8px;">
          Ouvrir le site mariage
        </a>
      </p>
      <p>Vous pouvez aussi scanner ce QR code:</p>
      <p><img src="${qrCodeDataUrl}" alt="QR code lien site mariage" style="width: 200px; height: 200px;" /></p>
      <p style="font-size: 12px; color:#6b7280;">Ce message est automatique, merci de ne pas y repondre.</p>
    </div>
  `;
}

function createWeddingDeliveryRoutes({ db, transporter, fromEmail }) {
  if (!db || typeof db.query !== 'function') {
    throw new Error('createWeddingDeliveryRoutes requires a MySQL-like db with query()');
  }
  if (!transporter || typeof transporter.sendMail !== 'function') {
    throw new Error('createWeddingDeliveryRoutes requires a nodemailer transporter');
  }

  const router = express.Router();

  router.post('/wedding/deliveries/site-link', async (req, res) => {
    const orderId = sanitize(req.body?.orderId);
    const userId = sanitize(req.body?.userId);
    const referencebillet = sanitize(req.body?.referencebillet);
    const rotaryBilletId = sanitize(req.body?.rotaryBilletId);
    const billid = sanitize(req.body?.billid);
    const brideName = sanitize(req.body?.brideName);
    const groomName = sanitize(req.body?.groomName);
    const payerFirstName = sanitize(req.body?.payerFirstName);
    const payerLastName = sanitize(req.body?.payerLastName);
    const payerEmail = sanitize(req.body?.payerEmail).toLowerCase();
    const status = sanitize(req.body?.status);
    const paymentStatus = sanitize(req.body?.paymentStatus);
    const siteStatus = sanitize(req.body?.siteStatus);
    const deliveryUrlRaw = sanitize(req.body?.deliveryUrl);

    if (!orderId || !userId || !brideName || !groomName || !payerEmail) {
      return res.status(400).json({
        success: false,
        error: 'orderId, userId, brideName, groomName and payerEmail are required'
      });
    }
    if (!isValidHttpUrl(deliveryUrlRaw)) {
      return res.status(400).json({ success: false, error: 'deliveryUrl is invalid' });
    }

    const deliveryUrl = normalizeHttpUrl(deliveryUrlRaw);
    const finalStatus = status || 'livre';
    const finalPaymentStatus = paymentStatus || 'livre';
    const finalSiteStatus = siteStatus || 'delivered';

    try {
      const qrPayload = JSON.stringify({
        orderId,
        referencebillet,
        deliveryUrl,
        brideName,
        groomName
      });
      const qrCodeDataUrl = await QRCode.toDataURL(qrPayload, { margin: 1, width: 320 });

      await db.query(
        `
          INSERT INTO rotary_wedding_site_deliveries (
            order_id,
            user_id,
            reference_billet,
            rotary_billet_id,
            bill_id,
            bride_name,
            groom_name,
            payer_first_name,
            payer_last_name,
            payer_email,
            delivery_url,
            qr_code_data_url,
            status,
            payment_status,
            site_status
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON DUPLICATE KEY UPDATE
            reference_billet = VALUES(reference_billet),
            rotary_billet_id = VALUES(rotary_billet_id),
            bill_id = VALUES(bill_id),
            bride_name = VALUES(bride_name),
            groom_name = VALUES(groom_name),
            payer_first_name = VALUES(payer_first_name),
            payer_last_name = VALUES(payer_last_name),
            payer_email = VALUES(payer_email),
            delivery_url = VALUES(delivery_url),
            qr_code_data_url = VALUES(qr_code_data_url),
            status = VALUES(status),
            payment_status = VALUES(payment_status),
            site_status = VALUES(site_status),
            updated_at = CURRENT_TIMESTAMP
        `,
        [
          orderId,
          userId,
          toNullable(referencebillet),
          toNullable(rotaryBilletId),
          toNullable(billid),
          brideName,
          groomName,
          toNullable(payerFirstName),
          toNullable(payerLastName),
          payerEmail,
          deliveryUrl,
          qrCodeDataUrl,
          finalStatus,
          finalPaymentStatus,
          finalSiteStatus
        ]
      );

      const html = buildDeliveryHtml({
        brideName,
        groomName,
        payerFirstName,
        payerLastName,
        referencebillet,
        deliveryUrl,
        qrCodeDataUrl
      });

      await transporter.sendMail({
        from: fromEmail,
        to: payerEmail,
        subject: `Votre site mariage est disponible (${brideName} & ${groomName})`,
        html
      });

      return res.json({
        success: true,
        message: 'Delivery link saved to SQL and email sent.',
        data: {
          id: orderId,
          recipient: payerEmail,
          qrCodeDataUrl
        }
      });
    } catch (err) {
      console.error('[POST /wedding/deliveries/site-link] failed:', err);
      return res.status(500).json({
        success: false,
        error: 'Failed to save delivery and send email',
        details: err?.message || String(err)
      });
    }
  });

  return router;
}

module.exports = { createWeddingDeliveryRoutes };
