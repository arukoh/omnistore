FROM amazonlinux
RUN yum install -y ruby ruby-devel git make gcc-c++ libxml2 libxslt libxml2-devel libxslt-devel

RUN gem install bundler -N -v 1.16.0
RUN bundle config build.nokogiri --use-system-libraries

WORKDIR /usr/src/omnistore
ADD . .
# RUN bundle i
