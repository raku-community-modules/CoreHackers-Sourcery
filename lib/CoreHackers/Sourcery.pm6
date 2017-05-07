constant $GitHub-URL = 'https://github.com/rakudo/rakudo/blob/';
my $Setting = (
    %*ENV<SOURCERY_SETTING>
        // $*EXECUTABLE.parent.parent.parent.child(&say.file)
).IO;

constant $Commit = do with $*PERL.compiler.version.Str -> $v is copy {
    # remove dots if we have a non-release version; `.g` seps commit SHA
    $v .= subst: '.', '', :g if $v.contains: '.g';
    $v.split('g')[*-1];
}

sub EXPORT {
    use MONKEY-TYPING;
    augment class Code {
        multi method sourcery      { sourcery self;     }
        multi method sourcery (|c) { sourcery self, c; }
    }

    .^compose
        for Block, WhateverCode, Routine, Macro, Method, Sub, Submethod, Regex;

    return { '&sourcery' => &sourcery };
}

multi sourcery ($thing, Str:D $method, Capture $c) {
    my $code = gather {
        for $thing.^can($method) -> $meth {
            .take for grep *.defined, $meth.cando: \($thing, |$c);
        }
    }
    do-sourcery $code[0]
        // die "Could not find candidate that can do {$c.gist}";
}

multi sourcery ($thing, Str:D $method) { do-sourcery $thing.^can($method)[0]; }
multi sourcery (&code                ) { do-sourcery &code }
multi sourcery (&code, Capture $c    ) {
    do-sourcery &code.cando($c)[0]
        // die "Could not find candidate that can do {$c.gist}";
}

#### Auxiliary subs

sub do-sourcery (&code) {
    my $location = real-location-for &code;

    warn 'Your Perl 6 is too old to give accurate line number.'
            ~ ' Need at least v2016.07.1.128.g.715.b.822'
        if $*PERL.compiler.version before v2016.07.1.128.g.715.b.822;

    (
        ([~] $location<file>, ':', $location<line>),
        ([~] $GitHub-URL, $Commit, '/', $location<file>, '#L', $location<line>),
    );
}

sub real-location-for (&code) {
    my $wanted = &code.line;
    my $line-num = 0;
    my $file;
    my $offset;

    # Newer compilers return proper file/line number
    if $*PERL.compiler.version after v2016.10.286.g.2.e.9.e.89.b {
        $file = &code.file.substr: 9;
        return { :$file, :line($wanted), };
    }

    for $Setting.lines -> $line {
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
