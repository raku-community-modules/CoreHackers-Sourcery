#!perl6

use lib 'lib';
use Test;
use Test::When <author>;
use CoreHackers::Sourcery;

is &say.sourcery.elems, 2, 'sourcery returns a list of two items';

like &say.sourcery.join, rx{
    'src/core/io_operators.pm6:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/io_operators.pm6#L' $<line>
}, '&say.sourcery';

like &say.sourcery('foo').join, rx{
    'src/core/io_operators.pm6:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/io_operators.pm6#L' $<line>
}, '&say.sourcery("foo")';

like Str.^can('say')[0].sourcery.join, rx{
    'src/core/Mu.pm6:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Mu.pm6#L' $<line>
}, 'Str.say.sourcery';

like sourcery(&say).join, rx{
    'src/core/io_operators.pm6:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/io_operators.pm6#L' $<line>
}, 'sourcery(&say)';

like sourcery(Str, 'say').join, rx{
    'src/core/Mu.pm6:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Mu.pm6#L' $<line>
}, 'sourcery Str, "say"';

like sourcery('foo', 'say').join, rx{
    'src/core/Mu.pm6:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Mu.pm6#L' $<line>
}, 'sourcery "foo", "say"';

like sourcery('foo', 'say', \()).join, rx{
    'src/core/Mu.pm6:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Mu.pm6#L' $<line>
}, 'sourcery "foo", "say", \()';

like sourcery(42, 'base', \(16)).join, rx{
    'src/core/Int.pm6:' $<line>=\d+
    'https://github.com/rakudo/rakudo/blob/'
    <-[/]>+
    '/src/core/Int.pm6#L' $<line>
}, 'sourcery 42, "base", \(16)';

dies-ok { sourcery 'foo', 'say', \(42) }, 'sourcery "foo", "say", \(42) dies';

done-testing;
