const axios = require('axios');
const username = 'afup';
const key = 'b3b8814e-4639-46a1-97c3-bf37401dc54b';
const auth = 'Basic ' + Buffer.from(`${username}:${key}`).toString('base64');
const payload = {
  payer_msisdn: '+24177001255',
  payer_email: 'client1@gmail.com',
  payer_name: 'samira Kananga',
  amount: 100,
  external_reference: 'TEST-' + Date.now(),
  short_description: 'auth-check',
  expiry_period: '10',
  return_url: 'https://example.com/return',
  notification_url: 'https://example.com/webhook'
};

(async () => {
  for (const url of ['https://stg.billing-easy.com/api/v1/merchant/e_bills', 'https://lab.billing-easy.net/api/v1/merchant/e_bills']) {
    try {
      const r = await axios.post(url, payload, {
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          Authorization: auth
        },
        timeout: 15000
      });
      console.log('OK', url, r.status, JSON.stringify(r.data));
    } catch (e) {
      console.log('ERR', url, e.response?.status || e.code, JSON.stringify(e.response?.data || e.message));
    }
  }
})();
