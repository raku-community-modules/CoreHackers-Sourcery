[![Build Status](https://travis-ci.org/zoffixznet/perl6-CoreHackers-Sourcery.svg)](https://travis-ci.org/zoffixznet/perl6-CoreHackers-Sourcery)

# NAME

CoreHackers::Sourcery - Show source locations of core methods and subs

# SYNOPSIS

```perl6
    use CoreHackers::Sourcery;
    &say.sourcery("foo").put;

    # OUTPUT:
    # src/core/io_operators.pm:22 https://github.com/rakudo/rakudo/blob/c843682/src/core/io_operators.pm#L22

    put sourcery Int, 'abs';         # method called on a type object
    put sourcery 42,  'split';       # method called on an Int object
    put sourcery 42,  'base', \(16); # method call with args
```

# DESCRIPTION

When calling `.line` or `.file` on core `Code` objects, you get a line
in the setting. The setting is a giant file, so such information is not
ideal when trying to locate the place to edit the code.

This module provides the *actual* location of the sub or method definition
in Rakudo's source code.

# BLOG POST

Related blog post:
[http://perl6.party/post/Perl-6-Core-Hacking-Wheres-Da-Sauce-Boss](http://perl6.party/post/Perl-6-Core-Hacking-Wheres-Da-Sauce-Boss)

# ONLINE ACCESS

If you use Rakudo earlier than [v2016.07.1.128.g.715.b.822](https://github.com/rakudo/rakudo/commit/715b822bfd7dc66efbf041e19d11cf4841fbf12f),
this module requires access to GitHub. Read the above blogpost to learn why.

# METHODS

## `.sourcery`

```perl6
    &say.sourcery.put;        # location of the `proto`
    &say.sourcery('foo').put; # location of the candidate that can do 'foo'
```

The core `Code` class and its core subclasses get augmented with `.sourcery`
method. Calling this method with no arguments provides the location
of the method or sub, or the `proto` of the multi.

When called with arguments, returns the location of the narrowest candidate,
possibly `die`ing if no candidate can be found.

Returns a list of two strings: the `file:line-number` referring to the
core file and the GitHub URL.

# SUBROUTINES

## `sourcery`

```perl6
    put sourcery &say;              # just Code object
    put sourcery &say, \('foo');    # find best candidate for a Code object
    put sourcery Int, 'abs';        # method `abs` on a type object

    # find best candidate for method `base` on object 42, with argument `16`
    put sourcery 42, 'base', \(16);
```
Operates similar to the method form, except allows more flexibility, such
as passing object/method names.
Returns a list of two strings: the `file:line-number` referring to the
core file and the GitHub URL.

# ENVIRONMENTAL VARIABLES

## `SOURCERY_SETTING`

The location of the setting file. Defaults to:

```perl6
    $*EXECUTABLE.parent.parent.parent.child(&say.file)
```

This will generally work for most installs.

---

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-CoreHackers-Sourcery

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-CoreHackers-Sourcery/issues

#### AUTHOR

Zoffix Znet (http://zoffix.com/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
