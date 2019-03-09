#
# A function for printing 256 colors in a pretty way.
#
# @author Thomas Malt <thomas@malt.no>
#


colorlist() {
    local BLOCK
    BLOCK=$(echo -e "\xE2\x96\x88")
    for code in {0..255}; do 
        printf "\e[38;05;${code}m"
        printf "$BLOCK%.0s" {1..4} 
        printf " %3s " $code;

        if (( $code < 16 )); then
            (( $code>0 && ($code+1)%8 == 0 )) && echo ""
            (( $code == 15 )) && echo ""
        elif (( $code > 231 )); then
            (( ($code-231)%8 == 0 )) && echo ""
        else
            (( ($code-15)%6 == 0 ))  && echo ""
            (( ($code-15)%36 == 0 )) && echo ""
        fi
    done
    echo ""
}

