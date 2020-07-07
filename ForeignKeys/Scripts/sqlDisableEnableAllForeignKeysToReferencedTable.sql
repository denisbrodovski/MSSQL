/*
    Script for disable/enable all foreign keys on referencing tables to referenced table
*/

declare
    @Referenced_Schema nvarchar(128) = 'dbo',
    @Referenced_Table nvarchar(128) = 'Files',
    @Do_Disable bit = 0,

    @Schema_Name nvarchar(128),
    @Table_Name nvarchar(128),
    @FK nvarchar(128),
    @sql nvarchar(max),
    @cur cursor;

set @cur = cursor local fast_forward read_only for
    select
        Schema_Name = object_schema_name(FK.parent_object_id),
        Table_Name = object_name(FK.parent_object_id),
        FK = object_name(FK.object_id)
    from sys.foreign_keys as FK
        inner join sys.objects as RO on RO.object_id = FK.referenced_object_id
    where 
        RO.name = @Referenced_Table
        and schema_name(RO.schema_id) = @Referenced_Schema;

open @cur;
while (1 = 1)
begin
    fetch @cur into @Schema_Name, @Table_Name, @FK;
    if @@fetch_status <> 0 break;

    set @sql = concat('alter table ', @Schema_Name, '.', @Table_Name, iif(@Do_Disable = 1, ' nocheck', ' check'), ' constraint ', @FK, ';');
    exec(@sql);
end
close @cur;
deallocate @cur;

