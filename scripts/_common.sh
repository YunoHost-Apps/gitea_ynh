#!/bin/bash

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

_gitea_mkdirs() {
    mkdir -p "$install_dir/data"
    mkdir -p "$install_dir/custom/conf"
    _gitea_permissions_install_dir

    mkdir -p "$data_dir/.ssh"
    mkdir -p "$data_dir/repositories"
    mkdir -p "$data_dir/data/avatars"
    mkdir -p "$data_dir/data/attachments"
    chown -R "$app:$app" "$data_dir"
    chmod -R u=rwX,g=rX,o= "$data_dir"
    chmod -R u=rwx,g=,o= "$data_dir/.ssh"

    mkdir -p "/var/log/$app"
    touch "/var/log/$app/gitea.log"
    chown -R "$app:$app" "/var/log/$app"
    chmod -R u=rwX,g=rX,o= "/var/log/$app"
}

_gitea_permissions_install_dir() {
    chown -R "$app:$app" "$install_dir"
    chmod -R u=rwX,g=rX,o= "$install_dir"
}

_gitea_set_secrets() {
    if [[ -z "${internal_token:-}" ]]; then
        internal_token=$(ynh_exec_as "$app" "$install_dir/gitea" generate secret INTERNAL_TOKEN)
        ynh_app_setting_set --app "$app" --key internal_token --value="$internal_token"
    fi

    if [[ -z "${secret_key:-}" ]]; then
        secret_key=$(ynh_exec_as "$app" "$install_dir/gitea" generate secret SECRET_KEY)
        ynh_app_setting_set --app "$app" --key secret_key --value="$secret_key"
    fi

    if [[ -z "${jwt_secret:-}" ]]; then
        jwt_secret=$(ynh_exec_as "$app" "$install_dir/gitea" generate secret JWT_SECRET)
        ynh_app_setting_set --app "$app" --key jwt_secret --value="$jwt_secret"
    fi

    if [[ -n "${lfs_key:-}" ]]; then
        # Migration
        lfs_jwt_secret="$lfs_key"
        ynh_app_setting_delete --app "$app" --key lfs_key
        ynh_app_setting_set --app "$app" --key lfs_jwt_secret --value="$lfs_jwt_secret"
    fi

    if [[ -z "${lfs_jwt_secret:-}" ]]; then
        lfs_jwt_secret=$(ynh_exec_as "$app" "$install_dir/gitea" generate secret JWT_SECRET)
        ynh_app_setting_set --app "$app" --key lfs_jwt_secret --value="$lfs_jwt_secret"
    fi
}

_gitea_add_config() {
    ssh_port=$(grep -P "Port\s+\d+" /etc/ssh/sshd_config | grep -P -o "\d+")
    ynh_add_config --template="app.ini" --destination="$install_dir/custom/conf/app.ini"
}
