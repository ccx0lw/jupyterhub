FROM openjdk:19-jdk-alpine3.15
MAINTAINER ccx0lw <fcjava@163.com>

ENV DEBIAN_FRONTEND noninteractive

ENV LANG=C.UTF-8

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.32-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

RUN apk add --no-cache bash shadow sudo curl linux-pam ca-certificates libintl gettext && \
            update-ca-certificates && \
            ln -s /lib /lib64 && \
            addgroup sudo
            
RUN apk add --virtual .build-deps build-base automake autoconf libtool linux-pam-dev openssl-dev wget unzip

# 安装 conda
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV CONTAINER_UID 1000
ENV INSTALLER Miniconda3-latest-Linux-x86_64.sh
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    echo $(wget --quiet -O - https://repo.continuum.io/miniconda/ \
    | grep -A3 $INSTALLER \
    | tail -n1 \
    | cut -d\> -f2 \
    | cut -d\< -f1 ) $INSTALLER  && \
    /bin/bash $INSTALLER -f -b -p $CONDA_DIR && \
    rm $INSTALLER

# python3
RUN conda install -y python=3 && \
    conda update conda && \
    conda clean --all --yes

# jupyterhub ... 
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx jupyterhub jupyterlab notebook nbgitpuller && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman matplotlib && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman pytorch torchvision torchaudio torchtext && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx xeus-cling && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx ipywidgets && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx bash_kernel && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx go && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx elyra jupyter_console jupyterlab-git prompt-toolkit && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx -c beakerx beakerx_kernel_groovy beakerx_kernel_kotlin beakerx_kernel_clojure beakerx_kernel_scala && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx lua ruby && \
    conda update --all && \
    conda clean --all --yes
    
RUN conda install -c conda-forge -c pytorch -c krinsman -c beakerx voila ipyvuetify bqplot voila-vuetify && \
    conda update --all && \
    conda clean --all --yes

# An error occurred. ValueError: Please install nodejs ＞=12.0.0 before continuing.
# 参考：https://blog.csdn.net/m0_59249795/article/details/124660726
#      https://computingforgeeks.com/how-to-install-nodejs-on-ubuntu-debian-linux-mint/
# conda使用的是14.x的版本，但是matplotlib使用的是6.x的版本被覆盖了。导致最终labextension的时候conda用到的版本过低
# nodejs
RUN conda upgrade -c conda-forge nodejs && \
    node -v
                                                        
# jupyter extension
RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix 
RUN jupyter serverextension enable --py jupyterlab 
RUN jupyter nbextension enable --py --sys-prefix ipyvuetify 
RUN jupyter nbextension enable --py --sys-prefix bqplot 
# labextension     -- jupyterlab-logout
RUN jupyter labextension install jupyterlab-plotly 
RUN jupyter labextension install jupyterlab-drawio 
RUN jupyter labextension install jupyterlab-topbar-extension 
RUN jupyter labextension install jupyterlab-theme-toggle 
RUN jupyter labextension install @jupyterlab/toc 
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager 
RUN jupyter labextension install @elyra/pipeline-editor-extension 
RUN jupyter labextension install jupyter-vuetify 
RUN jupyter labextension install bqplot 
RUN jupyter labextension update --all
    
RUN pip install markdown
    
# javascript
RUN npm --unsafe-perm i -g ijavascript && \
    ijsinstall --install=global
    
RUN BUILD='alpine-sdk linux-headers gcc g++ gfortran make cmake freetype-dev musl-dev libpng-dev libxml2-dev libxslt-dev tar make curl build-base wget gnupg perl perl-dev tar zeromq zeromq-dev libffi-dev jpeg-dev zlib-dev' && \
    apk update --no-cache && apk add --no-cache --virtual=build-deps ${BUILD}
    
# perl
RUN curl -sL http://cpanmin.us | perl - App::cpanminus
RUN export ARCHFLAGS='-arch x86_64' && \
    cpanm -n --mirror http://mirrors.163.com/cpan --mirror-only --build-args 'OTHERLDFLAGS=' ZMQ::LibZMQ3 Devel::IPerl PDL Moose MooseX::AbstractFactory MooseX::AbstractMethod MooseX::Storage Test::More

# java
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip

RUN mkdir ijava-kernel && \
    unzip ijava-kernel.zip -d ijava-kernel && \
    cd ijava-kernel && \
    python3 install.py --sys-prefix
    
# go
RUN cp /opt/conda/bin/x86_64-conda_cos6-linux-gnu-cc /opt/conda/bin/x86_64-conda-linux-gnu-cc && \ 
    go get -u github.com/gopherdata/gophernotes && \ 
    cd ~/go/src/github.com/gopherdata/gophernotes && \
    GOPATH=~/go GO111MODULE=on go install . && \
    cp ~/go/bin/gophernotes /usr/local/bin/ && \
    mkdir -p /usr/local/share/jupyter/kernels/gophernotes && \
    cp -r ./kernel/* /usr/local/share/jupyter/kernels/gophernotes 

# lua
RUN pip3 install ilua

# ruby
RUN gem install cztop rbczmq && \
    gem install iruby && \
    iruby register --force
    
RUN pip3 install --upgrade --force jupyter-console jupyterlab-git

RUN rm -rf /tmp/* /var/cache/apk/* && rm -rf /root/.cache && rm -rf ijava-kernel.zip

WORKDIR /$USER

COPY scripts /scripts

ADD settings/jupyter_notebook_config.py /etc/jupyter/
ADD settings/jupyterhub_config.py /etc/jupyterhub/

RUN chmod -R 755 /scripts

EXPOSE 8000 8866

CMD ["/scripts/init.sh"]
