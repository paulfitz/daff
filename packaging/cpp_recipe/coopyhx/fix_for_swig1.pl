#!/usr/bin/perl -w

use strict;

my $pending = "";

while(<>) {
    next if ($_ =~ /SWIGFIX/);
    if ($_ =~ /(.*)inline operator ::coopy::(.*)_obj \*(.*)/) {
	my $space = $1;
	my $name = $2;
	my $rest = $3;
	print "$space// hxcpp output massaged for SWIG //SWIGFIX\n";
	print "${space}inline ::hx::ObjectPtr< ::coopy::${name}_obj> as${name}${rest} //SWIGFIX\n";
	print "${space}\t{ return ::hx::ObjectPtr< ::coopy::${name}_obj>(this); } //SWIGFIX\n";
	print "#ifndef SWIG //SWIGFIX\n";
	$pending = "#endif //SWIGFIX\n";
	print $_;
    } else {
	print $_;
	print $pending;
	$pending = "";
    }
}
