Pipeline to automatically retrieve traces from the new Cisco 9800 Wireless controller and display various info on a Kibana dashboard.

On the 9800 wireless controller, on top of the rich set of data exported thru gRPC, 

One of the important serviceability aspects on the new c9800 wireless controller is the support for 'always on' traces. The always-on traces allow to investigate behaviour that happened on the past, even when no special debug was enabled.

As an example of this rich data, this demo periodically export the latest traces from the controller and sends them to a ELK (Elasticsearch, Logstash, Kibana) stack.

![Data flow](diagrams/arch-1.png?raw=true "Data flow")

The periodic trace export is done using several techniques available in IOS-XE:

 Event Manager
 TCL scripting




![Dashboard](diagrams/dashboard1.png?raw=true "Dashboard")
