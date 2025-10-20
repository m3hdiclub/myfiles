/**
 * Cloudflare Worker - DoH Proxy with Ad-blocking
 */

const DOH_PROVIDERS = [
  {
    name: "AdGuard",
    url: "https://dns.adguard-dns.com/dns-query",
    weight: 40
  },
  {
    name: "Cloudflare",
    url: "https://cloudflare-dns.com/dns-query",
    weight: 35
  },
  {
    name: "AdGuard-Family",
    url: "https://family.adguard-dns.com/dns-query",
    weight: 15
  },
  {
    name: "NextDNS",
    url: "https://dns.nextdns.io/dns-query",
    weight: 10
  }
];

const CACHE_TTL = 300;

export default {
  async fetch(request, env, ctx) {
    return handleRequest(request, env, ctx);
  }
};

async function handleRequest(request, env, ctx) {
  const url = new URL(request.url);
  
  if (url.pathname === '/') {
    return serveLandingPage(request);
  }
  
  if (request.method === 'OPTIONS') {
    return handleCORS();
  }

  if (url.pathname !== '/dns-query') {
    return new Response('Invalid endpoint', { status: 400 });
  }

  const isGet = request.method === 'GET';
  const isPost = request.method === 'POST';
  
  if (!isGet && !isPost) {
    return new Response('Method not allowed', { status: 405 });
  }

  if (isGet && !url.searchParams.has('dns')) {
    return new Response('Missing DNS query parameter', { status: 400 });
  }

  const selectedProvider = selectProvider(DOH_PROVIDERS);
  
  try {
    const targetUrl = selectedProvider.url + url.search;
    const headers = new Headers(request.headers);
    
    if (isPost) {
      headers.set('Content-Type', 'application/dns-message');
    } else {
      headers.set('Accept', 'application/dns-message');
    }
    
    headers.set('User-Agent', 'DoH-Proxy/2.0');

    const upstreamRequest = new Request(targetUrl, {
      method: request.method,
      headers: headers,
      body: isPost ? await request.arrayBuffer() : null,
      redirect: 'follow'
    });

    const response = await fetch(upstreamRequest);
    const responseHeaders = new Headers(response.headers);
    
    responseHeaders.set('Access-Control-Allow-Origin', '*');
    responseHeaders.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    responseHeaders.set('Access-Control-Allow-Headers', 'Content-Type, Accept');
    responseHeaders.set('Cache-Control', `public, max-age=${CACHE_TTL}`);
    responseHeaders.set('Expires', new Date(Date.now() + CACHE_TTL * 1000).toUTCString());

    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: responseHeaders
    });
  } catch (error) {
    return await tryFallbackProviders(request, url, selectedProvider);
  }
}

function serveLandingPage(request) {
  const workerUrl = new URL(request.url);
  workerUrl.pathname = '/dns-query';
  const dnsEndpoint = workerUrl.toString();
  
  const html = `<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>سرویس DNS شخصی - DoH</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      padding: 20px;
      color: #fff;
    }
    .container { max-width: 900px; margin: 0 auto; }
    header {
      text-align: center;
      padding: 40px 20px;
      margin-bottom: 30px;
    }
    h1 {
      font-size: 2.8rem;
      margin-bottom: 15px;
      text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    .subtitle {
      font-size: 1.2rem;
      opacity: 0.9;
      margin-bottom: 20px;
    }
    .endpoint-card {
      background: rgba(255, 255, 255, 0.15);
      backdrop-filter: blur(10px);
      border-radius: 20px;
      padding: 30px;
      margin-bottom: 30px;
      border: 1px solid rgba(255, 255, 255, 0.2);
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }
    .endpoint-url {
      background: rgba(0, 0, 0, 0.3);
      border-radius: 10px;
      padding: 20px;
      font-family: 'Courier New', monospace;
      font-size: 1rem;
      margin: 20px 0;
      word-break: break-all;
      text-align: left;
      direction: ltr;
    }
    .copy-btn {
      background: #fff;
      color: #667eea;
      border: none;
      padding: 12px 30px;
      border-radius: 10px;
      font-weight: 600;
      font-size: 1rem;
      cursor: pointer;
      transition: all 0.3s ease;
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
    }
    .copy-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
    }
    .card {
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(10px);
      border-radius: 16px;
      padding: 25px;
      margin-bottom: 20px;
      border: 1px solid rgba(255, 255, 255, 0.2);
    }
    h2 {
      font-size: 1.8rem;
      margin-bottom: 15px;
    }
    .features {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
      margin: 20px 0;
    }
    .feature {
      background: rgba(255, 255, 255, 0.1);
      padding: 20px;
      border-radius: 12px;
      text-align: center;
    }
    .feature h3 {
      font-size: 1.3rem;
      margin-bottom: 10px;
    }
    .providers {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-top: 15px;
    }
    .provider {
      background: rgba(255, 255, 255, 0.1);
      border-radius: 10px;
      padding: 15px;
      text-align: center;
    }
    .provider-name {
      font-weight: 600;
      font-size: 1.1rem;
      margin-bottom: 5px;
    }
    .provider-weight {
      background: rgba(255, 255, 255, 0.2);
      display: inline-block;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 0.9rem;
    }
    .highlight {
      background: rgba(255, 255, 255, 0.15);
      padding: 15px;
      border-radius: 10px;
      margin: 15px 0;
      border-right: 4px solid #10b981;
    }
    .copy-notification {
      position: fixed;
      top: 20px;
      left: 20px;
      background: #10b981;
      color: white;
      padding: 15px 25px;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
      transform: translateX(-200%);
      transition: transform 0.3s ease;
      z-index: 1000;
    }
    .copy-notification.show {
      transform: translateX(0);
    }
    footer {
      text-align: center;
      padding: 30px 0;
      opacity: 0.8;
    }
    @media (max-width: 768px) {
      h1 { font-size: 2rem; }
      .subtitle { font-size: 1rem; }
      .card { padding: 20px; }
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>🚀 سرویس DNS شخصی</h1>
      <p class="subtitle">دور زدن تحریم و فیلترینگ با حذف تبلیغات</p>
    </header>
    
    <div class="endpoint-card">
      <h2>آدرس DNS شما</h2>
      <div class="endpoint-url" id="endpointUrl">${dnsEndpoint}</div>
      <button class="copy-btn" onclick="copyToClipboard()">کپی آدرس</button>
    </div>
    
    <div class="features">
      <div class="feature">
        <h3>🔓 دور زدن تحریم</h3>
        <p>دسترسی به یوتیوب، اسپاتیفای و سرویس‌های فیلتر</p>
      </div>
      <div class="feature">
        <h3>🛡️ حذف تبلیغات</h3>
        <p>مسدودسازی خودکار تبلیغات و ردیاب‌ها</p>
      </div>
      <div class="feature">
        <h3>⚡ سرعت بالا</h3>
        <p>استفاده از شبکه جهانی Cloudflare</p>
      </div>
    </div>
    
    <div class="card">
      <h2>📡 سرورهای DNS</h2>
      <div class="highlight">
        <strong>ترکیب بهینه:</strong> 40% AdGuard برای حذف تبلیغات + 35% Cloudflare برای دور زدن فیلتر
      </div>
      <div class="providers">
        <div class="provider">
          <div class="provider-name">🛡️ AdGuard</div>
          <div class="provider-weight">40%</div>
        </div>
        <div class="provider">
          <div class="provider-name">🔓 Cloudflare</div>
          <div class="provider-weight">35%</div>
        </div>
        <div class="provider">
          <div class="provider-name">👨‍👩‍👧 AdGuard Family</div>
          <div class="provider-weight">15%</div>
        </div>
        <div class="provider">
          <div class="provider-name">🔒 NextDNS</div>
          <div class="provider-weight">10%</div>
        </div>
      </div>
    </div>
    
    <footer>
      <p>DoH Proxy | Powered by Cloudflare Workers</p>
    </footer>
  </div>
  
  <div class="copy-notification" id="copyNotification">آدرس کپی شد!</div>
  
  <script>
    function copyToClipboard() {
      const endpointUrl = document.getElementById('endpointUrl').textContent;
      navigator.clipboard.writeText(endpointUrl).then(() => {
        const notification = document.getElementById('copyNotification');
        notification.classList.add('show');
        setTimeout(() => notification.classList.remove('show'), 3000);
      }).catch(err => {
        alert('خطا در کپی کردن: ' + endpointUrl);
      });
    }
  </script>
</body>
</html>`;
  
  return new Response(html, {
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'public, max-age=3600'
    }
  });
}

function handleCORS() {
  return new Response(null, {
    status: 204,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Accept',
      'Access-Control-Max-Age': '86400'
    }
  });
}

function selectProvider(providers) {
  const totalWeight = providers.reduce((sum, provider) => sum + provider.weight, 0);
  let random = Math.random() * totalWeight;
  
  for (const provider of providers) {
    if (random < provider.weight) {
      return provider;
    }
    random -= provider.weight;
  }
  
  return providers[0];
}

async function tryFallbackProviders(request, url, failedProvider) {
  const fallbackProviders = DOH_PROVIDERS.filter(p => p.name !== failedProvider.name);
  
  for (const provider of fallbackProviders) {
    try {
      const targetUrl = provider.url + url.search;
      const headers = new Headers(request.headers);
      
      if (request.method === 'POST') {
        headers.set('Content-Type', 'application/dns-message');
      } else {
        headers.set('Accept', 'application/dns-message');
      }
      headers.set('User-Agent', 'DoH-Proxy/2.0');
      
      const upstreamRequest = new Request(targetUrl, {
        method: request.method,
        headers: headers,
        body: request.method === 'POST' ? await request.arrayBuffer() : null,
        redirect: 'follow'
      });
      
      const response = await fetch(upstreamRequest);
      
      if (response.ok) {
        const responseHeaders = new Headers(response.headers);
        responseHeaders.set('Access-Control-Allow-Origin', '*');
        responseHeaders.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        responseHeaders.set('Access-Control-Allow-Headers', 'Content-Type, Accept');
        responseHeaders.set('Cache-Control', `public, max-age=${CACHE_TTL}`);
        
        return new Response(response.body, {
          status: response.status,
          statusText: response.statusText,
          headers: responseHeaders
        });
      }
    } catch (error) {
      continue;
    }
  }
  
  return new Response('All DNS providers unavailable', { status: 503 });
}
