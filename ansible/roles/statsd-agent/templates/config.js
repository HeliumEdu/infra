{
    graphitePort: 2003,
    graphiteHost: "{{ graphite_host }}",
    graphite: {
        legacyNamespace: false
    },
    port: 8125,
    backends: ["./backends/console", "./backends/graphite"],
    debug: false
}
