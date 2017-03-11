#
# A function for defining setuptypes according to criteria
#
# Copyright (c) 2012-2016 Thomas Malt <thomas@malt.no>
#
# License: MIT
#
setuptype() {
    if (( $EUID == 0 )); then
        if [[ $container == "lxc" ]]; then
          echo "lxc"
          return 
        fi

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
        elif [[ $(uname -n) == "pi" ]]; then
            echo "linux-rpi"
            export MALT_SETUPTYPE="Raspberry Pi"
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

     if [[ $(uname | grep "Darwin") ]]; then
        case $(hostname) in
            *nrk.no)
                echo "nrk-laptop"
                ;;
            wootz.malt.no)
              echo "laptop"
              ;;
        esac
        return
     fi

     echo "laptop"
}
