#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use Parser;
use Store::Database;
use Display::Graph;
use Display::Page;
use Data::Printer;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Template;
use boolean; # true/false

use Log::Log4perl;
Log::Log4perl::init('conf/log4perl.conf');
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

$logger->info("Started building web page");

my $q = CGI->new;
print $q->header('text/html');

my $configfile = 'conf/config.json';

my $results = Parser::file2hash({
    file => $configfile,
});
$logger->trace("read config");

$results = Store::Database::fetch({
    data => $results,
});
$logger->trace("fetched from DB");

my $graphs_response = Display::Graph::build({
    data => $results,
});
$logger->trace("built graphs");

$results = Display::Page::transform({
    data => $results,
});
$logger->trace("transformed data for page");

my $template = Template->new({
    # where to find template files
    INCLUDE_PATH => [ $results->{system}->{template}->{base_full_path} ],
});
$template->process('web/report.tt2', $results) or die "Template process failed: " . $template->error;
$logger->trace("rendered page");

$logger->info("Finished building web page");
