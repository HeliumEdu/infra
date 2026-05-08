function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Helium Classic shutdown (2026-08-01): /planner** and /settings** routes
    // were served by the legacy frontend. Redirect them to the new app.
    if (uri === '/planner' || uri.startsWith('/planner/') ||
        uri === '/settings' || uri.startsWith('/settings/')) {
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                location: { value: 'https://app.heliumedu.com/' }
            }
        };
    }

    return request;
}
