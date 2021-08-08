MariaDB [wiki_en]> select user_id, count(rev_user) as edits_count, user_name from revision, user where rev_user=user_id group by rev_user order by edits_count desc limit 20;
+---------+-------------+------------------+
| user_id | edits_count | user_name        |
+---------+-------------+------------------+
|      13 |        4358 | Hennevogel       |
|      10 |        3286 | Rajko m          |
|    1545 |        2444 | Jsmeix           |
|      61 |        2264 | Saigkill         |
|       4 |        2227 | Spyhawk          |
|   21868 |        1824 | Ddemaio          |
|      27 |        1815 | Digitaltomm      |
|    3012 |        1726 | Jospoortvliet    |
|    1778 |        1598 | Guillaume G      |
|       5 |        1236 | A jaeger         |
|   41338 |        1153 | Guoyunhe         |
|      98 |        1044 | Pistazienfresser |
|    1091 |        1027 | Muhlemmer        |
|      84 |        1012 | HeliosReds       |
|      48 |        1004 | Jnweiger         |
|   13359 |         981 | A faerber        |
|   42008 |         954 | Lkocman          |
|    2639 |         908 | Diamond gr       |
|     131 |         867 | Manugupt1        |
|      82 |         782 | Lnussel          |
+---------+-------------+------------------+
20 rows in set (0.277 sec)
