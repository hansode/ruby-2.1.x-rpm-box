#!/bin/bash
#
# requires:
#  bash
#  chroot
#
set -x
set -e

echo "doing execscript.sh: $1"

## root

chroot $1 $SHELL -ex <<'EOS'
  rpm -Uvh http://dlc.wakame.axsh.jp.s3-website-us-east-1.amazonaws.com/epel-release
  yum install -y libyaml-devel
EOS

## normal user

chroot $1 su - ${devel_user} <<'EOS'
  whoami

  git clone https://github.com/hansode/ruby-2.1.x-rpm.git /tmp/ruby-2.1.x-rpm
  rubyver=$(egrep "^%define rubyver" /tmp/ruby-2.1.x-rpm/ruby21x.spec | awk '{print $3}')

  cd
  rpmdev-setuptree

  cp -f /tmp/ruby-2.1.x-rpm/ruby21x.spec ~/rpmbuild/SPECS/ruby21x.spec

  cd ~/rpmbuild/SOURCES; pwd
  wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-${rubyver}.tar.gz

  rpmbuild -bb ~/rpmbuild/SPECS/ruby21x.spec
EOS

## root

chroot $1 $SHELL -ex <<EOS
  rpm -ivh /home/${devel_user}/rpmbuild/RPMS/*/ruby-2.1.*.rpm
  gem install bundler --no-rdoc --no-ri
EOS
