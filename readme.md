# orb.sh, about the easiest way to pick a ruby interpreter

Why not rbenv?

I don't like shims that are shell wrappers, and no need to exec a shell just to exec ruby.

Why not rvm?

More complicated that it needs to be. I like simple.

Why use this?

Its 60 lines of simple shell that uses select to adjust $PATH. Outside of typing export PATH=/foo/bar/baz/bin, this is about the most basic you can make it.

# How do I use it?

Don't like the default location of $HOME/.rubies as being the place for your rubies?

export $orb_ruby_base=/some/dir/with/all/your/ruby/interpreters

Source it!

. /path/to/orb.sh

Install some form of ruby/jruby/rbx/python/perl as long as it has a /bin dir its all good.

./configure --prefix=$orb_ruby_base/some_new_ruby

## interactively

Type orb and then pick the directory you want.

Example:
$ orb
1) system   3) rbx-head               5) ruby-1.9.3-p125
2) jruby-1.6.7            4) ruby-1.9.3-p0          6) ruby-1.9.3-p194
ruby?: 2
Adding jruby-1.6.7 to $PATH
$ ruby -v
jruby 1.6.7 (ruby-1.8.7-p357) (2012-02-22 3e82bc8) (OpenJDK 64-Bit Server VM 1.7.0-jdk7u6-b07) [darwin-universal-java]

note, picking system just removes any changes from $PATH.

## non-interactively muck with $PATH

Assuming $orb_ruby_base has a directory named ruby-1.9.3-p194 within:

setupruby ruby-1.9.3-p194

## But I don't want that dir in $PATH anymore!

No worries, typing orbimplode removes anything from $orb_ruby_base in $PATH.

Thats it!

Known to work on zsh on OSX/Leopardish+ and Linux. Should work with ksh and bash as well, probably old school bourne too. Might work on Solaris/AiX/HPUX.
