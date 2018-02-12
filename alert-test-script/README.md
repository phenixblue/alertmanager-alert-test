## Alert Test for Prometheus AlertManager

This script was written to supply a method for generating an alert manually for Prometheus/AlertManager to validate
changes to the monitoring/alerting system. At the time this was written the target platform was CoreOS Tectonics.
I've tried to make it as flexible as possible, so it may work with other platforms with little to no modification.

As always.......this is not supported, **USE AT YOUR OWN RISK!!!**

```sh
Usage: ./alert-test.rb [options]

Specific options:
    -u, --url FULL_URL               Specify the full URL for Alert Manager if the base domain is different than the default
    -c, --context CONTEXT_NAME       Specify the context to work in. This assumes the default base domain: "k8s.example.com"
    -h, --help
```

## NOTES

Normal operation of the script only requires you to supply a K8's context/cluster.

```sh
./alert-test.rb -c cluster1
```

This script assumes a base domain of "k8s.example.com" and an alertmanager url that
starts with **https://alertmanager.xxxx**. If the target url is different, in any way, use
the **-u** option to supply the full custom url.

```sh
./alert-test.rb -u customurl.context.domain.com
./alert-test.rb -u alerts.cluster1.kube.example.com
```
