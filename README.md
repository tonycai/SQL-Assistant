# SQL-Assistant
 SQL Assistant and more. Improve productivity with sql auto complete, snippets, text replacements and more. 


== Usage ==
* tonycai@dolphin:~/bin$ ./mysqltl4php.pl --config=wiki -tw_page

####################################################################
Variables List
####################################################################
$column_name = "";  // concat(column_comment,' ',column_type) 
$page_id = "";  // int(10) unsigned 
$page_namespace = "";  // int(11) 
$page_title = "";  // varchar(255) 
$page_restrictions = "";  // tinyblob 
$page_is_redirect = "";  // tinyint(3) unsigned 
$page_is_new = "";  // tinyint(3) unsigned 
$page_random = "";  // double unsigned 
$page_touched = "";  // binary(14) 
$page_links_updated = "";  // varbinary(14) 
$page_latest = "";  // int(10) unsigned 
$page_len = "";  // int(10) unsigned 
$page_content_model = "";  // varbinary(32) 
$page_lang = "";  // varbinary(35) 
####################################################################
Array Statement
####################################################################
$res = array(
    'column_name' => $column_name,
    'page_id' => $page_id,
    'page_namespace' => $page_namespace,
    'page_title' => $page_title,
    'page_restrictions' => $page_restrictions,
    'page_is_redirect' => $page_is_redirect,
    'page_is_new' => $page_is_new,
    'page_random' => $page_random,
    'page_touched' => $page_touched,
    'page_links_updated' => $page_links_updated,
    'page_latest' => $page_latest,
    'page_len' => $page_len,
    'page_content_model' => $page_content_model,
    'page_lang' => $page_lang
);
####################################################################
Insert Statement
####################################################################
insert into `w_page` (`column_name`, `page_id`, `page_namespace`, `page_title`, `page_restrictions`, `page_is_redirect`, `page_is_new`, `page_random`, `page_touched`, `page_links_updated`, `page_latest`, `page_len`, `page_content_model`, `page_lang`) values(:column_name, :page_id, :page_namespace, :page_title, :page_restrictions, :page_is_redirect, :page_is_new, :page_random, :page_touched, :page_links_updated, :page_latest, :page_len, :page_content_model, :page_lang);
####################################################################
Update Statement
####################################################################
update `w_page` set `column_name` = :column_name, `page_id` = :page_id, `page_namespace` = :page_namespace, `page_title` = :page_title, `page_restrictions` = :page_restrictions, `page_is_redirect` = :page_is_redirect, `page_is_new` = :page_is_new, `page_random` = :page_random, `page_touched` = :page_touched, `page_links_updated` = :page_links_updated, `page_latest` = :page_latest, `page_len` = :page_len, `page_content_model` = :page_content_model, `page_lang` = :page_lang where `column_name` = :column_name ;
####################################################################
Select Statement
####################################################################
select `column_name`, `page_id`, `page_namespace`, `page_title`, `page_restrictions`, `page_is_redirect`, `page_is_new`, `page_random`, `page_touched`, `page_links_updated`, `page_latest`, `page_len`, `page_content_model`, `page_lang` from `w_page` where `column_name` = ? ;
####################################################################
PHP PDO Statement
####################################################################

  $stmt = $this->pdo->prepare($sql);
  $stmt->execute($res);
  
  $last_id = $this->pdo->lastInsertId();
  $cols = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $stmt = $this->pdo->prepare($sql);
    $stmt->bindParam(':uid', $uid, PDO::PARAM_INT);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

Help Document:
https://secure.php.net/manual/zh/class.pdostatement.php

