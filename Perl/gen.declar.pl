#!/usr/bin/perl

# TODO: 
# 1.bool 型函数用 Is 开头
# 2.CString 传引用

open(IN, "<" , "./ItBase.h.edit.h");

$text;

while( <IN> )
{
	if ($_ =~ /^[\s|\/]/)
	{
		next;
	}

	$_ =~ /^[^\/].*;/;

    @sym = split(/\s/, $&);

    print @sym[0]."\n";
    print @sym[1]."\n";

	@sym[1] =~ s/[;,]//;

	$funcName = @sym[1];
	$funcName =~ /^[a-z|_]*/;
	$funcName = $';

	$line = @sym[0]." Get".$funcName."() const;\n";
	$text = $text.$line;

	# $line = "\treturn m_cfgData.".@sym[1].";\n";
	# $text = $text.$line."}\n";

	$varLName = @sym[1];
	$varLName =~ /^[a-z]_/;
	$varLName = $';

	$line = "void Set".$funcName."(".$sym[0]." ".$varLName.");\n";
	$text = $text.$line;

	# $text = $text."\tassertWriteEnabled();\n";

	# $line = "\tm_cfgData.".@sym[1]." = ".$varLName.";\n";
	# $text = $text.$line."}\n";

	$text = $text."\n";
}

print "中文";

close(IN);

open(OUT, ">" , "./getterSetter.h" );
print OUT $text;
close(OUT)
