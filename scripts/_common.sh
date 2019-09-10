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
    ynh_backup_if_checksum_is_different --file "$final_path/custom/conf/app.ini"

    cp ../conf/app.ini "$final_path/custom/conf"
    usermod -s /bin/bash $app

    if [ "$path_url" = "/" ]
    then
        ynh_replace_string --match_string __URL__ --replace_string "$domain" --target_file "$final_path/custom/conf/app.ini"
    else
        ynh_replace_string --match_string __URL__ --replace_string "$domain${path_url%/}" --target_file "$final_path/custom/conf/app.ini"
    fi

    ynh_replace_string --match_string __REPOS_PATH__ --replace_string "$REPO_PATH" --target_file "$final_path/custom/conf/app.ini"
    ynh_replace_string --match_string __DB_PASSWORD__ --replace_string "$dbpass" --target_file "$final_path/custom/conf/app.ini"
    ynh_replace_string --match_string __DB_USER__ --replace_string "$dbuser" --target_file "$final_path/custom/conf/app.ini"
    ynh_replace_string --match_string __DOMAIN__ --replace_string "$domain" --target_file "$final_path/custom/conf/app.ini"
    ynh_replace_string --match_string __KEY__ --replace_string "$key" --target_file "$final_path/custom/conf/app.ini"
    ynh_replace_string --match_string __DATA_PATH__ --replace_string "$DATA_PATH" --target_file "$final_path/custom/conf/app.ini"
    ynh_replace_string --match_string __PORT__ --replace_string $port --target_file "$final_path/custom/conf/app.ini"
    ynh_replace_string --match_string __APP__ --replace_string $app --target_file "$final_path/custom/conf/app.ini"
    ynh_replace_string --match_string __SSH_PORT__ --replace_string $ssh_port --target_file "$final_path/custom/conf/app.ini"

    ynh_store_file_checksum --file "$final_path/custom/conf/app.ini"
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

set_access_settings() {
    if [ "$is_public" = '1' ]
    then
        ynh_app_setting_set --app $app --key unprotected_uris --value "/"
    else
        # For an access to the git server by https in private mode we need to allow the access to theses URL :
        #  - "DOMAIN/PATH/USER/REPOSITORY/info/refs"
        #  - "DOMAIN/PATH/USER/REPOSITORY/git-upload-pack"
        #  - "DOMAIN/PATH/USER/REPOSITORY/git-receive-pack"

        excaped_domain=${domain//'.'/'%.'}
        excaped_domain=${excaped_domain//'-'/'%-'}
        excaped_path=${path_url//'.'/'%.'}
        excaped_path=${excaped_path//'-'/'%-'}
        ynh_app_setting_set --app $app --key skipped_regex --value "$excaped_domain$excaped_path/[%w-.]*/[%w-.]*/git%-receive%-pack,$excaped_domain$excaped_path/[%w-.]*/[%w-.]*/git%-upload%-pack,$excaped_domain$excaped_path/[%w-.]*/[%w-.]*/info/refs"
    fi
}
