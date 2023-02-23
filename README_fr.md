# Gitea pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/gogs.svg)](https://dash.yunohost.org/appci/app/gogs) ![](https://ci-apps.yunohost.org/ci/badges/gogs.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/gogs.maintain.svg)  
[![Installer Gogs avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=gogs)

*[Read this readme in english.](./README.md)*
*[Lire ce readme en français.](./README_fr.md)*

> *Ce package vous permet d'installer Gogs rapidement et simplement sur un serveur YunoHost.
Si vous n'avez pas YunoHost, regardez [ici](https://yunohost.org/#/install) pour savoir comment l'installer et en profiter.*

## Vue d'ensemble

Gogs (Go Git Service) est une forge multiplateforme basée sur git écrite en Go. Sa particularité est d’être léger et pouvant fonctionner sur carte ARM, ce qui fait qu’il est adapté à l’auto-hébergement. Gogs a une interface web similaire à celle de GitHub. 


**Version incluse :** 0.12.6~ynh1

**Démo :** https://try.gogs.io/user/login

## Captures d'écran

![](./doc/screenshots/screenshot.png)

## Avertissements / informations importantes

## Notes on SSH usage

If you want to use Gogs with SSH and be able to pull/push with you SSH key, your SSH daemon must be properly configured to use private/public keys. Here is a sample configuration of `/etc/ssh/sshd_config` that works with Gogs:

```bash
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
```

You also need to add your public key to your Gogs profile.

If you use SSH on another port than 22, you need to add theses lines to your ssh config in `~/.ssh/config`:

```bash
Host domain.tld
    port 2222 # change this with the port you use
```

## Private Mode

Actually it's possible to access to the Git repositories by the `git` command over HTTP also in private mode installation. It's important to know that in this mode the repository could be ALSO getted if you don't set the repository as private in the repos settings.

## Documentations et ressources

* Site officiel de l'app : http://gogs.io
* Documentation officielle de l'admin : https://gogs.io/docs
* Dépôt de code officiel de l'app : https://github.com/gogs/gogs
* Documentation YunoHost pour cette app : https://yunohost.org/app_gogs
* Signaler un bug : https://github.com/YunoHost-Apps/gogs_ynh/issues

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/gogs_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/gogs_ynh/tree/testing --debug
ou
sudo yunohost app upgrade gogs -u https://github.com/YunoHost-Apps/gogs_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications :** https://yunohost.org/packaging_apps