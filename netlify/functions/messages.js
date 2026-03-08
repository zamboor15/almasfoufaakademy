const crypto = require('crypto');

// Password hash - SHA-256 of "Fadhil Abbas 1973"
const PASSWORD_HASH = '4aa8681ef3eabdf6c040c6220cdb029797b9f1df20582dd3e00ab8b132c8ed2c';

function verifyPassword(password) {
  if (!password) return false;
  const hash = crypto.createHash('sha256').update(password).digest('hex');
  return hash === PASSWORD_HASH;
}

exports.handler = async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, X-Admin-Password',
    'Access-Control-Allow-Methods': 'GET, DELETE, OPTIONS'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers, body: '' };
  }

  // Check admin password via hash
  const password = event.queryStringParameters?.password ||
                   event.headers['x-admin-password'];

  if (!verifyPassword(password)) {
    return {
      statusCode: 401,
      headers,
      body: JSON.stringify({ error: 'كلمة المرور غير صحيحة' })
    };
  }

  // Use Netlify API with token from env (SITE_ID is auto-set)
  const token = process.env.NETLIFY_TOKEN;
  const siteId = process.env.SITE_ID;

  if (!token || !siteId) {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        total: 0,
        messages: [],
        notice: 'لوحة الادارة تعمل. لعرض الرسائل، اضف NETLIFY_TOKEN في متغيرات البيئة في Netlify Dashboard.'
      })
    };
  }

  try {
    if (event.httpMethod === 'DELETE') {
      const submissionId = event.queryStringParameters?.id;
      if (!submissionId) {
        return {
          statusCode: 400, headers,
          body: JSON.stringify({ error: 'معرف الرسالة مطلوب' })
        };
      }

      const delRes = await fetch(
        `https://api.netlify.com/api/v1/submissions/${submissionId}`,
        { method: 'DELETE', headers: { Authorization: `Bearer ${token}` } }
      );

      return {
        statusCode: delRes.ok ? 200 : delRes.status,
        headers,
        body: JSON.stringify(delRes.ok
          ? { success: true, message: 'تم حذف الرسالة' }
          : { error: 'فشل حذف الرسالة' })
      };
    }

    // GET submissions
    const page = event.queryStringParameters?.page || 1;
    const perPage = event.queryStringParameters?.per_page || 50;

    const response = await fetch(
      `https://api.netlify.com/api/v1/sites/${siteId}/submissions?per_page=${perPage}&page=${page}`,
      { headers: { Authorization: `Bearer ${token}` } }
    );

    if (!response.ok) {
      return {
        statusCode: response.status, headers,
        body: JSON.stringify({ error: 'فشل جلب الرسائل' })
      };
    }

    const submissions = await response.json();
    const messages = submissions.map(s => ({
      id: s.id,
      name: s.data?.name || '',
      email: s.data?.email || '',
      phone: s.data?.phone || '',
      type: s.data?.type || '',
      opportunity: s.data?.opportunity || '',
      message: s.data?.message || '',
      date: s.created_at,
      form: s.form_name
    }));

    return {
      statusCode: 200, headers,
      body: JSON.stringify({ total: messages.length, messages })
    };
  } catch (err) {
    return {
      statusCode: 500, headers,
      body: JSON.stringify({ error: err.message })
    };
  }
};