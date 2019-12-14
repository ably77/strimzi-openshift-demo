# Support for multiple namespaces

The operator can import dashboards from either one, some or all namespaces. By default it will only look for dashboards in its own namespace.
By setting the `--scan-all` or `--namespaces` flags the operator can watch for dashboards in other namespaces.

The `Grafana` and `GrafanaDataSource` resources do not support multiple namespaces and are only reconciled if created in the operators namespace.

## Watching for dashboards in all namespaces

Set the `--scan-all` flag to watch for dashboards in all namespaces. Cluster wide permissions for the `grafana-operator` service account are required (see `deploy/cluster_roles`).

## Watching for dashboards in some namespaces

You can provide a comma separated list of watch namespaces using the `--namespaces` flag. The format is `--namespaces=<NS_1,NS_2,...,NS_N>`, for example: `--namespaces=grafana,dashboards,example_namespace`.
The same cluster wide permissions as for watching all namespaces are required.

*NOTE*: `--scan-all` and `--namespaces` are mutually exclusive. You can only use one at a time.