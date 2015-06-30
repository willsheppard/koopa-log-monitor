package Display::Graph;

use strict;
use warnings;

use Data::Printer;
use GD::Graph::linespoints;
use boolean; # true/false

use Log::Log4perl;
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub build {
    my ($args) = @_;
    my $data = $args->{data} or die "expected 'data'";

    foreach my $pf (@{ $data->{pattern_files} }) {

        foreach my $c (@{ $pf->{pattern_counts} }) {
            my @x_axis;
            my @y_axis;
            my $pattern = $pf->{pattern};
            foreach my $hist (@{ $c->{historic_data} }) {
                # Skip zero values as that probably just means the data is missing for that day
                next if not defined $hist->[1];

                push @x_axis, $hist->[0]; # date
                push @y_axis, $hist->[1]; # count
            } # foreach historic data point

            my @points = ( \@x_axis, \@y_axis );

            # build filename
            my $graph_filename = build_filename({
                pattern_file    => $pf,
                count_rec       => $c,
                data            => $data,
            });
            $c->{graph_filename} = $graph_filename;

            write_graph({
                points      => \@points,
                name        => $pattern,
                filename    => $graph_filename,
            });
        } # foreach pattern count

    } # foreach file pattern

    foreach my $legend_data (
        {
            colour       => 'lred',
            filename    => 'legend_1.gif',
        },
        {
            colour => 'gray',
            filename => 'legend_2.gif',
        },
    ) {
        write_legend($legend_data);
    }

} # sub build

sub build_filename {
    my ($args) = @_;
    my $pattern_file = $args->{pattern_file} or die "expected 'pattern_file'";
    my $count_rec = $args->{count_rec} or die "expected 'count_rec'";
    my $data = $args->{data} or die "expected 'data'";

    $logger->trace("called build_filename({ pattern_file->{pattern} => ".p($pattern_file->{pattern}).", count_rec => ".p($count_rec).", ... })");

    my $file_rec = $data->{files}->{ $count_rec->{file} }; # file record

    # TODO: sanitize data for filename
    my $graph_filename = join('.', $file_rec->{environment}, $count_rec->{file}, $pattern_file->{pattern}, 'gif');
    return $graph_filename;
}

sub write_graph {
    my ($args) = @_;
    my $points = $args->{points} or die "expected 'points'";
    my $name = $args->{name} or die "expected 'name'";
    my $filename = $args->{filename} or die "expected 'filename'";

    $logger->trace("plotting points: ".p($points));

    unless (scalar(@{$points->[0]}) and scalar(@{$points->[0]})) {
        $logger->warn("no points found");
        return;
    }

    my $graph = GD::Graph::linespoints->new(400, 300);

    # All possible colours:
    #   pink, lbrown, lred, purple, dblue, lpurple,
    #   green, white, gold, blue, dyellow, red, lgreen, marine, dred,
    #   cyan, yellow, lblue, orange, lgray, dgreen, dbrown, lyellow,
    #   black, gray, dpink, dgray, lorange, dpurple
    # Generated with:
    #   use GD::Graph::colour qw(:lists);
    #   print join(", ", colour_list)'
    my $line_colour;
    if ($points->[1][-1] == 0) {
        # Count is now zero, graph is less important
        $line_colour = 'gray';
    } else {
        # Count is not zero (i.e. higher), pay more attention
        $line_colour = 'lred'; # Bright red
    }

    $graph->set(
        title               => $name,
        x_label             => 'Date',
        y_label             => 'Matches',
        x_labels_vertical   => true,
        y_min_value         => 0,
        dclrs               => [ $line_colour ],
    ) or die $graph->error;

    my $plotted_graph = $graph->plot($points) or die $graph->error;
    write_file({
        graph       => $plotted_graph,
        filename    => $filename,
    });
}

sub write_file {
    my ($args) = @_;
    my $graph = $args->{graph} or die "expected 'graph'";
    my $filename = $args->{filename} or die "expected 'filename'";

    # TODO: Put image dir in config
    $logger->trace("writing file: images/$filename");
    open(IMG, '>', "images/$filename") or die "Failed to open images/$filename: $!";
    binmode IMG;
    print IMG $graph->gif;
    close(IMG) or die "Failed to close images/$filename: $!";
    $logger->trace("written file: images/$filename");
}

sub write_legend {
    my ($args) = @_;
    my $graph = GD::Graph::linespoints->new(100, 20);
    my $colour = $args->{colour} or die "expected 'colour'";
    my $filename = $args->{filename} or die "expected 'filename'";
    $graph->set(
        no_axes             => true,
        dclrs               => [ $colour ],
    ) or die $graph->error;
    my $points = [ [0, 0, 0], [0, 0, 0] ]; # A straight line
    my $plotted_graph = $graph->plot($points) or die $graph->error;
    write_file({
        graph       => $plotted_graph,
        filename    => $filename,
    });
}

1;
