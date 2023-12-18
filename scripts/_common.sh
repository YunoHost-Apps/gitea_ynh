#=================================================
# SET ALL CONSTANTS
#=================================================

systemd_match_start_line='Starting new Web server: tcp:127.0.0.1:'
ssh_port=$(grep -P "Port\s+\d+" /etc/ssh/sshd_config | grep -P -o "\d+")

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

_set_permissions() {
    chown -R "$app:$app" "$install_dir"
    chmod -R u=rwX,g=rX,o= "$install_dir"
    chmod +x "$install_dir/gitea"

    chown -R "$app:$app" "$data_dir"
    find $data_dir \(   \! -perm u=rwX,g=rX,-o= \
                     -o \! -user $app \
                     -o \! -group $app \) \
                   -exec chown $app:$app {} \; \
                   -exec chmod u=rwX,g=rX,o= {} \;
    chmod -R u=rwX,g=,o= "$data_dir/.ssh"

    chown -R "$app:$app" "/var/log/$app"
    chmod -R u=rwX,g=rX,o= "/var/log/$app"
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

    if [[ -n "${lfs_key:-}" ]]; then
        lfs_jwt_secret="$lfs_key"
        ynh_app_setting_delete --app "$app" --key lfs_key
        ynh_app_setting_set --app "$app" --key lfs_jwt_secret --value="$lfs_jwt_secret"
    fi

    if [[ -z "${lfs_jwt_secret:-}" ]]; then
        lfs_jwt_secret=$(ynh_exec_as "$app" "$install_dir/gitea" generate secret JWT_SECRET)
        ynh_app_setting_set --app "$app" --key lfs_jwt_secret --value="$lfs_jwt_secret"
    fi
}
