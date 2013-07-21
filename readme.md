# orb.sh, my opinionated ruby/perl/python chooser

Consider this a work in progress at best until I finish writing tests for everything. Proof of concept basically. It "works" for varying definitions of the word.

* Why not rbenv?

I don't like shims that are shell wrappers, and there really is no need to exec a shell just to exec ruby.

* Why not rvm?

More complicated that it needs to be.

* Why not perlbrew?

About the same, plus this is all in one.

* Why not chruby?

Well to be honest I would use that if all I wanted was to deal with just switching ruby interpreters. But I have a bug up my ass that I want something that does perl/python/ruby all in one. So here we are.

* So what is this good for in general?

It's a few lines of semi-simple(ish) shell that modifies the running shells $PATH. Outside of typing export PATH=/foo/bar/baz/bin, this is about the most basic you can make it. Its also fast, no fork/execs just to get at your executable. Just source orb.sh in and start choosing things.

I personally use it to make testing against rbx/ruby/jruby/perl head simple. Always nice to know in advance what will be coming down the pike.

# How do I use it?

> cd $HOME && git clone https://github.com/mitchty/orb .orb

> . ${HOME}/.orb/orb.sh

If you don't like the default of ${HOME}/.orb, you can clone it anywhere and then set orb_base to that directory instead.

Then install some version of perl/ruby/jruby/rbx:

> orb install

Or perl:

> opl install

Or python:

> opy install

For help just run orb install --help.

## Interactively choose intepreter

Type orb and then pick installed ruby you want. Similarly, typing opl will allow you to choose the perl you use. And the same applies for opy and choosing python.

Example:
> $ orb
> 1) system   3) rbx-head               5) ruby-1.9.3-p125
> 2) jruby-1.6.7            4) ruby-1.9.3-p0          6) ruby-1.9.3-p194
> ruby?: 2
> Adding jruby-1.6.7 to $PATH
> $ ruby -v
> jruby 1.6.7 (ruby-1.8.7-p357) (2012-02-22 3e82bc8) (OpenJDK 64-Bit Server VM 1.7.0-jdk7u6-b07) [darwin-universal-java]

note, picking system just removes any changes from $PATH.

## Non-interactively muck with $PATH

> orb use ruby-1.9.3-p327
> opl use perl-5.18.0
> opy use python-3.3.2

## I don't like it, how do I remove it?

No worries, typing *orb implode* removes everything it sets up in the current shell. Then simply remove the directory.

Thats it (for now)!

Known/testedish to work on zsh on OSX/Leopardish+ and Linux. Should work with ksh and bash as well, probably old school bourne too. Might work on Solaris/AiX/HPUX but no guarantees.

## TODO

God lots of things left to do.

TDD/BDD this old POS script with Test::More and make it mostly just a perl module. (WIP) This is an ancient script thats just been hacked until it worked. TDD could do it good.

Make it more modular for compiles/etc.. right now its pretty pathetic.

Make it more compatible with the other ruby version managers.

Add in python/pypy support, I've been lazy.

Start testing with Vagrant on all the os's automatically.

Make the installer more intelligent so it doesn't always install ffi/yaml for ruby.

I'm thinking of just making each engine a directory instead of concatenating things together.

Shell completion support for zsh, bash eventually.
