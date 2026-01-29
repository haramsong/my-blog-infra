var defined = /^\/.+(\.\w+$)/;

function handler(event) {
  var request = event.request;
  var uri = request.uri;

  // 파일 확장자가 없고 trailing slash가 없으면 리다이렉트
  if (!defined.test(uri) && !uri.endsWith('/')) {
    console.log('Redirect [' + uri + '] with trailing slash [' + uri + '/]');
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: { location: { value: uri + '/' } }
    };
  }

  // trailing slash가 있으면 index.html 추가
  if (!defined.test(uri)) {
    request.uri = uri + 'index.html';
    console.log('Request for [' + olduri + '] rewritten to [' + request.uri + ']');
  }

  return request;
}
