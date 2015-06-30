package Parser;

use strict;
use warnings;

use File::Slurp; # read_file
use JSON 'decode_json';
use Data::Printer;
use DateTime;

use Log::Log4perl;
my $logger = Log::Log4perl->get_logger(__PACKAGE__);

sub file2hash {
    my ($args) = @_;
    my $file = $args->{file} or die "expected 'file'";
    my $data = read_file($file);
    my $decoded_json = decode_json($data);
    return $decoded_json;
}

sub validate_config {
    my ($c) = @_;
    my $patterns = $c->{patterns};
    my $envs = $c->{environments};
    my $files = $c->{files};

    #### TODO: Use some kind of automated JSON validation?
    # - every entity should have all required fields
    # - foreach $files, 'environment' must be in list of $envs
    # - foreach $file_patterns, names of 'file' and all 'patterns' must exist
}

sub process {
    # Entry point of module
    my ($args) = @_;
    my $configfile = $args->{configfile} or die "expected 'configfile'";
    my $config = file2hash({ file => $configfile });
    validate_config($config);
    return parse_all_patterns({
        config => $config,
    });
}

sub parse_all_patterns {
    my ($args) = @_;
    my $config = $args->{config} or die "expected 'config'";

    my $pattern_files = $config->{pattern_files};
    my $environments = $config->{environments};

    my $filedate = DateTime->now->subtract(days => 1)->ymd("");

    foreach my $record (@$pattern_files) {
        $logger->trace("Processing pattern_files record: ".p($record));
        my $pattern = $config->{patterns}->{ $record->{pattern} }; # pattern record

        # Fetch the file record
        my @files = map {
            my $file_record = $config->{files}->{$_};
            die "file shortname '$_' not found in \$config->{files}" unless $file_record; # validation
            my $x = {
                %$file_record,
                name => $_, # add in key name as hash subkey for later use
                path => $environments->{ $file_record->{environment} }->{path}, # add path for environment
            };
            { $x };
        } @{ $record->{files} }; # file records

        # Use the config data structure to save results
        $record->{pattern_counts} = parse_all_files({
            pattern     => $pattern,
            files       => \@files,
            filedate    => $filedate,
        });
    }

    return $config; # Now includes new pattern_count data
}

sub parse_all_files {
    my ($args) = @_;
    my @files = @{ $args->{files} } or die "expected 'files'";
    my $filedate = $args->{filedate} or die "expected 'filedate'";
    my $pattern = $args->{pattern} or die "expected 'pattern'";

    my @pattern_counts;
    foreach my $file (@files) {
        # Apply each regex to the file
        my $filename = join('/', $file->{path}, $file->{filename}); # XXX: Linux only
        my $regex = $pattern->{regex};
        my $match_count = parse({
            regex    => $regex,
            file     => $filename,
            filedate => $filedate,
        });
        if (defined $match_count) {
            # Successfully parsed the file, may have found zero matches
            $logger->trace("Found $match_count matches");
        } else {
            # Failed to parse the file
            $logger->warn("Failed to parse file: ".$file->{name});
        }
        # Save the result, positive, zero or undef
        push @pattern_counts, {
            file  => $file->{name},
            count => $match_count,
        };
    }
    return \@pattern_counts;
}

sub parse {
    my ($args) = @_;
    my $file = $args->{file} or die "expected 'file'";
    my $filedate = $args->{filedate} or die "expected 'filedate'";
    my $regex = $args->{regex} or die "expected 'regex'";
    # -P = Perl-style regex for grep
    # -c = count
    $file =~ s/YYYYMMDD/$filedate/;
    unless (-f $file) {
        $logger->warn("file $file does not exist");
        return;
    }

    # Handle single quotes in regex:
    # a) Leave and re-enter the single-quoting
    # b) Perl must escape the single backslash
    $regex =~ s{'}{'\\''}g;
    # Disable other escape sequences within the regex
    # until it's passed to grep
    $regex = "\\Q$regex\\E";

    my $command = "grep -Pc '$regex' $file"; # TODO: Use portabe perl grep
    $logger->trace("command = $command");
    my $match_count = `$command`;
    chomp($match_count) if defined $match_count;
    return $match_count; # may be undef upon error
}

1;
