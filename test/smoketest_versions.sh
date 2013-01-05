#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

it_detects_latest_versions() {
  set +e
  engine=ruby
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  # Meh, use jruby as its faster to install WHY NOT
  ./ruby-install --ruby=jruby --prefix=$orb_ruby_base/default > /dev/null 2>&1
  orb use default
  gem install nokogiri
  set -e
  ruby latest-versions.rb > versions-new
  diff versions-new versions
  assertEquals $? 0
}

. ./helper.sh

orb_implode
