#!perl6

use lib 'lib';
use Test;
use Test::When <author>;
use CoreHackers::Sourcery;

is &say.sourcery.elems, 2, 'sourcery returns a list of two items';

like &say.sourcery.join, rx{
    'src/core/io_operators.pm:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/io_operators.pm#L' $<line>
}, '&say.sourcery';

like &say.sourcery('foo').join, rx{
    'src/core/io_operators.pm:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/io_operators.pm#L' $<line>
}, '&say.sourcery("foo")';

like Str.^can('say')[0].sourcery.join, rx{
    'src/core/Mu.pm:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Mu.pm#L' $<line>
}, 'Str.say.sourcery';

like sourcery(&say).join, rx{
    'src/core/io_operators.pm:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/io_operators.pm#L' $<line>
}, 'sourcery(&say)';

like sourcery(Str, 'say').join, rx{
    'src/core/Mu.pm:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Mu.pm#L' $<line>
}, 'sourcery Str, "say"';

like sourcery('foo', 'say').join, rx{
    'src/core/Mu.pm:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Mu.pm#L' $<line>
}, 'sourcery "foo", "say"';

like sourcery('foo', 'say', \()).join, rx{
    'src/core/Mu.pm:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Mu.pm#L' $<line>
}, 'sourcery "foo", "say", \()';

like sourcery(42, 'base', \(16)).join, rx{
    'src/core/Int.pm:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Int.pm#L' $<line>
}, 'sourcery 42, "base", \(16)';

dies-ok { sourcery 'foo', 'say', \(42) }, 'sourcery "foo", "say", \(42) dies';

done-testing;
