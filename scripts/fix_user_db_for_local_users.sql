UPDATE `__APP__`.`user`
SET `login_type` = 2, `login_source` = 1, `login_name` = `name`
WHERE `user`.`name` in __USER_LIST__ ;
