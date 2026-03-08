const { getStore } = require("@netlify/blobs");

exports.handler = async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Cache-Control': 'no-cache'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers, body: '' };
  }

  try {
    const store = getStore("visitors");
    const page = event.queryStringParameters?.page || "total";

    // Read current count
    let countStr = await store.get(page);
    let count = countStr ? parseInt(countStr, 10) : 0;

    // POST = increment
    if (event.httpMethod === 'POST') {
      count += 1;
      await store.set(page, String(count));
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ page, count })
    };
  } catch (err) {
    // Fallback if Blobs not available - use simple in-memory
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ page: "total", count: -1, fallback: true })
    };
  }
};
