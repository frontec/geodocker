FROM ubuntu:xenial
LABEL maintainer="jose.macchi@frontec.net"
#Thanks to winsent<pipetc@gmail.com>
#Thanks to jailbirt<jailbirt@interactar.com>
#Thanks to jgzurano<jgzurano@interactar.com>

ENV DEBIAN_FRONTEND noninteractive
ENV GDAL_PATH /usr/share/gdal
ENV GEOSERVER_HOME /opt/geoserver
ENV JAVA_HOME /usr
ENV GDAL_DATA $GDAL_PATH/2.1
ENV PATH $GDAL_PATH:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/jni:/usr/share/java

RUN export DEBIAN_FRONTEND=noninteractive
RUN dpkg-divert --local --rename --add /sbin/initctl

# Install packages

RUN \
  apt-get -y update --fix-missing && \
  apt-get -y install wget iproute2 unzip software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get -y update && \
  wget "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=230532_2f38c3b165be4555a1fa6e98c45e0808" -O ~/jdk-8u151-linux-x64.tar.gz && \
  cd ~/ && tar xzf ~/jdk-8u151-linux-x64.tar.gz && mkdir -p /usr/lib/jvm && mv ~/jre1.8.0_161 /usr/lib/jvm/java-8-oracle && \
  update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/bin/java 100 && \
  apt-get install -y python-software-properties && \
  add-apt-repository -y ppa:ubuntugis/ppa && \
  apt-get -y update && \
  apt-get install -y gdal-bin=2.1.3+dfsg-1~xenial2 libgdal-java && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer && \
  rm -rf /tmp/* /var/tmp/*

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH

# Get native JAI and ImageIO

RUN \
    cd $JAVA_HOME && \
    ln -s $JAVA_HOME jre && \
    wget http://data.boundlessgeo.com/suite/jai/jai-1_1_3-lib-linux-amd64-jdk.bin && \
    echo "yes" | sh jai-1_1_3-lib-linux-amd64-jdk.bin && \
    rm jai-1_1_3-lib-linux-amd64-jdk.bin

RUN \
    cd $JAVA_HOME && \
    ln -s $JAVA_HOME jre && \
    export _POSIX2_VERSION=199209 && \
    wget http://data.opengeo.org/suite/jai/jai_imageio-1_1-lib-linux-amd64-jdk.bin && \
    echo "yes" | sh jai_imageio-1_1-lib-linux-amd64-jdk.bin && \
    rm jai_imageio-1_1-lib-linux-amd64-jdk.bin

#
# GEOSERVER INSTALLATION
#
ENV GEOSERVER_VERSION 2.13.1

# Get GeoServer
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-bin.zip -O ~/geoserver.zip &&\
    unzip ~/geoserver.zip -d /opt && mv -v /opt/geoserver* /opt/geoserver && \
    rm ~/geoserver.zip

# Get OGR plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-ogr-wfs-plugin.zip -O ~/geoserver-ogr-plugin.zip &&\
    unzip -o ~/geoserver-ogr-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-ogr-plugin.zip
    
# Get GDAL plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-gdal-plugin.zip -O ~/geoserver-gdal-plugin.zip &&\
    unzip -o ~/geoserver-gdal-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-gdal-plugin.zip

# Get import plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-importer-plugin.zip -O ~/geoserver-importer-plugin.zip &&\
    unzip -o ~/geoserver-importer-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-importer-plugin.zip

# Replace GDAL Java bindings
RUN rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/imageio-ext-gdal-bindings-*.jar
RUN cp /usr/share/java/gdal.jar $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/gdal.jar

# Remove geoserver jai-core
RUN rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_*.jar

# Clustering plugin (manual url set)
RUN wget -c http://ares.opengeo.org/geoserver/master/community-latest/geoserver-2.13-SNAPSHOT-jms-cluster-plugin.zip -O ~/jms.zip &&\
    unzip -o ~/jms.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ &&\
    rm ~/jms.zip

#Cgastrel Plugins
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-printing-plugin.zip -O ~/geoserver-printing-plugin.zip &&\
    unzip ~/geoserver-printing-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-printing-plugin.zip

RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-css-plugin.zip -O ~/geoserver-css-plugin.zip &&\
    unzip ~/geoserver-css-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-css-plugin.zip

RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-querylayer-plugin.zip -O ~/geoserver-querylayer-plugin.zip &&\
    unzip ~/geoserver-querylayer-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-querylayer-plugin.zip

#GWS-S3 Plugin (manual url set)
RUN wget -c https://build.geoserver.org/geoserver/2.13.x/community-latest/geoserver-2.13-SNAPSHOT-gwc-s3-plugin.zip -O ~/geoserver-gwc-s3-plugin.zip &&\
    unzip -o ~/geoserver-gwc-s3-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ &&\
    rm ~/geoserver-gwc-s3-plugin.zip

#Custom Libraries for Molaa
COPY ./libs/gs-sldservice-$GEOSERVER_VERSION.zip /tmp/
RUN unzip -o /tmp/gs-sldservice-$GEOSERVER_VERSION.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/  &&\
    rm /tmp/gs-sldservice-$GEOSERVER_VERSION.zip

#End Cgastrel requested plugins

# Expose GeoServer's default port
EXPOSE 8080
CMD ["/opt/geoserver/bin/startup.sh"]
