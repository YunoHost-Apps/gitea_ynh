#=================================================
# SET ALL CONSTANTS
#=================================================

app=$YNH_APP_INSTANCE_NAME
dbname=$app
db_user=$app
final_path="/opt/$app"
DATADIR="/home/$app"
REPO_PATH="$DATADIR/repositories"
DATA_PATH="$DATADIR/data"
SSH_PATH="$DATADIR/.ssh"

# Detect the system architecture to download the right tarball
# NOTE: `uname -m` is more accurate and universal than `arch`
# See https://en.wikipedia.org/wiki/Uname
if [ -n "$(uname -m | grep arm64)" ] || [ -n "$(uname -m | grep aarch64)" ]; then
    architecture="arm64"
elif [ -n "$(uname -m | grep 64)" ]; then
    architecture="x86-64"
elif [ -n "$(uname -m | grep 86)" ]; then
    architecture="i386"
elif [ -n "$(uname -m | grep armv7)" ]; then
    architecture="armv7"
elif [ -n "$(uname -m | grep arm)" ]; then
    architecture="arm"
else
	ynh_die --message "Unable to detect your achitecture, please open a bug describing \
        your hardware and the result of the command \"uname -m\"." 1
fi

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

create_dir() {
    mkdir -p "$final_path/data"
    mkdir -p "$final_path/custom/conf"
    mkdir -p "$SSH_PATH"
    mkdir -p "$REPO_PATH"
    mkdir -p "$DATA_PATH/avatars"
    mkdir -p "$DATA_PATH/attachments"
    mkdir -p "/var/log/$app"
}

config_nginx() {
    if [ "$path_url" != "/" ]
    then
        ynh_replace_string --match_string "^#sub_path_only" --replace_string "" --target_file "../conf/nginx.conf"
    fi
    ynh_add_nginx_config
}

config_gitea() {
    ssh_port=$(grep -P "Port\s+\d+" /etc/ssh/sshd_config | grep -P -o "\d+")
    ynh_add_config --template="app.ini" --destination="$final_path/custom/conf/app.ini"
}

set_permission() {
    chown -R $app:$app "$final_path"
    chown -R $app:$app "/home/$app"
    chown -R $app:$app "/var/log/$app"

    chmod u=rwX,g=rX,o= "$final_path"
    chmod u=rwx,g=rx,o= "$final_path/gitea"
    chmod u=rwx,g=rx,o= "$final_path/custom/conf/app.ini"
    chmod u=rwX,g=rX,o= "/home/$app"
    chmod u=rwX,g=rX,o= "/var/log/$app"
}
