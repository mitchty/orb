# orb.sh, the opinionated ruby/perl chooser

Consider this a work in progress at best until I finish writing tests for everything. Proof of concept basically. It "works" for varying definitions of the word.

Why not rbenv?

I don't like shims that are shell wrappers, and there really is no need to exec a shell just to exec ruby.

Why not rvm?

More complicated that it needs to be.

Why not perlbrew?

About the same, plus this is all in one.

Why not chruby?

Well to be honest I would use that if all I wanted was to deal with just switching rubies. But I have a bug up my ass that I want something that does perl/python(not yet)/ruby all in one. So here we are.

Why use this instead?

It's a few lines of semi-simple(ish) shell that modifies the running shells $PATH. Outside of typing export PATH=/foo/bar/baz/bin, this is about the most basic you can make it. Its also fast, no fork/execs just to get at your executable. Just source orb.sh in and start choosing things.

# How do I use it?

Well assuming you've git cloned it to say $HOME its simple.

> . ${HOME}/orb/orb.sh

Install some version of ruby using the handy dandy script there as well:

> ${HOME}/orb/ruby-install

Or perl:

> ${HOME}/orb/perl-install

(python coming when it bugs me enough :D)

## interactively

Type orb and then pick installed ruby you want. Similarly, typing opl will allow you to choose the perl you use.

Example:
> $ orb
>
> 1) system   3) rbx-head               5) ruby-1.9.3-p125
>
> 2) jruby-1.6.7            4) ruby-1.9.3-p0          6) ruby-1.9.3-p194
>
> ruby?: 2
>
> Adding jruby-1.6.7 to $PATH
>
> $ ruby -v
>
> jruby 1.6.7 (ruby-1.8.7-p357) (2012-02-22 3e82bc8) (OpenJDK 64-Bit Server VM 1.7.0-jdk7u6-b07) [darwin-universal-java]

note, picking system just removes any changes from $PATH.

## non-interactively muck with $PATH

orb use 1.9.3-p327

## I don't like it, how do I remove it?

No worries, typing *orb implode* removes everything it sets up.

Thats it (for now)!

Known/testedish to work on zsh on OSX/Leopardish+ and Linux. Should work with ksh and bash as well, probably old school bourne too. Might work on Solaris/AiX/HPUX but no guarantees.

## TODO

God lots of things left to do.

TDD/BDD this old POS script with Test::More and make it mostly just a perl module. (WIP)
Make it more modular for compiles/etc.. right now its pretty pathetic.
Make it more compatible with the other ruby version managers.
Add in python support, i've been lazy.
Start testing with Vagrant on all the os's I want to care about.

