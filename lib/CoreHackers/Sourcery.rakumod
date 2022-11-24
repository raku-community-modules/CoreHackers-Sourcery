my constant $GitHub-URL = 'https://github.com/rakudo/rakudo/blob/';
my $Setting = (
    %*ENV<SOURCERY_SETTING>
      // $*EXECUTABLE.parent.parent.parent.child(&say.file)
).IO;

my constant $Commit = do with $*RAKU.compiler.version.Str -> $v is copy {
    # remove dots if we have a non-release version; `.g` seps commit SHA
    $v .= subst: '.', '', :g if $v.contains: '.g';
    $v.split('g').tail
}

multi sourcery($thing, Str:D $method, Capture:D $c = \()) {
    for $thing.^can($method) -> $meth {
         with $meth.cando(\($thing, |$c)).first(*.defined) {
             return do-sourcery($_);
         }
    }
    die "Could not find candidate that can do $c.gist()";
}

multi sourcery(&code) { do-sourcery &code }
multi sourcery(&code, Capture $c) {
    do-sourcery &code.cando($c).head
      // die "Could not find candidate that can do $c.gist()";
}

my sub do-sourcery(&code) {
    my $file := &code.file;
    $file := $file.substr(9) if $file.starts-with('SETTING::');
    my $line := &code.line;

    "$file:$line", "$GitHub-URL$Commit/$file#L$line"
}

my sub EXPORT {
    use MONKEY-TYPING;
    augment class Code {
        multi method sourcery()   { sourcery self     }
        multi method sourcery(|c) { sourcery self, c; }
    }
    .^compose for
      Block, WhateverCode, Routine, Macro, Method, Sub, Submethod, Regex;

    Map.new: ('&sourcery' => &sourcery)
}

=begin pod

=head1 NAME

CoreHackers::Sourcery - Show source locations of core methods and subs

=head1 SYNOPSIS

=begin code :lang<raku>

use CoreHackers::Sourcery;
&say.sourcery("foo").put;

# OUTPUT:
# src/core/io_operators.pm:22 https://github.com/rakudo/rakudo/blob/c843682/src/core/io_operators.pm#L22

put sourcery Int, 'abs';         # method called on a type object
put sourcery 42,  'split';       # method called on an Int object
put sourcery 42,  'base', \(16); # method call with args

=end code

=head1 DESCRIPTION

This module provides the *actual* location of the sub or method definition
in Rakudo's source code.

=head1 BLOG POST

Related L<blog post|https://github.com/Raku/CCR/blob/main/Remaster/Zoffix%20Znet/Raku-Core-Hacking-Wheres-Da-Sauce-Boss.md#raku-core-hacking-wheres-da-sauce-boss>.

=head1 METHODS

=begin code :lang<raku>

&say.sourcery.put;        # location of the `proto`
&say.sourcery('foo').put; # location of the candidate that can do 'foo'

=end code

The core C<Code> class and its core subclasses get augmented with a
C<.sourcery> method.  Calling this method without arguments provides
the location of the method or sub, or the C<proto> of the multi.

When called with arguments, returns the location of the narrowest
candidate, possibly C<die>ing if no candidate can be found.

Returns a list of two strings: the C<file:line-number> referring to the
core file and the GitHub URL.

=head1 EXPORTED SUBROUTINES

=head2 sourcery

=begin code :lang<raku>

put sourcery &say;              # just Code object
put sourcery &say, \('foo');    # find best candidate for a Code object
put sourcery Int, 'abs';        # method `abs` on a type object

# find best candidate for method `base` on object 42, with argument `16`
put sourcery 42, 'base', \(16);

=end code

Operates similar to the method form, except allows more flexibility, such
as passing object/method names.
Returns a list of two strings: the C<file:line-number> referring to the
core file and the GitHub URL.

=head1 ENVIRONMENT VARIABLES

=head2 SOURCERY_SETTING

The location of the setting file. Defaults to:

=begin code :lang<raku>

$*EXECUTABLE.parent.parent.parent.child(&say.file)

=end code

This will generally work for most installs.

=head1 AUTHOR

Zoffix Znet

=head1 COPYRIGHT AND LICENSE

Copyright 2016 - 2018 Zoffix Znet

Copyright 2019 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
