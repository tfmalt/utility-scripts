#
# A function for defining setuptypes according to criteria
#

setuptype() {
    if (( $EUID == 0 )); then
        echo "root"
        return
    fi

    echo "laptop"
}
