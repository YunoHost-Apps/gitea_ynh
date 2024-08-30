#=================================================
# SET ALL CONSTANTS
#=================================================

systemd_match_start_line='Starting new Web server: tcp:127.0.0.1:'
ssh_port="$(yunohost settings get security.ssh.ssh_port)"

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

_set_permissions() {
    #REMOVEME? Assuming the install dir is setup using ynh_setup_source, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chown -R "$app:$app" "$install_dir"
    #REMOVEME? Assuming the install dir is setup using ynh_setup_source, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chmod -R u=rwX,g=rX,o= "$install_dir"
    chmod +x "$install_dir/gitea"

    chown -R "$app:$app" "$data_dir"
    find "$data_dir" \(   \! -perm -o= \
                     -o \! -user "$app" \
                     -o \! -group "$app" \) \
                   -exec chown "$app:$app" {} \; \
                   -exec chmod u=rwX,g=rX,o= {} \;
    chmod -R u=rwX,g=,o= "$data_dir/.ssh"

    #REMOVEME? Assuming ynh_config_add_logrotate is called, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chown -R "$app:$app" "/var/log/$app"
    #REMOVEME? Assuming ynh_config_add_logrotate is called, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chmod -R u=rwX,g=rX,o= "/var/log/$app"
}
