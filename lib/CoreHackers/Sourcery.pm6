unit module CoreHackers::Sourcery;
use MONKEY-TYPING;
use HTTP::UserAgent;

constant $Raw-URL    = 'https://raw.githubusercontent.com/rakudo/rakudo/';
constant $GitHub-URL = 'https://github.com/rakudo/rakudo/blob/';
constant $Setting-Prefix
    = (%*ENV<SOURCERY_SETTING_PREFIX> // $*EXECUTABLE.parent.parent.parent).IO;
constant $Commit
    = $*PERL.compiler.version.Str.subst('.', '', :g).split('g')[*-1];

#### Main method/sub

augment class Code {
    multi method sourcery      { sourcery self;     }
    multi method sourcery (|c) { sourcery self, |c; }
}

.^compose
    for Block, WhateverCode, Routine, Macro, Method, Sub, Submethod, Regex;

sub sourcery (&code, |c) is export {
    my $candidate = &code.cando: c;
    my $location = real-location-for $candidate[0];
    my ($line, $url) = github-url-for |$location<file line>;
    [~] $location<file>, ':', $line, ' ', $url;
}

#### Auxiliary subs

sub github-url-for ($file, $line is copy) {
    return '' if %*ENV<SOURCERY_NO_GITHUB>;

    my $res = HTTP::UserAgent.new.get: [~] $Raw-URL, $Commit, '/', $file;
    fail "Failed to fetch GitHub content: $res.status-line()"
        unless $res.is-success;

    $line = adjusted-line-number $res.content, $line;
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
