FROM registry.access.redhat.com/openshift3/logging-fluentd:v3.9.30-2
ADD ocp.repo /etc/yum.repos.d/
ADD openshift /etc/fluent/configs.d/openshift
ADD ruby /ruby
RUN echo 'nameserver 192.168.233.2' >>  /etc/resolv.conf && \
    yum --disablerep=\* --enablerepo=ocp -y install --setopt=tsflags=nodocs \ 
    gcc-c++ patch make iputils net-tools nc && \
    cd /ruby && \
    rpm -Uvh *.rpm  && \
    rm -rf /ruby && \
    rm -rf /etc/yum.repos.d/* 
ADD kafka-plugin/ ${HOME}/
RUN fluent-gem install 0.2.2/zookeeper-1.4.11.gem --local && \
    fluent-gem install 0.2.2/zk-1.9.6.gem --local && \
    fluent-gem install 0.2.2/poseidon-0.0.5.gem --local && \
    fluent-gem install 0.2.2/poseidon_cluster-0.3.3.gem --local && \
    fluent-gem install 0.2.2/ltsv-0.1.0.gem --local && \
    fluent-gem install 0.2.2/fluent-plugin-kafka-0.1.3.gem --local
