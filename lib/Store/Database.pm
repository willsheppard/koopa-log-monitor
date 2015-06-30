package Store::Database;

use strict;
use warnings;

use DBI;
use DateTime;
use DateTime::Format::Pg;
use Data::Printer;

use Log::Log4perl;
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub store {
    my ($args) = @_;
    my $data = $args->{data} or die "expected 'data'";
    my $year = $args->{year}; # optional
    my $month = $args->{month}; # optional
    my $day = $args->{day}; # optional

    my $dbh = get_dbh({ data => $data });
    my $table = $data->{system}->{database}->{table};
    my $insert_query = "INSERT INTO $table (date, environment, file, pattern, count) VALUES (?, ?, ?, ?, ?)";
    my $sth = $dbh->prepare($insert_query);

    my $now_pg;
    if ($year and $month and $day) {
        # Override for re-parsing old data
        $now_pg = DateTime::Format::Pg->format_datetime( DateTime->new( year => $year, month => $month, day => $day ) );
    }
    else {
        # Assume we're parsing today's data
        $now_pg = DateTime::Format::Pg->format_datetime( DateTime->now );
    }

    foreach my $pf (@{ $data->{pattern_files} }) {

        foreach my $c (@{ $pf->{pattern_counts} }) {
            my $file = $data->{files}->{ $c->{file} }; # file record
            my $r = $sth->execute(
                $now_pg,
                $file->{environment},   # env shortname
                $c->{file},             # file shortname
                $pf->{pattern},         # pattern shortname
                $c->{count},
            );
        } # each pattern count

    } # each file pattern

} # sub store

sub fetch {
    my ($args) = @_;
    my $data = $args->{data} or die "expected 'data'";

    my $dbh = get_dbh({ data => $data });
    my $table = $data->{system}->{database}->{table};
    my $select_query = "SELECT date, count FROM $table
    WHERE environment = ? AND file = ? AND pattern = ?
    GROUP BY date, count ORDER BY date";
    my $sth = $dbh->prepare($select_query);

    foreach my $pf (@{ $data->{pattern_files} }) {

        foreach my $file (@{ $pf->{files} }) {
            my $file_rec = $data->{files}->{ $file }; # file record
            $logger->trace(sprintf("Querying DB with: $select_query (%s, %s, %s)",
                $file_rec->{environment}, $file, $pf->{pattern}));
            $sth->execute(
                $file_rec->{environment},   # env shortname
                $file,                  # file shortname
                $pf->{pattern},         # pattern shortname
            ) or die "Failed to execute select query";
            my $r = $sth->fetchall_arrayref;
            $logger->trace("Got data from DB: ".p($r));
            $pf->{pattern_counts} = [] unless exists $pf->{pattern_counts};
            push @{$pf->{pattern_counts}}, {
                file            => $file,
                pattern         => $pf->{pattern},
                historic_data   => $r,
            };

        } # each pattern count

    } # each file pattern

    return $data;

} # sub fetch

sub get_dbh {
    my ($args) = @_;
    my $data = $args->{data} or die "expected 'data'";

    my $dbname = $data->{system}->{database}->{name};
    my $dbuser = $data->{system}->{database}->{user};

    my $dsn = "dbi:Pg:dbname=$dbname";
    my $dbh = DBI->connect($dsn, $dbuser, '');
    return $dbh;
}

1;
