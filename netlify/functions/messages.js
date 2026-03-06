// Netlify Function: fetch form submissions for admin inbox
exports.handler = async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, X-Admin-Password',
    'Access-Control-Allow-Methods': 'GET, DELETE, OPTIONS'
  };

  // Handle CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers, body: '' };
  }

  // Check admin password
  const password = event.queryStringParameters?.password ||
                   event.headers['x-admin-password'];
  const adminPassword = process.env.ADMIN_PASSWORD;

  if (!adminPassword || password !== adminPassword) {
    return {
      statusCode: 401,
      headers,
      body: JSON.stringify({ error: 'غير مصرح — كلمة المرور غير صحيحة' })
    };
  }

  const token = process.env.NETLIFY_TOKEN;
  const siteId = process.env.SITE_ID; // auto-set by Netlify

  if (!token) {
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'NETLIFY_TOKEN غير مُعرّف في متغيرات البيئة' })
    };
  }

  try {
    // DELETE: delete a specific submission
    if (event.httpMethod === 'DELETE') {
      const submissionId = event.queryStringParameters?.id;
      if (!submissionId) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({ error: 'معرف الرسالة مطلوب' })
        };
      }

      const delRes = await fetch(
        `https://api.netlify.com/api/v1/submissions/${submissionId}`,
        {
          method: 'DELETE',
          headers: { Authorization: `Bearer ${token}` }
        }
      );

      if (!delRes.ok) {
        return {
          statusCode: delRes.status,
          headers,
          body: JSON.stringify({ error: 'فشل حذف الرسالة' })
        };
      }

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ success: true, message: 'تم حذف الرسالة' })
      };
    }

    // GET: fetch all submissions
    const page = event.queryStringParameters?.page || 1;
    const perPage = event.queryStringParameters?.per_page || 50;

    const response = await fetch(
      `https://api.netlify.com/api/v1/sites/${siteId}/submissions?per_page=${perPage}&page=${page}`,
      {
        headers: { Authorization: `Bearer ${token}` }
      }
    );

    if (!response.ok) {
      return {
        statusCode: response.status,
        headers,
        body: JSON.stringify({ error: 'فشل جلب الرسائل من Netlify' })
      };
    }

    const submissions = await response.json();

    // Format the submissions
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
      statusCode: 200,
      headers,
      body: JSON.stringify({
        total: messages.length,
        messages
      })
    };
  } catch (err) {
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message })
    };
  }
};