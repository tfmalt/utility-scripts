#
# A function for defining setuptypes according to criteria
#

setuptype() {
    if (( $EUID == 0 )); then
        echo "root"
        return
    fi
    if [[ $(uname) == "Linux" ]]; then
        if [[ $(dmesg | grep "Booting paravirtualized kernel on bare hardware") ]]; then
            echo "linux-server"
            return
        elif [[ $(dmesg | grep "Booting paravirtualized kernel") ]]; then
	    echo "linux-virtual"
	    return
        elif [[ $(dmesg | grep "Raspberry Pi") ]]; then
            echo "linux-rpi"
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
