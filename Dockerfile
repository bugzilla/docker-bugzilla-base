# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

FROM centos:7
MAINTAINER David Lawrence <dkl@mozilla.com>

# Environment configuration
ENV BUGZILLA_LIB /opt/bugzilla
ENV BUGZILLA_WWW /var/www/html/bugzilla
ENV GITHUB_BASE_GIT https://github.com/bugzilla/bugzilla
ENV GITHUB_BASE_BRANCH master

ADD https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm /usr/local/bin/cpanm
RUN chmod 755 /usr/local/bin/cpanm

COPY rpm_list /rpm_list
RUN rpm -qa --queryformat '/^%{NAME}$/ d\n' > rpm_fix.sed && \
    sed -f rpm_fix.sed /rpm_list > /rpm_list.clean

RUN yum -y install https://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm && \
	yum -y install epel-release  && \
	yum -y install `cat /rpm_list.clean` && \
    yum clean all

# Clone the code repo initially
RUN git clone $GITHUB_BASE_GIT -b $GITHUB_BASE_BRANCH $BUGZILLA_WWW

# Install dependencies
RUN cd $BUGZILLA_WWW && \
	cpanm -l $BUGZILLA_LIB --quiet --skip-satisfied --notest --installdeps \
          --with-all-features --without-feature oracle \
          --without-feature sqlite --without-feature pg . && \
	rm -rf ~/.cpanm
