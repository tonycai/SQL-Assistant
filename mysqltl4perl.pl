#!/usr/bin/env perl

####################################################################
# author     : tonycai
# e-mail     : tonycai321@gmail.com
# desc       : mysql Extend
# created-at : 2008-05-12
#####################################################################
use strict;
use warnings;
use utf8;
use DBI;
use Encode;
use Data::Dumper;



### useage
my $argvfirst = $ARGV[0];
$argvfirst = "" if(!defined($argvfirst));
if($argvfirst eq "--help" || $argvfirst eq "-?" || $argvfirst eq ""){
print <<END;
mysqltl  Ver 0.12 , for redhat-linux-gnu (i386) using readline 5.0
Copyright (C) 2008 anjuke.com
This software created by tonycai at 2008-05-20. This is free software,
and you are welcome to modify and redistribute it under the GPL license
Usage: mysql [OPTIONS] [database]
  -?, --help          Display this help and exit.
  --config            config filename
  --table             database's table name
  -D                  Database to use.
END
exit;
}

#############add config file by tonycai#######
## Initialize some variables set by options.
my %opt = (
                "nobad" => 0,
                "nogood" => 0,
                "noinfo" => 0,
                "nocolor" => 0,
                "forcemem" => 0,
                "forceswap" => 0,
                "host" => 0,
                "port" => 0,
                "db" => "",
                "charset" => "",
                "user" => 0,
                "pass" => 0,
                "skipsize" => 0,
                "checkversion" => 0,
        );
use vars qw/
$config $t
$db
/;
my %param=();
  for (0..@ARGV-1) { $param{$_}=$ARGV[$_]; }
   foreach my $key (sort keys %param) {
     if ($param{$key} =~ /(^|-|&)config=([^&]+)/i) { $config=$2; shift; next; }
     if ($param{$key} =~ /(^|-|&)D([^&]+)/i) { $db=$2; shift; next; }
     if ($param{$key} =~ /(^|-|&)t([^&]+)/i) { $t=$2; shift; next; }
   }
   $config = "$ENV{HOME}/.mytop/mytop_".$config if($config ne "");#mouse,whale,dolphin,dolphin2
   $config = "$ENV{HOME}/.mytop/mytop_default" if(!defined($config) || $config eq "");
   $t = "ajk_members" if(!defined($t) || $t eq "");
#
#printf("%s\n",$config);

if (-e $config)
{
    if (open CFG, "<$config")
    {
        while (<CFG>)
        {
            next if /^\s*$/;  ## skip blanks
            next if /^\s*#/;  ## skip comments
 
            chomp;
 
            if (/(\S+)\s*=\s*(.*\S)/)
            {
                $opt{lc $1} = $2 if exists $opt{lc $1};
            }
        }
        close CFG;
    }
}
#############add config file by tonycai#######
## Initialize some variables set by options.

#binmode(STDOUT, ":utf8");
if(defined($db))
{
  $opt{'db'} = $db;
}

my $i = 0;
my $sql = "";

#print Dumper(%opt);
#exit 1;

open (MYPIPE, "mysql -u$opt{'user'} -p$opt{'pass'} --default-character-set=$opt{'charset'} -D$opt{'db'} -e 'desc $t ;' 2>&1 |")|| 
     die ("Could not open file");
while (my $line = <MYPIPE>) {
  #ERROR 1146 (42S02) at line 1: Table 'anjuke_db_dy.ajk_shop' doesn't exist
  if($line =~ m/^ERROR \d+/){
    print $line;
    exit;
  }
  &printsf("Variables List") if($i==0);
  if($i>0){
    $line =~ s/\s+/ /g;
    my($l) = $line =~ m/^\w+/ig;
    print "my \$".lc($l)." = \"\";" ."\n";
    if($sql ne ""){
      $sql .= ", ". $l;
    }
    else{
      $sql = $l;
    }
  }
  $i++;
}
my $insertsql = $sql;

$insertsql =~ s/, /','/ig;
$insertsql =~ s/(\w+)/sprintf("\$%s", lc($1))/seg;

my $i_sql = $sql;
$i_sql =~ s/(\w+)/sprintf("`%s`", "$1")/seg;
my $sql2 = "insert into `$t` (${i_sql}) values('${insertsql}');";

&printsf("Insert Statement");
print "\e[00;32m$sql2\e[00m\n";

&printsf("Update Statement");
my $updatesql = $sql;
$updatesql =~ s/(\w+)/sprintf("`$1`='\$%s'", lc($1))/seg;
#update ajk_communitys set CommId='CommId',
my ($id1,$id2) = $updatesql =~ m/`(\w+)`='\$(\w+)'/oi;
my $sql4 = "update `$t` set $updatesql where `$id1` = ? ;";
print $sql4."\n";
&printsf("Select Statement");
my $select_sql = $sql;
$select_sql =~ s/(\w+)/sprintf("`%s`", "$1")/seg;
print "select $select_sql from `$t` where `$id1` = ? ;\n";
sub trim($)
{
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

sub printsf{
  my($msg) = @_;
  my $barner = "####################################################################\n";
  print $barner;
  print "\e[00;34m$msg\e[00m\n";
  print $barner;
}

