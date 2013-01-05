# orb.sh, the opinionated ruby/perl chooser

Consider this a work in progress at best until I finish writing tests for everything. Proof of concept basically. It "works" for varying definitions of work.

Why not rbenv?

I don't like shims that are shell wrappers, and no need to exec a shell just to exec ruby.

Why not rvm?

More complicated that it needs to be. I like simple.

Why not perlbrew?

About the same, plus this is all in one.

Why use this instead?

It's a few lines of semi-simple shell that modifies your running shells $PATH. Outside of typing export PATH=/foo/bar/baz/bin, this is about the most basic you can make it. Its also fast, no fork/execs just to get at your executable.

# How do I use it?

Well assuming you've git cloned it to say $HOME its simple.

> . ${HOME}/orb/orb.sh

Install a ruby using the handy dandy script there as well:

> ${HOME}/orb/ruby-install

## interactively

Type orb and then pick the directory you want.

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

## But I don't want that dir in $PATH anymore!

No worries, typing orb_implode removes everything it sets up.

Thats it!

Known to work on zsh on OSX/Leopardish+ and Linux. Should work with ksh and bash as well, probably old school bourne too. Might work on Solaris/AiX/HPUX.
