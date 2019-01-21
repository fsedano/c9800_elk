Pipeline to automatically retrieve traces from the new Cisco 9800 Wireless controller and display various info on a Kibana dashboard.


## Overview
One of the important serviceability aspects on the new c9800 wireless controller is the support for 'always on' traces. The always-on traces allow to investigate behaviour that happened on the past, even when no special debug was enabled.

As an example of this rich data, this demo periodically export the latest traces from the controller and sends them to a ELK (Elasticsearch, Logstash, Kibana) stack.

![Data flow](diagrams/arch-1.png?raw=true "Data flow")

The periodic trace export is done using several techniques available in IOS-XE:

* Embedded Event Manager
* TCL scripting

## Embedded Event Manager
Event manager is an XE feature that allows a customer to specify actions to be performed when a given event occurs.
In order to periodically export the trace, we use [Embedded Event Manager](https://www.cisco.com/c/en/us/products/ios-nx-os-software/ios-embedded-event-manager-eem/index.html) to periodically trigger a TCL script.

```
event manager directory user policy "bootflash:/user_eem"
!! Copy collect_wireless_logs.tcl to bootflash:/user_eem directory
event manager policy collect_wireless_logs.tcl type user
event manager applet WirelessLogs
 event timer watchdog time 60 maxrun 200
 action 1.0 cli command "enable"
 action 2.0 cli command "event manager run collect_wireless_logs.tcl"
```

## TCL scripting

Embedded Event Manager triggers this [TCL](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/eem/configuration/15-mt/eem-15-mt-book/eem-policy-tcl.html) script, which collects the traces since last period and uploads them to a off-box location. Collecting the traces can be a time consuming operation, but this script runs asynchronously so it has no impact on the controller operation.

## Logstash plugin

Once the traces are stored in the off-box storage, Logstash processes them. The traces we're interested in are the ones relevant to the client state machine. For this type of data, the [aggregation Logstash plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-aggregate.html) is very useful.

## Sample dashboard output


![Dashboard](diagrams/dashboard1.png?raw=true "Dashboard")
