## Remarques sur l'utilisation de SSH

Si vous souhaitez utiliser Gitea avec SSH et pouvoir pull/push avec votre clé SSH, votre démon SSH doit être correctement configuré pour utiliser des clés privées/publiques. Voici un exemple de configuration de `/etc/ssh/sshd_config` qui fonctionne avec Gitea :

```bash
PubkeyAuthenticationoui
AuthorizedKeysFile %h/.ssh/authorized_keys
ChallengeResponseAuthentication non
Authentification par mot de passe non
UtiliserPAM non
```

Vous devez également ajouter votre clé publique à votre profil Gitea.

Si vous utilisez SSH sur un autre port que le 22, vous devez ajouter ces lignes à votre configuration SSH dans `~/.ssh/config` :

```bash
Domaine hôte.tld
     port 2222 # changez ceci avec le port que vous utilisez
```

## Mode privé

En fait, il est possible d'accéder aux référentiels Git par la commande `git` via HTTP également dans l'installation en mode privé. Il est important de savoir que dans ce mode, le référentiel peut également être obtenu si vous ne définissez pas le référentiel comme privé dans les paramètres du référentiel.