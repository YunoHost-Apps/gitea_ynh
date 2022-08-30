INSERT INTO `__APP__`.`login_source` 
(`id`, `type`, `name`, `is_active`, `cfg`, `created_unix`, `updated_unix`)
VALUES
('1', '2', 'YunoHost LDAP', '1', '{"Name":"Yunohost LDAP","Host":"localhost","Port":389,"UseSSL":false,"BindDN":"","BindPassword":"","UserBase":"ou=users,dc=yunohost,dc=org","AttributeName":"givenName","AttributeSurname":"sn","AttributeMail":"mail","Filter":"(&(uid=%s)(objectClass=posixAccount)(permission=cn=__APP__.main,ou=permission,dc=yunohost,dc=org))","AdminFilter":"(permission=cn=__APP__.admin,ou=permission,dc=yunohost,dc=org)","Enabled":true}', '1464014433', '1464015955')
ON DUPLICATE KEY 
UPDATE cfg='{"Name":"YunoHost LDAP","Host":"localhost","Port":389,"UseSSL":false,"BindDN":"","BindPassword":"","UserBase":"ou=users,dc=yunohost,dc=org","AttributeName":"givenName","AttributeSurname":"sn","AttributeMail":"mail","Filter":"(&(uid=%s)(objectClass=posixAccount)(permission=cn=__APP__.main,ou=permission,dc=yunohost,dc=org))","AdminFilter":"(permission=cn=__APP__.admin,ou=permission,dc=yunohost,dc=org)","Enabled":true}';
