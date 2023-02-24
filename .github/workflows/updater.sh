#!/bin/bash

#=================================================
# PACKAGE UPDATING HELPER
#=================================================

# This script is meant to be run by GitHub Actions
# The YunoHost-Apps organisation offers a template Action to run this script periodically
# Since each app is different, maintainers can adapt its contents so as to perform
# automatic actions when a new upstream release is detected.

update_source_file() {
  # Rewrite source file
  sed -i "s@SOURCE_URL=.*@SOURCE_URL=$asset_url@" "$path"
  sed -i "s@SOURCE_SUM=.*@SOURCE_SUM=$checksum@" "$path"
  echo "... $path"
}


# if the armv7 source file has not been updated, fill it with the armv6 info
# it's to patch the lack of armv7 build due to a bug

patch_source_file() {
  local patch_from_path=$1
  local patch_to_path=$2

  # if it's different from the new version available, patch the file
  echo "Patching '$patch_to_path' with '$patch_from_path'."
  path="$patch_to_path"
  asset_url="$(grep -Eo 'SOURCE_URL=.*' "$patch_from_path" | cut -d'=' -f2)"
  checksum="$(grep -Eo 'SOURCE_SUM=.*' "$patch_from_path" | cut -d'=' -f2)"
  update_source_file
  echo "Patching done."
}

#=================================================
# FETCHING LATEST RELEASE AND ITS ASSETS
#=================================================

# Fetching information
current_version=$(jq -j '.version|split("~")[0]' manifest.json)
repo=$(jq -j '.upstream.code|split("https://github.com/")[1]' manifest.json)
# Some jq magic is needed, because the latest upstream release is not always the latest version (e.g. security patches for older versions)
version=$(curl --silent "https://api.github.com/repos/$repo/releases" | jq -r '.[] | select( .prerelease != true ) | .tag_name' | sort -V | tail -1)
assets=($(curl --silent "https://api.github.com/repos/$repo/releases" | jq -r '[ .[] | select(.tag_name=="'"$version"'").assets[].browser_download_url ] | join(" ") | @sh' | tr -d "'"))

# Later down the script, we assume the version has only digits and dots
# Sometimes the release name starts with a "v", so let's filter it out.
# You may need more tweaks here if the upstream repository has different naming conventions. 
if [[ ${version:0:1} == "v" || ${version:0:1} == "V" ]]; then
    version=${version:1}
fi

# Setting up the environment variables
echo "Current version: $current_version"
echo "Latest release from upstream: $version"
{ echo "VERSION=$version"; echo "REPO=$repo"; } >> "$GITHUB_ENV"
# For the time being, let's assume the script will fail
echo "PROCEED=false" >> "$GITHUB_ENV"

# Proceed only if the retrieved version is greater than the current one
if ! dpkg --compare-versions "$current_version" "lt" "$version" ; then
    echo "::warning ::No new version available"
    exit 0
# Proceed only if the retrieved version is not a release candidate
elif [[ "$version" == *"rc"* ]] ; then
    echo "::warning ::No new stable version available (there is a release candidate)"
    exit 0
# Proceed only if a PR for this new version does not already exist
elif git ls-remote -q --exit-code --heads https://github.com/"$GITHUB_REPOSITORY".git ci-auto-update-v"$version" ; then
    echo "::warning ::A branch already exists for this update"
    exit 0
fi

# Each release can hold multiple assets (e.g. binaries for different architectures, source code, etc.)
echo "${#assets[@]} available asset(s)"

#=================================================
# UPDATE SOURCE FILES
#=================================================

# Here we use the $assets variable to get the resources published in the upstream release.
# Here is an example for Grav, it has to be adapted in accordance with how the upstream releases look like.

# Create the temporary directory
tempdir="$(mktemp -d)"

echo "First loop for processing checksum files..."

# Let's loop over the array of assets URLs
for asset_url in "${assets[@]}"; do

echo "Handling asset at $asset_url"

case $asset_url in
  # ignore irrelevant stuff
  *".asc"* | *".xz"* | *".exe"* | *"src"* | *".tar.gz"* | *"freebsd"* | *"darwin"*)
    ;;
  *".sha256")
    echo "Downloading checksum file at" "${asset_url##*/}"
    filename=${asset_url##*/}
    curl --silent -4 -L "$asset_url" -o "$tempdir/$filename"
    ;;
esac

done

echo "Checksums acquired."

echo "Second loop for processing source files..."

# Let's loop over the array of assets URLs
for asset_url in "${assets[@]}"; do

echo "Handling asset at $asset_url"

# Assign the asset to a source file in conf/ directory
# Here we base the source file name upon a unique keyword in the assets url (admin vs. update)
# Leave $src empty to ignore the asset
case $asset_url in
  *"linux-386")
    src="i386"
    ;;
  *"linux-amd64")
    src="x86-64"
    ;;
  *"linux-arm64")
    src="arm64"
    ;;
  *"linux-arm-6")
    src="arm"
    ;;
  *"linux-arm-7")
    src="armv7"
    ;;
  *)
    src=""
    ;;
esac

# If $src is not empty, let's process the asset
if [ -n "$src" ]; then

# Get checksum
filename=${asset_url##*/}
checksum=$(< "$tempdir/$filename.sha256" awk '{print $1;}')

path="conf/source/$src.src"

update_source_file

else
echo "... asset ignored"
fi

done

echo "Upgrade done."


# retrieving the actual version in the config file
patch_version="$(grep -Eo 'SOURCE_URL=.*' conf/source/armv7.src | cut -d'v' -f2 | cut -d'/' -f1)"
if [ "$version" != "$patch_version" ]; then
  patch_source_file "conf/source/arm.src" "conf/source/armv7.src"
fi


last_main_version="${current_version%.*}"
main_version="${version%.*}"

if [ "$last_main_version" != "$main_version" ]; then

  echo "Minor or major version number increased, creating migration stuff:"

  for i in arm arm64 armv7 i386 x86-64
  do

    path="conf/source/${i}_${last_main_version}.src"
    cp conf/source/"$i".src "$path"

    # retrieve the last minor release of the main version
    last_main_version_full=$(curl --silent "https://api.github.com/repos/$repo/releases" | jq -r '.[] | select( .prerelease != true ) | .tag_name' | sort -V | grep "$last_main_version" | tail -1 | cut -c2-)

    # set the checksum file link
    if [ "$i" = "arm" ]; then
      asset_url="https://github.com/$repo/releases/download/v$last_main_version_full/gitea-$last_main_version_full-linux-arm-6"
    elif [ "$i" = "armv7" ]; then
      asset_url="https://github.com/$repo/releases/download/v$last_main_version_full/gitea-$last_main_version_full-linux-arm-7"
    elif [ "$i" = "arm64" ]; then
      asset_url="https://github.com/$repo/releases/download/v$last_main_version_full/gitea-$last_main_version_full-linux-arm64"
    elif [ "$i" = "i386" ]; then
      asset_url="https://github.com/$repo/releases/download/v$last_main_version_full/gitea-$last_main_version_full-linux-386"
    elif [ "$i" = "x86-64" ]; then
      asset_url="https://github.com/$repo/releases/download/v$last_main_version_full/gitea-$last_main_version_full-linux-amd64"
    fi

    # downloading the checksum
    echo "Downloading checksum file at" "$asset_url.sha256"
    checksum=$(curl --silent -4 -L "$asset_url.sha256" | awk '{print $1;}')

    update_source_file

  done

  # retrieving the actual version in the config file
  patch_version="$(grep -Eo 'SOURCE_URL=.*' "conf/source/armv7_${last_main_version}.src" | cut -d'v' -f2 | cut -d'/' -f1)"
  if [ "$version" != "$patch_version" ]; then
    patch_source_file "conf/source/arm_${last_main_version}.src" "conf/source/armv7_${last_main_version}.src"
  fi

  echo "Creation of source files for migration completed"

fi


#=================================================
# SPECIFIC UPDATE STEPS
#=================================================

# Any action on the app's source code can be done.
# The GitHub Action workflow takes care of committing all changes after this script ends.

#         WE need to add this
#         "1.7."* )
#             ynh_setup_source $final_path source/${architecture}_1.8
#             restart_gitea
#         ;&
#         esac

if [ "$last_main_version" != "$main_version" ]; then

  echo "Creating the migration steps in the upgrade file"

  last_last_version=$(grep 'ynh_setup_source $final_path source/${architecture}_' scripts/upgrade | tail -n1 | grep -Eo '[[:alnum:]]+\.[[:alnum:]]+$')
  perl -0777 -pe "s@restart_gitea\n;&\nesac@restart_gitea\n;&\n\"${last_last_version}."'"* )\n    ynh_setup_source \$final_path source/\${architecture}_'"${main_version}\n    restart_gitea\n;&\nesac@" scripts/upgrade > "$tempdir"/upgrade
  mv "$tempdir"/upgrade scripts/upgrade

  echo "Migration stuff is done."

fi

#=================================================
# GENERIC FINALIZATION
#=================================================

# Delete temporary directory
rm -rf "$tempdir"

# Replace new version in manifest
echo "$(jq -s --indent 4 ".[] | .version = \"$version~ynh1\"" manifest.json)" > manifest.json

# No need to update the README, yunohost-bot takes care of it

echo "End of script."

# The Action will proceed only if the PROCEED environment variable is set to true
echo "PROCEED=true" >> "$GITHUB_ENV"
exit 0
