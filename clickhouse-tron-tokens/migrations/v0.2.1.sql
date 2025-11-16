-- PROJECTION REMOVALS --
ALTER TABLE native_transfer ON CLUSTER 'tokenapis-a' DROP PROJECTION prj_to_from_by_minute;
ALTER TABLE trc20_transfer ON CLUSTER 'tokenapis-a' DROP PROJECTION prj_log_address_from_by_minute;
ALTER TABLE trc20_transfer ON CLUSTER 'tokenapis-a' DROP PROJECTION prj_log_address_to_by_minute;
ALTER TABLE trc20_transfer ON CLUSTER 'tokenapis-a' DROP PROJECTION prj_log_address_from_to_by_minute;
