use CoreHackers::Sourcery;

&say.sourcery.put;
put sourcery 42, 'base', \(16);
put sourcery &say, \('foo');

put "Int.{.name} is at {sourcery $_}" for Int.^methods;

# vim: expandtab shiftwidth=4
