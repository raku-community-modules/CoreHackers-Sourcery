unit module CoreHackers::Sourcery;
use MONKEY-TYPING;
use HTTP::UserAgent;

constant $Raw-URL    = 'https://raw.githubusercontent.com/rakudo/rakudo/';
constant $GitHub-URL = 'https://github.com/rakudo/rakudo/blob/';
constant $Setting-Prefix
    = (%*ENV<SOURCERY_SETTING_PREFIX> // $*EXECUTABLE.parent.parent.parent).IO;
constant $Commit
    = $*PERL.compiler.version.Str.subst('.', '', :g).split('g')[*-1];

my %Cache;

#### Main method/sub

augment class Code {
    multi method sourcery      { sourcery self;     }
    multi method sourcery (|c) { sourcery self, c; }
}

.^compose
    for Block, WhateverCode, Routine, Macro, Method, Sub, Submethod, Regex;

multi sourcery ($thing, Str:D $method, Capture $c) is export {
    my $code = gather {
        for $thing.^can($method) -> $meth {
            .take for grep *.defined, $meth.cando: \($thing, |$c);
        }
    }
    do-sourcery $code[0]
        // die "Could not find candidate that can do {$c.gist}";
}

multi sourcery ($thing, Str:D $method) is export {
    do-sourcery $thing.^can($method)[0];
}

multi sourcery (&code)             is export { do-sourcery &code }
multi sourcery (&code, Capture $c) is export {
    do-sourcery &code.cando($c)[0]
        // die "Could not find candidate that can do {$c.gist}";
}

#### Auxiliary subs

sub do-sourcery (&code) {
    my $location = real-location-for &code;
    my ($line, $url) = github-url-for |$location<file line>;
    ([~] $location<file>, ':', $line), $url;
}

sub github-url-for ($file, $line is copy) {
    my $url = [~] $Raw-URL, $Commit, '/', $file;

    my $content = %Cache{$url} // do {
        my $res = HTTP::UserAgent.new.get: $url;
        fail "Failed to fetch GitHub content: $res.status-line()"
            unless $res.is-success;
        %Cache{$url} = $res.content;
    }

    # The v2016.07.1.128.g.715.b.822 had a fix for setting generator go in
    # so the line numbers will match up and we do not need to adjust anything
    $line = adjusted-line-number $content, $line
        if $*PERL.compiler.version before v2016.07.1.128.g.715.b.822;

    return $line, [~] $GitHub-URL, $Commit, '/', $file, '#L', $line;
}

sub adjusted-line-number ($content, $orig-line is copy) {
    my $in-cond      = 0;
    my $in-omit      = 0;
    my $line         = 1;
    my $setting-line = 0;
    my $backend      = $*VM.name;

    for $content.lines {
        if my $x = $_ ~~ / ^ '#?if' \s+ ('!')? \s* (\w+) \s* $ / {
            fail "Came across nested conditional; can't proceed" if $in-cond;
            $in-cond = 1;
            $in-omit = $x[0] && $x[1] eq $backend
                   || !$x[0] && $x[1] ne $backend;
        } elsif $_ ~~ /^ '#?endif' / {
            warn "#?endif without matching #?if on line $line" unless $in-cond;
            $in-cond = 0;
            $in-omit = 0;
        } elsif !$in-omit {
            $setting-line++ unless $_ ~~ /^ '# ' \w /;
            last if $setting-line == $orig-line;
        }
        $line++;
    }
    return $line;
}

sub real-location-for (&code) {
    my $wanted = &code.line;
    my $line-num = 0;
    my $file;
    my $offset;
    for $Setting-Prefix.child(&code.file).IO.lines -> $line {
        $line-num++;
        return { :$file, :line($line-num - $offset), } if $line-num == $wanted;
        if $line ~~ /^ '#line 1 ' $<file>=\S+/ {
            $file = $<file>;
            $offset = $line-num+1;
        }
    };

    fail 'Were not able to find location in setting. Are you sure this is'
        ~ ' a core Code?';
}
