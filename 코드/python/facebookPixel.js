// 파일명: facebookPixel.js

(function(f, b, e, v, n, t, s) {
    if (f.fbq) return;
    n = f.fbq = function() {
      n.callMethod ?
        n.callMethod.apply(n, arguments) : n.queue.push(arguments);
    };
    if (!f._fbq) f._fbq = n;
    n.push = n;
    n.loaded = !0;
    n.version = '2.0';
    n.queue = [];
    t = b.createElement(e);
    t.async = !0;
    t.src = v;
    s = b.getElementsByTagName(e)[0];
    s.parentNode.insertBefore(t, s);
  })(window, document, 'script', 'https://connect.facebook.net/en_US/fbevents.js');
  
  // 여기서 '{your-pixel-id-goes-here}' 부분을 실제 페이스북 픽셀 ID로 대체해야 합니다.
  fbq('init', '1379884515792901');
  fbq('track', 'PageView');
  fbq('track', 'Purchase', {currency: "USD", value: 30.00});