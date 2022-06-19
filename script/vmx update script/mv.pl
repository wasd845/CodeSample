open(IN, "<" , $ARGV[1]."/build2/config/version.mk");

$text;

while( <IN> )
{
	if(  ( $ARGV[0] eq "android" ) && /web_android-linux/ )
	{
		print "Haha";
		$text = $text."VOVMXVER ?= Verimatrix-ViewRight-Web-".$ARGV[2]."-web_android-linux/Verimatrix-ViewRight-Web-3.6.4.0-ItrA-1-web_android-linux\n";
	}
	elsif(  ( $ARGV[0] eq "ios" ) && /web_iOS/ )
	{
		$text = $text."VOVMXVER ?= Verimatrix-ViewRight-Web-".$ARGV[2]."-web_iOS\n";
	}
	elsif(  ( $ARGV[0] eq "macos" ) && /web_mac-osx/ )
	{
		$text = $text."VOVMXVER ?= Verimatrix-ViewRight-Web-".$ARGV[2]."-web_mac-osx\n";
	}
	elsif(  ( $ARGV[0] eq "win32" ) && /web_pc-win32/ )
	{
		$text = $text."VOVMXVER ?= Verimatrix-ViewRight-Web-".$ARGV[2]."-web_pc-win32\n";
	}
	elsif(  ( $ARGV[0] eq "winrt" ) && /web_stb-winrt/ )
	{
		$text = $text."VOVMXVER ?= Verimatrix-ViewRight-Web-".$ARGV[2]."-web_stb-winrt\n";
	}
	elsif(  ( $ARGV[0] eq "tvos" ) && /web_tvOS/ )
	{
		$text = $text."VOVMXVER ?= Verimatrix-ViewRight-Web-".$ARGV[2]."-web_tvOS\n";
	}
	else
	{
		$text = $text.$_;
	}
}

close(IN);

open(OUT, ">" , $ARGV[1]."/build2/config/version.mk" );
print OUT $text;
close(OUT)
