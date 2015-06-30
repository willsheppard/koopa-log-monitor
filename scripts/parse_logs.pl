#!/usr/bin/perl

=head1 DESCRIPTION

Parse a set of files for patterns (details specified in config), and load the results into a database

=head1 USAGE

Usage: parse_logs.pl [year month day]

Where [year month day] is optional, intended to override today's date
when re-parsing old data for new patterns.

=cut

use strict;
use warnings;

use Log::Log4perl;
Log::Log4perl::init('conf/log4perl.conf');

use lib 'lib';
use Parser;
use Store::Database;
use Data::Printer;

my $logger = Log::Log4perl->get_logger(__PACKAGE__);

my $year = $ARGV[0];
my $month = $ARGV[1];
my $day = $ARGV[2];

# Start

$logger->info("Started parsing");

my $configfile = 'conf/config.json';

my $results = Parser::process({
    configfile => $configfile,
});

$logger->debug("Processed");

my $stored_response = Store::Database::store({
    data => $results,
    year => $year,
    month => $month,
    day => $day,
});

$logger->debug("Stored");

$logger->info("Finished parsing");
