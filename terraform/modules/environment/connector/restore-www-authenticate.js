// Lambda function URLs rename WWW-Authenticate, which MCP clients read on a 401 to discover the authorization server
function handler(event) {
    var headers = event.response.headers;
    var remapped = headers['x-amzn-remapped-www-authenticate'];

    if (remapped) {
        headers['www-authenticate'] = remapped;
        delete headers['x-amzn-remapped-www-authenticate'];
    }

    return event.response;
}
