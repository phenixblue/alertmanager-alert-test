## Alert Test for Prometheus AlertManager

This script was written to supply a method for generating an alert manually for Prometheus/AlertManager to validate
changes to the monitoring/alerting system. At the time this was written the target platform was CoreOS Tectonics.
I've tried to make it as flexible as possible, so it may work with other platforms with little to no modification.

As always.......this is not supported, **USE AT YOUR OWN RISK!!!**

```sh
Usage: alert-test.rb [options]

Specific options:
    -e, --endpoint ENDPOINT_URL      Specify the full endpoint URL for Alert Manager if the base domain is different than the default
    -c, --cluster CLUSTER_NAME       Specify the cluster to work in. This assumes the default base domain: "k8s.example.com"
    -u, --user USERNAME              Specify the username of for the AlertManager Instance.
    -h, --help
```


## NOTES

Normal operation of the script only requires you to supply a K8's cluster.

```sh
./alert-test.rb -c cluster1
```


This script assumes a base domain of "k8s.example.com: and an alertmanager url that
starts with **"https://alertmanager.xxxx"**. If the target url is different, in any way, use
the **"-e"** option to supply the full endpoint url.

```sh
alert-test.rb -u customurl.context.domain.com
```
