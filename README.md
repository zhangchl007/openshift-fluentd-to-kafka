Openshift Fluentd Kafka customized images 

Since Redhat OpenShift 3.9 fluentd without kafka plugin ,I made the customized images as the request from client

The directory structure
```
tree
. 
├── Dockerfile 
├── kafka-plugin 
│ └── 0.2.2 
│ ├── fluent-plugin-kafka-0.1.3.gem 
│ ├── fluent-plugin-kafka-0.2.2.gem.bak 
│ ├── ltsv-0.1.0.gem 
│ ├── poseidon-0.0.5.gem 
│ ├── poseidon_cluster-0.3.3.gem 
│ ├── ruby-kafka-0.3.9.gem 
│ ├── zk-1.9.6.gem 
│ └── zookeeper-1.4.11.gem 
├── ocp.repo 
├── openshift 
│ ├── filter-exclude-journal-debug.conf 
│ ├── filter-k8s-meta.conf 
│ ├── filter-k8s-record-transform.conf 
│ ├── filter-kibana-transform.conf 
│ ├── filter-post-genid.conf 
│ ├── filter-pre-force-utf8.conf 
│ ├── filter-retag-journal.conf 
│ ├── filter-syslog-record-transform.conf 
│ ├── filter-viaq-data-model.conf 
│ ├── input-pre-systemd.conf 
│ ├── output-applications.conf 
│ ├── output-es-config.conf 
│ ├── output-es-ops-config.conf 
│ ├── output-es-ops-retry.conf 
│ ├── output-es-retry.conf 
│ ├── output-operations.conf 
│ ├── README 
│ └── system.conf 
└── ruby 
└── ruby-devel-2.0.0.648-33.el7_4.x86_64.rpm 

docker build -t registry.access.redhat.com/openshift3/logging-fluentd:kafka
```

The new images can be deployed with ds logging-fluentd once the customized fluentd images had been built

oc edit ds logging-fluentd

Add a new line ,then add the new items with key:value into fluentd configmap

@include configs.d/user/input-kafka-auditlog.conf

key:input-kafka-audilog.conf

value:
```
<source>
  @type tail
  path /var/log/audit-ocp.log
  pos_file /var/log/auditlog.pos
  time_format %Y-%m-%dT%H:%M:%S.%N%Z
  tag auditlog.requests
  format json
</source>

<filter auditlog**>
  @type record_transformer
  enable_ruby
  <record>
    @timestamp ${record['@timestamp'].nil? ? Time.at(time).getutc.to_datetime.rfc3339(6) : Time.parse(record['@timestamp']).getutc.to_datetime.rfc3339(6)}
    auditlog.hostname ${(begin; File.open('/etc/docker-hostname') { |f| f.readline }.rstrip; rescue; end)}
  </record>
</filter>

  <filter  auditlog**>
  type record_transformer
  enable_ruby
  <record>
     partition_key    {#partition}
  </record>
</filter>

#---output---
<match auditlog**>
   type kafka
   brokers  kafka1:9092,kafka2:9092,kafka3:9092
   default_topic  my-test
   output_data_type json
   output_include_tag  false
   output_include_time flase
   <buffer topic>
    flush_interval 5s
  </buffer>
   max_send_retries   3         
</match>

```
