# Docker file build for hathora server
# Server Docker File
# DOcumentation : https://hathora.dev/docs/guides/create-dockerfile

FROM centos:centos8
    
RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y wget unzip libXcursor openssl openssl-libs libXinerama libXrandr-devel libXi alsa-lib pulseaudio-libs mesa-libGL

# TODO: replace with your Godot version
ENV GODOT_VERSION "3.5.3"

# Install Godot Server
RUN wget -q https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
&& unzip Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
&& mv Godot_v${GODOT_VERSION}-stable_linux_server.64 /usr/local/bin/godot \
&& chmod +x /usr/local/bin/godot

# Add these dependencies if you're enabling TLS
RUN dnf -y update && \
    dnf -y install ca-certificates && \
    update-ca-trust

# Copy All Game files And Libraries

COPY teting_v1.0.pck .

CMD /usr/local/bin/godot --headless --main-pack ./teting_v1.0.pck

