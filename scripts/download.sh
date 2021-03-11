#!/bin/bash
set -e
set -o pipefail


error_msg(){
    local msg=$1
    local no_usage=$2
    echo -e "[ERROR] $msg"
    [[ -z $no_usage ]] && usage
    export DEBUG=1
    exit 1
}


log_msg(){
    local msg=$1
    echo -e "[LOG] $(date) # $msg"
}


download_zips(){
    declare -a urls=(${_GITHUB_URLS[@]})
    for url in "${urls[@]}"; do
        declare -a url_array=($(echo $url | tr "/" " "))
        local github_owner=${url_array[2]}
        local github_repo=${url_array[3]}
        local release_version=${url_array[5]//.zip/}
        log_msg "Downloading ${github_owner}/${github_repo} $release_version ..."
        curl -sL -o "${github_repo}-${release_version}.zip" "$url"
        log_msg "Successfully downloaded ${github_owner}/${github_repo} $release_version"
    done
    wait
}


unzip_zip_files(){
    declare -a urls=(${_GITHUB_URLS[@]})
    for url in "${urls[@]}"; do
        declare -a url_array=($(echo $url | tr "/" " "))
        local github_owner=${url_array[2]}
        local github_repo=${url_array[3]}
        local release_version=${url_array[5]//.zip/}
        local zip_filepath="${github_repo}-${release_version}.zip"
        log_msg "Unzipping ${zip_filepath} ..."
        unzip -qq "$zip_filepath"
        rm "$zip_filepath"
        log_msg "Successfully unzipped ${zip_filepath} to $(ls ${github_repo}*)"
    done
    wait
}


# main
_GITHUB_URLS=("$@")
download_zips "${_GITHUB_URLS[@]}"
unzip_zip_files "${_GITHUB_URLS[@]}"
