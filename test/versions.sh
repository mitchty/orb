#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

jruby_version=$(grep "^jruby:" ${dir}/versions | awk -F: '{print $2}')
ruby_version=$(grep "^ruby:" ${dir}/versions | awk -F: '{print $2}')
perl_version=$(grep "^perl:" ${dir}/versions | awk -F: '{print $2}')

jruby_verbose="(1.9.3p392) 2013-05-16 2390d3b"
ruby_verbose="(2013-06-27 revision 41674)"
perl_verbose="This is perl 5, version 18, subversion 0 (v5.18.0)"

# so we can eval output in helper.sh
cat <<EOF
jruby_version="${jruby_version}"
ruby_version="${ruby_version}"
perl_version="${perl_version}"

jruby_verbose="${jruby_verbose}"
ruby_verbose="${ruby_verbose}"
perl_verbose="${perl_verbose}"
EOF
