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
        # Check for WSL more reliably using /proc/version
        if [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
          echo "windows"
          return
        fi

        # Try systemd-detect-virt first (more reliable and doesn't require elevated permissions)
        if command -v systemd-detect-virt >/dev/null 2>&1; then
            local virt=$(systemd-detect-virt 2>/dev/null)
            if [[ -n "$virt" && "$virt" != "none" ]]; then
                echo "linux-virtual"
                return
            fi
        fi

        # Check for Raspberry Pi
        if [[ $(uname -n) == "pi" ]] || [[ -f /proc/device-tree/model ]] && grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null; then
            echo "linux-rpi"
            export MALT_SETUPTYPE="Raspberry Pi"
            return
        fi

        # Fallback to dmesg with error handling (may require elevated permissions)
        local dmesg_output=$(dmesg 2>/dev/null)
        if [[ -n "$dmesg_output" ]]; then
            if echo "$dmesg_output" | grep -q "Booting paravirtualized kernel on bare hardware"; then
                echo "linux-server"
                return
            elif echo "$dmesg_output" | grep -q "Booting paravirtualized kernel"; then
                echo "linux-virtual"
                return
            fi
        fi

        # Use hostname-based detection as final fallback
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

     if [[ $(uname) == "Darwin" ]]; then
        case $(hostname -s) in
              *)
                echo "macbook"
              ;;
        esac
        return
     fi

     echo "laptop"
}
