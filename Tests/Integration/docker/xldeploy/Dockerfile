FROM java:8u111-jre

MAINTAINER Marcel Bezemer

ENV version 6.1.0
ENV root /lib
ENV home ${root}/xl-deploy-${version}-server

RUN wget \
      https://dist.xebialabs.com/public/trial/xl-deploy/${version}/xl-deploy-${version}-server-trial-edition.zip \
      -O /tmp/xld.zip \
  && unzip \
      /tmp/xld.zip \
      -d ${root} \
  && rm -R \
      /tmp/xld.zip

COPY xldeploy.answers ${home}/bin/xldeploy.answers
# COPY deployit-license.lic ${home}/conf/deployit-license.lic

WORKDIR ${home}/bin
RUN ["./run.sh", "-setup", "-reinitialize", "-force", "-setup-defaults", "./bin/xldeploy.answers"]

VOLUME ["${home}/conf", \
	"${home}/ext", \
	"${home}/hotfix", \
	"${home}/importablePackages", \
	"${home}/log", \
	"${home}/plugins", \
	"${home}/repository"]

EXPOSE 4516

CMD ["./run.sh"]
