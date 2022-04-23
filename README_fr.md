# Gitea pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/gitea.svg)](https://dash.yunohost.org/appci/app/gitea) ![](https://ci-apps.yunohost.org/ci/badges/gitea.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/gitea.maintain.svg)  
[![Installer Gitea avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=gitea)

*[Read this readme in english.](./README.md)*
*[Lire ce readme en français.](./README_fr.md)*

> *Ce package vous permet d'installer Gitea rapidement et simplement sur un serveur YunoHost.
Si vous n'avez pas YunoHost, regardez [ici](https://yunohost.org/#/install) pour savoir comment l'installer et en profiter.*

## Vue d'ensemble

Gitea is a fork of Gogs a self-hosted Git service written in Go. Alternative to Github.


**Version incluse :** 1.16.5~ynh1



## Captures d'écran

![](./doc/screenshots/screenshot.png)

## Avertissements / informations importantes

Additional informations
-----------------------

### Notes on SSH usage

If you want to use Gitea with ssh and be able to pull/push with you ssh key, your ssh daemon must be properly configured to use private/public keys. Here is a sample configuration of `/etc/ssh/sshd_config` that works with Gitea:

```bash
PubkeyAuthentication yes
AuthorizedKeysFile /home/yunohost.app/%u/.ssh/authorized_keys
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
```

You also need to add your public key to your Gitea profile.

If you use ssh on another port than 22, you need to add theses lines to your ssh config in `~/.ssh/config`:

```bash
Host domain.tld
    port 2222 # change this with the port you use
```

### Upgrade

By default a backup is made before the upgrade. To avoid this you have theses following possibilites:
- Pass the `NO_BACKUP_UPGRADE` env variable with `1` at each upgrade. By example `NO_BACKUP_UPGRADE=1 yunohost app upgrade gitea`.
- Set the settings `disable_backup_before_upgrade` to `1`. You can set this with this command:

`yunohost app setting gitea disable_backup_before_upgrade -v 1`

After this settings will be applied for **all** next upgrade.

From command line:

`yunohost app upgrade gitea`

### Backup

This app use now the core-only feature of the backup. To keep the integrity of the data and to have a better guarantee of the restoration is recommended to proceed like this:

- Stop gitea service with theses following command:

`systemctl stop gitea.service`

- Launch the backup of gitea with this following command:

`yunohost backup create --app gitea`

- Do a backup of your data with your specific strategy (could be with rsync, borg backup or just cp). The data is generally stored in `/home/yunohost.app/gitea`.
- Restart the gitea service with theses command:

`systemctl start gitea.service`

### Remove

Due of the backup core only feature the data directory in `/home/yunohost.app/gitea` **is not removed**. It need to be removed manually to purge app user data.

### LFS setup
To use a repository with an `LFS` setup, you need to activate-it on `/opt/gitea/custom/conf/app.ini`
```ini
[server]
LFS_START_SERVER = true
LFS_HTTP_AUTH_EXPIRY = 20m
```
By default Nginx is setup with a max value to updload files at 200 Mo. It's possible to change this value on `/etc/nginx/conf.d/my.domain.tld.d/gitea.conf`.
```
client_max_body_size 200M;
```
Don't forget to restart Gitea `sudo systemctl restart gitea.service`.

> This settings are restored to the default config when Gitea is updated. Don't forget to restore your setup after all updates.

### Git command access with HTTPS

If you want to use the git command (like `git clone`, `git pull`, `git push`), you need to set this app as **public**.

## Documentations et ressources

* Site officiel de l'app : https://gitea.io/
* Documentation officielle de l'admin : https://docs.gitea.io/
* Dépôt de code officiel de l'app : https://github.com/go-gitea/gitea
* Documentation YunoHost pour cette app : https://yunohost.org/app_gitea
* Signaler un bug : https://github.com/YunoHost-Apps/gitea_ynh/issues

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/gitea_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/gitea_ynh/tree/testing --debug
ou
sudo yunohost app upgrade gitea -u https://github.com/YunoHost-Apps/gitea_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications :** https://yunohost.org/packaging_apps
