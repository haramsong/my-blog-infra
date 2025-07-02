var regexExpr = /^\/.+(\.\w+$)/;

function handler(event) {
  var request = event.request;
  var olduri = request.uri;

  if (!regexExpr.test(olduri)) {
    request.uri = olduri.replace(/\/?$/, '/') + 'index.html';
    console.log('Request for [' + olduri + '] rewritten to [' + request.uri + ']');
  }

  return request;
}
