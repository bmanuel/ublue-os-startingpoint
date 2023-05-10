#!/bin/bash
# run scripts
echo "-- Running scripts defined in recipe.yml --"
buildscripts=$(yq '.scripts[]' </usr/etc/ublue-recipe.yml)
for script in $(echo -e "$buildscripts"); do
    echo "Running: ${script}" &&
        /tmp/scripts/$script
done
echo "---"

repos=$(yq '.extrarepos[]' </usr/etc/ublue-recipe.yml)
if [[ -n "$repos" ]]; then
    echo "-- Adding repos defined in recipe.yml --"
    for repo in $(echo -e "$repos"); do
        wget $repo -P /etc/yum.repos.d/
    done
    echo "---"
fi

# remove the default firefox (from fedora) in favor of the flatpak
# rpm-ostree override remove firefox firefox-langpacks
rpm-ostree override remove fprintd-pam fprintd

echo "-- Installing RPMs defined in recipe.yml --"
rpm_packages=$(yq '.rpms[]' </usr/etc/ublue-recipe.yml)
for pkg in $(echo -e "$rpm_packages"); do
    echo "Installing: ${pkg}" &&
        rpm-ostree install $pkg
done
echo "---"

# Remove RPMs.
get_yaml_array remove_rpms '.rpm.remove[]'
if [[ ${#remove_rpms[@]} -gt 0 ]]; then
    echo "-- Removing RPMs defined in recipe.yml --"
    echo "Removing: ${remove_rpms[@]}"
    rpm-ostree override remove "${remove_rpms[@]}"
    echo "---"
fi

# add a package group for yafti using the packages defined in recipe.yml
flatpaks=$(yq '.flatpaks[]' </tmp/ublue-recipe.yml)
# only try to create package group if some flatpaks are defined
if [[ -n "$flatpaks" ]]; then
    yq -i '.screens.applications.values.groups.Custom.description = "Flatpaks defined by the image maintainer"' /usr/etc/yafti.yml
    yq -i '.screens.applications.values.groups.Custom.default = true' /usr/etc/yafti.yml
    for pkg in $(echo -e "$flatpaks"); do
        yq -i ".screens.applications.values.groups.Custom.packages += [{\"$pkg\": \"$pkg\"}]" /usr/etc/yafti.yml
    done
fi
