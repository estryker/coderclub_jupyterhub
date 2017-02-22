# Build as jupyterhub/singleuser_ruby
# Run with the DockerSpawnerRuby in JupyterHub
FROM jupyter/scipy-notebook

MAINTAINER Ethan Stryker

EXPOSE 8888
# For Sinatra
EXPOSE 4567

USER root
# fetch juptyerhub-singleuser entrypoint
# renaming it to jupyterhub-singleuser-ruby
RUN wget -q https://raw.githubusercontent.com/jupyterhub/jupyterhub/0.6.1/scripts/jupyterhub-singleuser -O /usr/local/bin/jupyterhub-singleuser-ruby && \
    chmod 755 /usr/local/bin/jupyterhub-singleuser-ruby

ADD singleuser_ruby.sh /srv/singleuser/singleuser_ruby.sh

RUN apt-get update
RUN apt-get install curl libcurl3
# RUN apt-get install curl libcurl3 libgcrypt11 libgnutls26 librtmp0 rng-tools gnutls-bin 
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 
RUN which curl

RUN apt-get -y install pkg-config libunwind-dev libruby2.1 ruby ruby2.1 ruby-dev ruby2.1-dev rubygems-integration libtool-bin autoconf automake
RUN cd /tmp; git clone https://github.com/zeromq/libzmq
RUN cd /tmp/libzmq; ./autogen.sh && ./configure && make && make check && make install

RUN which ruby
RUN gem install iruby nyaplot ffi-rzmq seconds sinatra iruby_helpers erector mimemagic opt-simple bundler github_api --no-rdoc --no-ri
RUN gem uninstall rbczmq
RUN iruby register --force 
RUN chown -R jovyan:users  /home/jovyan/.ipython/ #  kernels/ruby

USER jovyan
ADD Gemfile /home/jovyan/ 
RUN bundle install
# smoke test that it's importable at least
RUN sh /srv/singleuser/singleuser_ruby.sh -h
CMD ["sh", "/srv/singleuser/singleuser_ruby.sh"]

