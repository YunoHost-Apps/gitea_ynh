<!--
Ohart ongi: README hau automatikoki sortu da <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>ri esker
EZ editatu eskuz.
-->

# Gitea YunoHost-erako

[![Integrazio maila](https://dash.yunohost.org/integration/gitea.svg)](https://ci-apps.yunohost.org/ci/apps/gitea/) ![Funtzionamendu egoera](https://ci-apps.yunohost.org/ci/badges/gitea.status.svg) ![Mantentze egoera](https://ci-apps.yunohost.org/ci/badges/gitea.maintain.svg)

[![Instalatu Gitea YunoHost-ekin](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=gitea)

*[Irakurri README hau beste hizkuntzatan.](./ALL_README.md)*

> *Pakete honek Gitea YunoHost zerbitzari batean azkar eta zailtasunik gabe instalatzea ahalbidetzen dizu.*  
> *YunoHost ez baduzu, kontsultatu [gida](https://yunohost.org/install) nola instalatu ikasteko.*

## Aurreikuspena

Gitea is a fork of Gogs a self-hosted Git service written in Go. Alternative to GitHub.


**Paketatutako bertsioa:** 1.22.3~ynh1

## Pantaila-argazkiak

![Gitea(r)en pantaila-argazkia](./doc/screenshots/screenshot.png)

## Dokumentazioa eta baliabideak

- Aplikazioaren webgune ofiziala: <https://gitea.io/>
- Administratzaileen dokumentazio ofiziala: <https://docs.gitea.io/>
- Jatorrizko aplikazioaren kode-gordailua: <https://github.com/go-gitea/gitea>
- YunoHost Denda: <https://apps.yunohost.org/app/gitea>
- Eman errore baten berri: <https://github.com/YunoHost-Apps/gitea_ynh/issues>

## Garatzaileentzako informazioa

Bidali `pull request`a [`testing` abarrera](https://github.com/YunoHost-Apps/gitea_ynh/tree/testing).

`testing` abarra probatzeko, ondorengoa egin:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/gitea_ynh/tree/testing --debug
edo
sudo yunohost app upgrade gitea -u https://github.com/YunoHost-Apps/gitea_ynh/tree/testing --debug
```

**Informazio gehiago aplikazioaren paketatzeari buruz:** <https://yunohost.org/packaging_apps>
