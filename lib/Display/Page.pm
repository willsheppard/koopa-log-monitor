package Display::Page;

use strict;
use warnings;

use Data::Printer;

use Log::Log4perl;
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub transform {
    my ($args) = @_;
    my $data = $args->{data} or die "expected 'data'";

    # Transform the pattern count data so it's indexed by file, not pattern.
    # The reason for this is: Being indexed by pattern works well for the config,
    # and being indexed by file works well for display.

    my $tempfiles = {};
    foreach my $pf (@{ $data->{pattern_files} }) {

        foreach my $file (@{ $pf->{files} }) {

            if (exists $tempfiles->{$file}->{patterns}) {
                push @{$tempfiles->{$file}->{patterns}}, $pf->{pattern};
            } else {
                $tempfiles->{$file}->{patterns} = [ $pf->{pattern} ];
            }

            foreach my $c (@{ $pf->{pattern_counts} }) {
                if ($c->{file} eq $file) {
                    if (exists $tempfiles->{$file}->{pattern_counts}) {
                        push @{$tempfiles->{$file}->{pattern_counts}}, $c;
                    } else {
                        $tempfiles->{$file}->{pattern_counts} = [ $c ];
                    }
                } # if file
            } # foreach pattern count

        } # foreach file

    } # foreach pattern file

    # All file data collected, now write it back out to the main hash
    # Sort for display
    $data->{file_patterns} = [];
    foreach my $file (sort keys %$tempfiles) {
        push @{$data->{file_patterns}}, {
            file            => $file,
            patterns        => $tempfiles->{$file}->{patterns},
            pattern_counts  => $tempfiles->{$file}->{pattern_counts},
        };
    } # foreach file

    return $data;

} # sub transform

1;
