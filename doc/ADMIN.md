## Git access

### Via HTTPS

If you want to use git repositories with `https` remotes, you need to set this app as **public**.

### Via SSH

If you want to use Gitea with SSH and be able to pull/push with your SSH key, your SSH daemon must be properly configured to use private/public keys.

Here is a sample configuration `/etc/ssh/sshd_config` that works with Gitea:

```bash
PubkeyAuthentication yes
AuthorizedKeysFile /home/yunohost.app/%u/.ssh/authorized_keys
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
```

You must also add your public key to your Gitea profile.

When using SSH on any port other than 22, you need to add these lines to your SSH configuration `~/.ssh/config`:

```bash
Host __DOMAIN__
    port 2222 # change this with the port you use
```

## LFS setup

To use a repository with an `LFS` setup, you need to activate it on `__INSTALL_DIR__/custom/conf/app.ini`

```ini
[server]
LFS_START_SERVER = true
LFS_HTTP_AUTH_EXPIRY = 20m
```

By default, NGINX is configured with a maximum value for uploading files at 200 MB. It's possible to change this value on `/etc/nginx/conf.d/__DOMAIN__.d/__APP__.conf`.

```nginx
client_max_body_size 200M;
```

Don't forget to restart Gitea:

```bash
sudo systemctl restart __APP__.service.
```

> These settings are restored to the default configuration when updating Gitea. Remember to restore your configuration after all updates.

## Upgrade

From command line:

```bash
yunohost app upgrade __APP__
```

If you want to bypass the safety backup before upgrading, run:

```bash
yunohost app upgrade --no-safety-backup __APP__
```

## Group management

Gitea support Yunohost group sync with Gitea Organisation Team.
As the organisation link to the group depends of the instance this should be configured by the admin on the gitea configuration interface in `DOMAIN/GITEA_PATH/admin/auths/1`.
Normally the admin just need to set the correct value of the `LDAP Group Team Map` parameter with something like this:
```json
{"cn=GROUPE_A_YNH,ou=groups,dc=yunohost,dc=org": {"gitea_organisation": ["gitea_team_A"]},
 "cn=GROUPE_B_YNH,ou=groups,dc=yunohost,dc=org": {"gitea_organisation": ["gitea_team_B"]}}
```

By this all members of the Yunohost groupe `GROUPE_A_YNH` will be member of the gitea team `gitea_team_A` of the organisation `gitea_organisation`.

**Note all others parameter are managed by the Yunohost package and should not be changed.**

## Backup

This application now uses the core-only feature of the backup. To keep the integrity of the data and to have a better guarantee of the restoration it is recommended to proceed as follows:

- Stop Gitea service:

```bash
systemctl stop __APP__.service
```

- Launch Gitea backup:

```bash
yunohost backup create --app __APP__
```

- Backup your data with your specific strategy (could be with rsync, borg backup or just cp). The data is generally stored in `/home/yunohost.app/__APP__`.
- Restart Gitea service:

```bash
systemctl start __APP__.service
```

## Remove

Due of the backup core only feature the data directory in `/home/yunohost.app/__APP__` **is not removed**. It must be manually deleted to purge user data from the app.
