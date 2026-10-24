## Accès Git

### Via HTTPS

Si vous souhaitez utiliser des dépôts Git avec des serveurs distants `https`, vous devez définir cette application comme **publique**.

### Via SSH

Si vous souhaitez utiliser Gitea avec SSH et pouvoir effectuer des opérations de pull/push avec votre clé SSH, votre démon SSH doit être correctement configuré pour utiliser des clés privées/publiques.

Voici un exemple de configuration du fichier `/etc/ssh/sshd_config` compatible avec Gitea :

```bash
PubkeyAuthentication yes
AuthorizedKeysFile /home/yunohost.app/%u/.ssh/authorized_keys
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
```

Vous devez également ajouter votre clé publique à votre profil Gitea.

Si vous utilisez SSH sur un port autre que le 22, vous devez ajouter ces lignes à votre fichier de configuration SSH `~/.ssh/config` :

```bash
Host __DOMAIN__
    port 2222 # remplacez cette valeur par le port que vous utilisez
```

## Configuration de LFS

Vous pouvez activer la configuration de LFS depuis votre application d'administration.

## Mise à jour

Depuis la ligne de commande :

```bash
yunohost app upgrade __APP__
```

Si vous souhaitez ignorer la sauvegarde de sécurité avant la mise à jour, exécutez :

```bash
yunohost app upgrade --no-safety-backup __APP__
```

## Gestion des groupes

Gitea prend en charge la synchronisation des groupes YunoHost avec les équipes des organisations Gitea.
Comme le lien entre l’organisation et le groupe dépend de l’instance, cela doit être configuré par l’administrateur dans l’interface de configuration de Gitea à l’adresse `DOMAIN/GITEA_PATH/admin/auths/1`.
En règle générale, l’administrateur n’a qu’à définir la valeur correcte du paramètre `LDAP Group Team Map` avec quelque chose comme ceci :
```json
{"cn=GROUPE_A_YNH,ou=groups,dc=yunohost,dc=org": {"gitea_organisation": ["gitea_team_A"]},
 "cn=GROUPE_B_YNH,ou=groups,dc=yunohost,dc=org": {"gitea_organisation": ["gitea_team_B"]}}
```

Ainsi, tous les membres du groupe YunoHost `GROUPE_A_YNH` feront partie de l'équipe Gitea `gitea_team_A` de l'organisation `gitea_organisation`.

**Remarque : tous les autres paramètres sont gérés par le paquet YunoHost et ne doivent pas être modifiés.**



## Sauvegarde

Cette application utilise désormais la fonctionnalité de sauvegarde « core-only ». Afin de préserver l’intégrité des données et d’optimiser les chances de réussite de la restauration, il est recommandé de procéder comme suit :

- Arrêter le service Gitea :

```bash
systemctl stop __APP__.service
```

- Lancer la sauvegarde Gitea :

```bash
yunohost backup create --app __APP__
```

- Sauvegardez vos données selon votre stratégie spécifique (par exemple avec rsync, borg backup ou simplement cp). Les données sont généralement stockées dans `/home/yunohost.app/__APP__`.
- Redémarrez le service Gitea :

```bash
systemctl start __APP__.service
```

## Suppression

En raison de la fonctionnalité propre au noyau de sauvegarde, le répertoire de données situé dans `/home/yunohost.app/__APP__` **n'est pas supprimé**. Il doit être supprimé manuellement pour purger les données utilisateur de l'application.
