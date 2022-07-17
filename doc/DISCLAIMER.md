## Notes on SSH usage

If you want to use Gitea with ssh and be able to pull/push with you ssh key, your ssh daemon must be properly configured to use private/public keys. Here is a sample configuration of `/etc/ssh/sshd_config` that works with Gitea:

```bash
PubkeyAuthentication yes
AuthorizedKeysFile /home/%u/.ssh/authorized_keys
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
```

You also need to add your public key to your Gitea profile.

If you use SSH on another port than 22, you need to add theses lines to your ssh config in `~/.ssh/config`:

```bash
Host domain.tld
    port 2222 # change this with the port you use
```

You will also need to add the gitea user in the ssh permission with this command:
```bash

sudo adduser gitea ssh.app
```

## Private Mode

Actually it's possible to access to the Git repositories by the `git` command over HTTP also in private mode installation. It's important to know that in this mode the repository could be ALSO getted if you don't set the repository as private in the repos settings.

## Remove Gitea

Due of the backup core only feature the data directory in `/home/yunohost.app/gitea` is not removed unless using thr purge option: `sudo yunohost app remove gitea --purge` 
