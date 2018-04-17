#!/usr/bin/env perl

####################################################################
# author     : tonycai
# e-mail     : tonycaii321@gmail.com
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
This software created by caixh at 2008-05-20. This is free software,
and you are welcome to modify and redistribute it under the GPL license
Usage: mysql [OPTIONS] [database]
  -?, --help          Display this help and exit.
  --config            config filename
  --table             database's table name
  -D                  Database to use.
END
exit;
}

#############add config file by caixh#######
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
   $config = "" if(!defined($config));
   $config = "$ENV{HOME}/.mytop/mytop_".$config if($config ne "");#mouse,whale,dolphin,dolphin2
   $config = "$ENV{HOME}/.mytop/mytop_default" if(!defined($config) || $config eq "");
   $t = "t_users" if(!defined($t) || $t eq "");
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
#############add config file by caixh#######
## Initialize some variables set by options.

#binmode(STDOUT, ":utf8");
if(defined($db))
{
  $opt{'db'} = $db;
}

my $i = 0;
my $sql = "";

#print Dumper(%opt);
#print $opt{'pass'} ."\n";
#exit 1;
my $show_table_schema = "select column_name, concat(column_comment,' ',column_type) from information_schema.columns where table_schema =\'".$opt{'db'}."\'  and  table_name = \'".$t."\';";
#print "$show_table_schema\n";
#exit 1;
#open (MYPIPE, "mysql -u$opt{'user'} --default-character-set=$opt{'charset'} -D$opt{'db'} -e 'show create table $t ;' 2>&1 |")|| 
#open (MYPIPE, "mysql -u$opt{'user'} --default-character-set=$opt{'charset'} -D$opt{'db'} -e 'desc $t ;' 2>&1 |")|| 
open (MYPIPE, "mysql -u$opt{'user'} -p$opt{'pass'} --default-character-set=$opt{'charset'} -D$opt{'db'} -e \"$show_table_schema\" 2>&1 |")|| 
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
    #printf("#%d , %s\n",$i, $line);
    my $comment1 = "";
    my($l, $comment) = $line =~ m/^(\w+)\s(.+?)$/ig;
    ($l) = $line =~ m/^(\w+)/ig if(!defined($l));
    if(!defined($comment)){
       $comment1 = "" 
    }
    else{
       $comment1 = "  // "  . $comment;
    }
    $l = "" if(!defined($l));
    print "\$".lc($l)." = \"\";" ."$comment1\n";
    if($sql ne ""){
      $sql .= ", ". $l;
    }
    else{
      $sql = $l;
    }
  }
  $i++;
}
#exit 1;
my $insertsql = $sql;
my $arr_str = $sql;

$insertsql =~ s/, /, :/ig;
$insertsql =~ s/(\w+)/sprintf("%s", lc($1))/seg;
$arr_str =~ s/, /,\n    /ig;
$arr_str =~ s/(\w+)/sprintf("'%s' => \$%s", lc($1), lc($1))/seg;
$arr_str = "\$res = array(\n    ".$arr_str."\n);";

my $i_sql = $sql;
$i_sql =~ s/(\w+)/sprintf("`%s`", "$1")/seg;
my $sql2 = "insert into `$t` (${i_sql}) values(:${insertsql});";
&printsf("Array Statement");
print "$arr_str\n";
&printsf("Insert Statement");
print "\e[00;32m$sql2\e[00m\n";

&printsf("Update Statement");
my $updatesql = $sql;
$updatesql =~ s/(\w+)/sprintf("`$1` = %s", ":$1")/seg;
#update ajk_communitys set CommId='CommId',
my ($id1) = $sql =~ m/(\w+),\s/oi;
$id1 = "id" if(!defined($id1));
#print "$id1\n";
#print "$sql\n";
#exit;
my $sql4 = "update `$t` set $updatesql where `$id1` = :$id1 ;";
print $sql4."\n";
&printsf("Select Statement");
my $select_sql = $sql;
$select_sql =~ s/(\w+)/sprintf("`%s`", "$1")/seg;
print "select $select_sql from `$t` where `$id1` = ? ;\n";
&printsf("PHP PDO Statement");

print  <<PDOStatement;

  \$stmt = \$this->pdo->prepare(\$sql);
  \$stmt->execute(\$res);
  
  \$last_id = \$this->pdo->lastInsertId();
  \$cols = \$stmt->fetchAll(PDO::FETCH_COLUMN);

    \$stmt = \$this->pdo->prepare(\$sql);
    \$stmt->bindParam(':uid', \$uid, PDO::PARAM_INT);
    \$stmt->bindParam(':limit', \$limit, PDO::PARAM_INT);
    \$stmt->bindParam(':offset', \$offset, PDO::PARAM_INT);
    \$stmt->execute();

Help Document:
https://secure.php.net/manual/zh/class.pdostatement.php

PDOStatement

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

=head
//php code
    protected function save_collect($uid, $jid)
    {
      $id = 0;

      $id = $this->get_collect_id($uid, $jid);
      $res = array('uid'=>$uid, 'jid'=>$jid, 'status'=>1);
      $res['client_ip'] = Util_NetWorkAddress::get_client_ip();
      $res['create_time'] = time();

      if($id==0){
          $sql = <<<SQL
insert into t_dingjob_collect
(uid, jid, status, client_ip, create_time)
values (:uid, :jid, :status, :client_ip, :create_time);
SQL;
          $stmt = $this->pdo->prepare($sql);
          $stmt->execute($res);
          $id = $this->pdo->lastInsertId();
      }
      else
      {
          $this->update_collect($id);
      }
      return $id;
    }
//

                $sql = "SELECT  * from tablename where 1=? order by id asc ;";
                $stmt = $lky_pdo->prepare($sql);
                $stmt->execute(array($id));
                $validdates = $stmt->fetchAll(PDO::FETCH_COLUMN);

//
public function dao_update_user_fund_by_uid($fund, $uid) {
                $sql = "UPDATE drupal_users SET fund = ? WHERE uid = ?";
                $stmt = $this->one_pdo->prepare($sql);
                return $stmt->execute(array($fund, $uid));
        }

public function update_new_customer_by_info($info, $isnew = TRUE) {
                if ($isnew) {
                        $sql = "UPDATE t_customer SET sales_flag = ?, first_admin_uid = ?, last_admin_uid = ? WHERE id = ?";
                }
                else {
                        $sql = "UPDATE t_customer SET last_order_date = ?,sales_flag = ?, first_admin_uid = ?, last_admin_uid = ? WHERE id = ?";
                }
                $stmt = $this->pdo->prepare($sql);
                return $stmt->execute($info);
        }

  public function stat_order($uid, $limit = 10, $offset = 0) {
    $sql = <<<SQL
SELECT (
  SELECT FROM_UNIXTIME(create_date,'%Y-%m-%d')
  FROM log_homestay_booking_trac
  WHERE t_homestay_booking.id=log_homestay_booking_trac.bid
  AND log_homestay_booking_trac.status=2
  ORDER BY tid LIMIT 1
) AS transaction_date,t_homestay_booking.*
FROM t_homestay_booking
WHERE zfansref = :uid AND exists(SELECT *
  FROM log_homestay_booking_trac
  WHERE t_homestay_booking.id=log_homestay_booking_trac.bid
  AND log_homestay_booking_trac.status=2)
ORDER BY id DESC
LIMIT :limit OFFSET :offset
SQL;
    $stmt = $this->slave_pdo->prepare($sql);
    $stmt->bindParam(':uid', $uid, PDO::PARAM_INT);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll();
  }
}


Help Document
https://secure.php.net/manual/zh/pdostatement.fetchcolumn.php
=cut
