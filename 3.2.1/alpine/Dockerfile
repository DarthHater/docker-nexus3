FROM       alpine:3.4

MAINTAINER Jeffry Hesse <jeffryxtron+docker@gmail.com>

ENV JAVA_HOME=/opt/java \
    SONATYPE_DIR=/opt/sonatype \
    NEXUS_DATA=/nexus-data \
    NEXUS_CONTEXT=''

ENV NEXUS_HOME=${SONATYPE_DIR}/nexus \
    SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work

ARG JAVA_VERSION_MAJOR=8
ARG JAVA_VERSION_MINOR=112 
ARG JAVA_VERSION_BUILD=15 
ARG GLIBC_VERSION=2.23-r3
ARG JAVA_URL=http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/server-jre-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz
ARG GLIBC_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}
ARG NEXUS_VERSION=3.2.1-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz
ARG BUILD_DEPENDENCIES="curl tar"

RUN apk upgrade --update && \
 apk add --update ${BUILD_DEPENDENCIES} && \
 for pkg in glibc glibc-bin glibc-i18n; do \
  curl -sSL ${GLIBC_URL}/${pkg}-${GLIBC_VERSION}.apk -o /tmp/${pkg}.apk; \
 done && \
 apk add --allow-untrusted /tmp/*.apk && \
 rm -v /tmp/*.apk && \
 /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 && \
 /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib 


# install Oracle JRE
RUN mkdir -p /opt && \
 curl --fail --silent --location --retry 3 \
         --header "Cookie: oraclelicense=accept-securebackup-cookie; " ${JAVA_URL} \
    | tar -xz -C /opt && \
 ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} ${JAVA_HOME}

# install nexus
RUN mkdir -p ${NEXUS_HOME} && \
  curl --fail --silent --location --retry 3 \
    ${NEXUS_DOWNLOAD_URL} \
  | gunzip \
  | tar x -C ${NEXUS_HOME} --strip-components=1 nexus-${NEXUS_VERSION} && \
  chown -R root:root ${NEXUS_HOME}

# configure nexus
RUN sed \
    -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties

RUN addgroup -S -g 201 nexus && \
  adduser -S -u 200 -G nexus -h ${NEXUS_DATA} -s /bin/false nexus && \
  mkdir -p ${NEXUS_DATA}/etc ${NEXUS_DATA}/log ${NEXUS_DATA}/tmp ${SONATYPE_WORK} && \
  ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3 && \
  chown -R nexus:nexus ${NEXUS_DATA}

VOLUME ${NEXUS_DATA}

EXPOSE 8081
USER nexus
WORKDIR ${NEXUS_HOME}

ENV JAVA_MAX_MEM=1200m \
  JAVA_MIN_MEM=1200m \
  EXTRA_JAVA_OPTS=""

CMD ["bin/nexus", "run"]
