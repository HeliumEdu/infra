// Lambda function URLs rename WWW-Authenticate, which MCP clients read on a 401 to discover the authorization server.
// An origin-response trigger, since CloudFront doesn't run viewer-response functions on 4xx/5xx responses.
exports.handler = async (event) => {
    const response = event.Records[0].cf.response;
    const remapped = response.headers['x-amzn-remapped-www-authenticate'];

    if (remapped) {
        response.headers['www-authenticate'] = [{key: 'WWW-Authenticate', value: remapped[0].value}];
        delete response.headers['x-amzn-remapped-www-authenticate'];
    }

    return response;
};
