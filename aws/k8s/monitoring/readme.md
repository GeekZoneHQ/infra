The value field for "alertmanager.yaml" in the "alertmanager-monitoring-kube-prometheus-alertmanager" secret contains the configuration that allows Prometheus to send data to Squadcast and Watchdog.

Squadcast is an application that sends alerts to the k8s cluster administrators as soon as an alert is triggered by Prometheus. 

Watchdog constantly performs heart-beat checks on the k8s cluster: if a check fail, it means that the cluster is down and an email is sent to the k8s cluster administrators.