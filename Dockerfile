FROM markvnext/mono

ENV KRE_VERSION 1.0.0-beta3
ENV KVM_USER_HOME /opt/k

RUN apt-get -qq update && apt-get -qqy install \
    unzip supervisor autoconf automake build-essential libtool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/lib/dpkg/lists/*
    
# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN LIBUV_VERSION=1.4.1 \
    && curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
    && cd /usr/local/src/libuv-$LIBUV_VERSION \
    && sh autogen.sh && ./configure && make && make install \
    && cd / \
    && rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
    && ldconfig


RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/master/kvminstall.sh | KRE_USER_HOME=$KVM_USER_HOME sh
RUN bash -c "source $KVM_USER_HOME/kvm/kvm.sh \
    && kvm install $KRE_VERSION -a default \
    && kvm alias default | xargs -i ln -s $KVM_USER_HOME/runtimes/{} $KVM_USER_HOME/runtimes/default"

ENV PATH $PATH:$KVM_USER_HOME/runtimes/default/bin

CMD ["/usr/bin/supervisord"]
