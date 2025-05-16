#=================================================
# SET ALL CONSTANTS
#=================================================

systemd_match_start_line='Starting new Web server: tcp:127.0.0.1:'
ssh_port="$(yunohost settings get security.ssh.ssh_port)"

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

_set_permissions() {
    chown -R "$app:$app" "$install_dir"
    chmod -R u=rwX,g=rX,o= "$install_dir"
    chmod +x "$install_dir/gitea"

    chown -R "$app:$app" "$data_dir"
    chmod u=rwx,g=rx,o= "$data_dir"
    find "$data_dir" \(   \! -perm -o= \
                     -o \! -user "$app" \
                     -o \! -group "$app" \) \
                   -exec chown "$app:$app" {} \; \
                   -exec chmod u=rwX,g=rX,o= {} \;
    chmod -R u=rwX,g=,o= "$data_dir/.ssh"
}

set_settings_default() {
    ynh_app_setting_set_default --key=internal_token --value="$(ynh_exec_as_app "$install_dir/gitea" generate secret INTERNAL_TOKEN)"
    ynh_app_setting_set_default --key=secret_key --value="$(ynh_exec_as_app "$install_dir/gitea" generate secret SECRET_KEY)"
    ynh_app_setting_set_default --key=lfs_jwt_secret --value="$(ynh_exec_as_app "$install_dir/gitea" generate secret JWT_SECRET)"
    ynh_app_setting_set_default --key=jwt_secret --value="$(ynh_exec_as_app "$install_dir/gitea" generate secret JWT_SECRET)"

    ynh_app_setting_set_default --key=require_signin_view --value=false
    ynh_app_setting_set_default --key=disable_users_page --value=false
    ynh_app_setting_set_default --key=disable_organizations_page --value=false
    ynh_app_setting_set_default --key=disable_code_page --value=false

    ynh_app_setting_set_default --key=show_user_email --value=true
    ynh_app_setting_set_default --key=default_keep_email_private --value=false

    ynh_app_setting_set_default --key=repos_indexer_enabled --value=false
}
