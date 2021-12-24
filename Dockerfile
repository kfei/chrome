FROM ubuntu:18.04

LABEL maintainer="Tomohisa Kusano <siomiz@gmail.com>"

ENV VNC_SCREEN_SIZE 1440x900

COPY copyables /

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	gnupg2 \
	fonts-noto-cjk \
	pulseaudio \
	supervisor \
	x11vnc \
	fluxbox \
	eterm \
	firefox \
	vim \
	tint2

ADD https://dl.google.com/linux/linux_signing_key.pub \
	https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
	https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
	/tmp/

RUN apt-key add /tmp/linux_signing_key.pub \
	&& dpkg -i /tmp/google-chrome-stable_current_amd64.deb \
	|| dpkg -i /tmp/chrome-remote-desktop_current_amd64.deb \
	|| apt-get -f --yes install

RUN apt-get clean \
	&& rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/* \
	&& ln -s /crdonly /usr/local/sbin/crdonly \
	&& ln -s /update /usr/local/sbin/update \
	&& unlink /etc/localtime \
	&& ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

VOLUME ["/home/chrome", "/data"]

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
