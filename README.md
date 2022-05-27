[![Actions Status](https://github.com/raku-community-modules/CoreHackers-Sourcery/actions/workflows/test.yml/badge.svg)](https://github.com/raku-community-modules/CoreHackers-Sourcery/actions)

NAME
====

CoreHackers::Sourcery - Show source locations of core methods and subs

SYNOPSIS
========

```raku
use CoreHackers::Sourcery;
&say.sourcery("foo").put;

# OUTPUT:
# src/core/io_operators.pm:22 https://github.com/rakudo/rakudo/blob/c843682/src/core/io_operators.pm#L22

put sourcery Int, 'abs';         # method called on a type object
put sourcery 42,  'split';       # method called on an Int object
put sourcery 42,  'base', \(16); # method call with args
```

DESCRIPTION
===========

This module provides the *actual* location of the sub or method definition in Rakudo's source code.

BLOG POST
=========

Related [blog post](https://github.com/Raku/CCR/blob/main/Remaster/Zoffix%20Znet/Raku-Core-Hacking-Wheres-Da-Sauce-Boss.md#raku-core-hacking-wheres-da-sauce-boss).

METHODS
=======

```raku
&say.sourcery.put;        # location of the `proto`
&say.sourcery('foo').put; # location of the candidate that can do 'foo'
```

The core `Code` class and its core subclasses get augmented with a `.sourcery` method. Calling this method without arguments provides the location of the method or sub, or the `proto` of the multi.

When called with arguments, returns the location of the narrowest candidate, possibly `die`ing if no candidate can be found.

Returns a list of two strings: the `file:line-number` referring to the core file and the GitHub URL.

EXPORTED SUBROUTINES
====================

sourcery
--------

```raku
put sourcery &say;              # just Code object
put sourcery &say, \('foo');    # find best candidate for a Code object
put sourcery Int, 'abs';        # method `abs` on a type object

# find best candidate for method `base` on object 42, with argument `16`
put sourcery 42, 'base', \(16);
```

Operates similar to the method form, except allows more flexibility, such as passing object/method names. Returns a list of two strings: the `file:line-number` referring to the core file and the GitHub URL.

ENVIRONMENT VARIABLES
=====================

SOURCERY_SETTING
----------------

The location of the setting file. Defaults to:

```raku
$*EXECUTABLE.parent.parent.parent.child(&say.file)
```

This will generally work for most installs.

AUTHOR
======

Zoffix Znet

COPYRIGHT AND LICENSE
=====================

Copyright 2016 - 2018 Zoffix Znet

Copyright 2019 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

