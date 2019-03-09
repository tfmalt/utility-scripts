# 
# A function for pretty printing the terminal window size currently
#
termsize() {
	echo "Size: $COLUMNS x $LINES"
	perl -e 'print "1--------|", "---------|" x 6, "--------80\n";'
	return 
}
