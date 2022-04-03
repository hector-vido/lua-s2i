ARG ALPINE_VERSION=3.15
# openresty
# Aqui podemos utilizar qualquer imagem base relevante para a aplicação
FROM alpine:${ALPINE_VERSION}

# repete-se o argumento para não perdê-lo pós FROM
ARG ALPINE_VERSION
ARG OPENRESTY_KEY=admin@openresty.com-5ea678a6.rsa.pub

# Aqui especificamos o mantenedor da imagem que estamos construindo
LABEL maintainer="Hector Vido <hvidosil@redhat.com>"

# Exporta uma variável de ambiente que fornece informações sobre a versão dessa aplicação
# Substitua isto pela versão da sua aplicação
ENV OPENRESTY_VERSION=1.19.9

# Configura os "labels" usados pelo OpenShift para descrever a imagem
LABEL io.k8s.description="OpenResty server" \
	io.k8s.display-name="OpenResty 1.19.9" \
	io.openshift.expose-services="8080:http" \
	io.openshift.tags="builder,webserver,html,openresty,appserver" \
	# Este "label" diz ao s2i onde encontrar os script obrigatórios
	# (run, assemble, save-artifacts)
	io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

# Instala os pacotes do servidor openresty e lua sem cache
RUN echo "http://openresty.org/package/alpine/v${ALPINE_VERSION}/main" >> /etc/apk/repositories \
	&& wget "http://openresty.org/package/${OPENRESTY_KEY}" -O "/etc/apk/keys/${OPENRESTY_KEY}" \
	&& apk add --no-cache git luarocks5.1 lua-sec lua5.1-sql-mysql lua5.1-sql-postgres openresty gcc musl-dev openssl-dev lua5.1-dev \
	&& mkdir -p /opt/app \
	&& chmod -R g=u /usr/local/openresty/nginx/ \
	&& chmod g=u /usr/local/lib /usr/local/share /usr/local/bin /opt/app

# Modifica a porta do openresty 
# Obrigatório caso planeje rodar imagens com um usuário diferente de root
RUN sed -i 's/80/8080/' /usr/local/openresty/nginx/conf/nginx.conf

# Copy the S2I scripts to /usr/libexec/s2i since we set the label that way
COPY ./s2i/bin/ /usr/libexec/s2i

USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Modify the usage script in your application dir to inform the user how to run
# this image.
CMD ["/usr/libexec/s2i/usage"]
