#=================================================
# SET ALL CONSTANTS
#=================================================

app=$YNH_APP_INSTANCE_NAME
dbname=$app
dbuser=$app
final_path="/opt/$app"
DATADIR="/home/$app"
REPO_PATH="$DATADIR/repositories"
DATA_PATH="$DATADIR/data"

# Detect the system architecture to download the right tarball
# NOTE: `uname -m` is more accurate and universal than `arch`
# See https://en.wikipedia.org/wiki/Uname
if [ -n "$(uname -m | grep 64)" ]; then
	architecture="x86-64"
elif [ -n "$(uname -m | grep 86)" ]; then
	architecture="i386"
elif [ -n "$(uname -m | grep arm)" ]; then
	architecture="arm"
else
	ynh_die "Unable to detect your achitecture, please open a bug describing \
        your hardware and the result of the command \"uname -m\"." 1
fi

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

create_dir() {
    mkdir -p "$final_path/data"
    mkdir -p "$final_path/custom/conf"
    mkdir -p "$REPO_PATH"
    mkdir -p "$DATA_PATH/avatars"
    mkdir -p "$DATA_PATH/attachments"
    mkdir -p "/var/log/$app"
}

config_nginx() {
    if [ "$path_url" != "/" ]
    then
        ynh_replace_string "^#sub_path_only" "" "../conf/nginx.conf"
    fi
    ynh_add_nginx_config
}

config_gitea() {
    ynh_backup_if_checksum_is_different "$final_path/custom/conf/app.ini"

    cp ../conf/app.ini "$final_path/custom/conf"

    if [ "$path_url" = "/" ]
    then
        ynh_replace_string "__URL__" "$domain" "$final_path/custom/conf/app.ini"
    else
        ynh_replace_string "__URL__" "$domain${path_url%/}" "$final_path/custom/conf/app.ini"
    fi

    ynh_replace_string "__REPOS_PATH__" "$REPO_PATH" "$final_path/custom/conf/app.ini"
    ynh_replace_string "__DB_PASSWORD__" "$dbpass" "$final_path/custom/conf/app.ini"
    ynh_replace_string "__DB_USER__" "$dbuser" "$final_path/custom/conf/app.ini"
    ynh_replace_string "__DOMAIN__" "$domain" "$final_path/custom/conf/app.ini"
    ynh_replace_string "__KEY__" "$key" "$final_path/custom/conf/app.ini"
    ynh_replace_string "__DATA_PATH__" "$DATA_PATH" "$final_path/custom/conf/app.ini"
    ynh_replace_string "__PORT__" $port "$final_path/custom/conf/app.ini"
    ynh_replace_string "__APP__" $app "$final_path/custom/conf/app.ini"

    ynh_store_file_checksum "$final_path/custom/conf/app.ini"
}

set_permission() {
    chown -R $app:$app "$final_path"
    chown -R $app:$app "/home/$app"
    chown -R $app:$app "/var/log/$app"
    chmod u=rwX,g=rX,o= "$final_path"
    chmod u=rwX,g=rX,o= "/home/$app"
    chmod u=rwX,g=rX,o= "/var/log/$app"
}
