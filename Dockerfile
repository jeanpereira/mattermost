FROM --platform=arm64 rockylinux:8

# Some ENV variables
ENV PATH="/opt/mattermost/bin:${PATH}"
ARG PUID=2000
ARG PGID=2000
ARG MM_VERSION
ARG MM_PACKAGE_NAME="mattermost-${MM_VERSION}-linux-arm64.tar.gz"
ARG MM_PACKAGE="https://github.com/SmartHoneybee/ubiquitous-memory/releases/download/${MM_VERSION}/mattermost-${MM_VERSION}-linux-arm64.tar.gz"

# Install some needed packages
RUN sed -i 's|enabled=0|enabled=1|g' /etc/yum.repos.d/{Rocky-Extras.repo,Rocky-Plus.repo,Rocky-PowerTools.repo} \
    && dnf install -y epel-release \
    && dnf update -y \
    && dnf install -y ca-certificates \
        curl \
        libffi-devel \
        kernel-headers \
        mailcap \
        netcat \
        xmlsec1-devel \
        tzdata \
        poppler-utils \
        tidy \
        wget \
    && dnf clean all

# Get Mattermost
RUN cd /opt \
    && mkdir -p /opt/mattermost/data /opt/mattermost/plugins /opt/mattermost/client/plugins \
    && wget $MM_PACKAGE \
    && tar -xvf $MM_PACKAGE_NAME \
    && rm -rf $MM_PACKAGE_NAME

RUN groupadd -g ${PGID} mattermost \
    && adduser -r -u ${PUID} -g mattermost -d /opt/mattermost mattermost \
    && chown -R mattermost:mattermost /opt/mattermost /opt/mattermost/plugins /opt/mattermost/client/plugins \
    && chmod -R g+w /opt/mattermost

COPY entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

USER mattermost

#Healthcheck to make sure container is ready
HEALTHCHECK --interval=30s --timeout=10s \
    CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1

# Configure entrypoint and command
WORKDIR /opt/mattermost
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/opt/mattermost/bin/mattermost"]

EXPOSE 8065 8067 8074 8075

# Declare volumes for mount point directories
VOLUME ["/opt/mattermost/data", "/opt/mattermost/logs", "/opt/mattermost/config", "/opt/mattermost/plugins", "/opt/mattermost/client/plugins"]
