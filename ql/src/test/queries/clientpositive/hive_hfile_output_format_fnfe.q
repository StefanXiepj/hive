-- create source table
drop table if exists t1;
create table t1( id string, name string, age int);
-- init data
insert overwrite table t1 values
('key_0', 'lily_0', 12),
('key_1', 'lily_1', 12),
('key_2', 'lily_2', 12),
('key_3', 'lily_3', 12),
('key_4', 'lily_4', 12);

--create hb range keys
drop table if exists range_keys;
create table range_keys( start_id string )
row format serde 'org.apache.hadoop.hive.serde2.binarysortable.BinarySortableSerDe'
stored as
inputformat 'org.apache.hadoop.mapred.TextInputFormat'
outputformat 'org.apache.hadoop.hive.ql.io.HiveNullValueSequenceFileOutputFormat'
location 'file:///tmp/range_keys';

--init range key
insert overwrite table range_keys values('key_0'),('key_2'),('key_4'),('key_6');

--create destination
drop table if exists t2;
create table t2 (
    id string,
    name string,
    age int)
stored as
    inputformat 'org.apache.hadoop.mapred.TextInputFormat'
    outputformat 'org.apache.hadoop.hive.hbase.HiveHFileOutputFormat'
tblproperties(
'hfile.family.path'='file:///tmp/C'
);

--running test
set mapreduce.totalorderpartitioner.path=file:///tmp/range_keys/000000_0;
set hive.mapred.partitioner=org.apache.hadoop.hive.ql.io.DefaultHivePartitioner;
set mapred.reduce.tasks=5;
insert overwrite table t2 select id as rowkey, name, age from t1 cluster by rowkey;
