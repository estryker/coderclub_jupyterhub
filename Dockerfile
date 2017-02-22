# Build as jupyterhub/singleuser_ruby
# Run with the DockerSpawnerRuby in JupyterHub
FROM jupyter/scipy-notebook

MAINTAINER Ethan Stryker

EXPOSE 8888

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
RUN cd /tmp; git clone https://github.com/zeromq/libzmq
RUN cd /tmp/libzmq; ./autogen.sh && ./configure && make && make check && make install

# RUN apt-get install autoconf automake autotools-dev bison libbison-dev libffi-dev libgdbm-dev libncurses5-dev libreadline6-dev libsigsegv2 libssl-dev libssl-doc libtinfo-dev libyaml-dev m4 zlib1g-dev autoconf automake autotools-dev bison file libbison-dev libffi-dev libgdbm-dev libltdl-dev libmagic1 libncurses5-dev libreadline6-dev libsigsegv2 libssl-dev libssl-doc libtinfo-dev  libyaml-dev m4 zlib1g-dev file libltdl-dev libmagic1 libtool-bin javascript-common libgmp-dev libgmpxx4ldbl libjs-jquery libruby2.1 ruby ruby2.1 ruby-dev ruby2.1-dev rubygems-integration
RUN apt-get -y install pkg-config libunwind-dev libruby2.1 ruby ruby2.1 ruby-dev ruby2.1-dev rubygems-integration libtool-bin autoconf automake
RUN which ruby
RUN gem install iruby nyaplot ffi-rzmq seconds sinatra iruby_helpers erector mimemagic opt-simple bundler github_api --no-rdoc --no-ri
RUN gem uninstall rbczmq
RUN iruby register --force 
RUN chown -R jovyan:users  /home/jovyan/.ipython/ #  kernels/ruby
# RUN jupyter kernelspec install --user /home/jovyan/.ipython/kernels/ruby
# RUN ipython kernelspec install  /home/jovyan/.ipython/kernels/ruby

# RUN curl -sSL https://get.rvm.io  | bash -s stable --ruby 
#RUN apt-get install libjs-jquery libruby1.9.1 libruby2.0 ruby ruby1.9.1 ruby2.0 rubygems-integration 
# RUN gem2.0 install iruby 
# RUN . /usr/local/rvm/scripts/rvm && gem install cztop && gem install iruby
# TODO: ADD Gemfile /
# RUN ls -l /usr/local/rvm/scripts/rvm 
#RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm \
#    && gem install --no-rdoc --no-ri cztop \
#    && gem install --no-rdoc --no-ri iruby \
#    && gem install --no-doc --no-ri seconds sinatra  \
#    && iruby register"

# ENV PATH $PATH:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# RUN which rvm 
# RUN echo "source /usr/local/rvm/scripts/rvm" >> /etc/profile


# RUN rm /bin/sh && ln -s /bin/bash /bin/sh
USER jovyan
ADD Gemfile /home/jovyan/ 
RUN bundle install
# smoke test that it's importable at least
RUN sh /srv/singleuser/singleuser_ruby.sh -h
CMD ["sh", "/srv/singleuser/singleuser_ruby.sh"]

