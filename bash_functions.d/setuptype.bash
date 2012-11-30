#
# A function for defining setuptypes according to criteria
#

setuptype() {
    if (( $EUID == 0 )); then
        echo "root"
        return
    fi
    if [[ $(uname) == "Linux" ]]; then
	if [[ $(dmesg | grep "Booting paravirtualized kernel on KVM") ]]; then
		echo "linux-virtual"
		return
	fi
	case $(hostname) in
	    duro*)
		echo "linux-server"
		;;
	    *)
		echo "linux"
		;;
	esac
        return
     fi

     echo "laptop"
}
