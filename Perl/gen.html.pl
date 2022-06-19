#!/usr/bin/perl

use LWP::Simple;


open(IN, "<" , "./bookmarks_2021_12_12.html");

$text;

while( <IN> )
{
	# if ($_ =~ /^[\s|\/]/)
	# {
	# 	next;
	# }

	# $_ =~ /^[^\/].*;/;

    # @sym = split(/\s/, $&);

    # print @sym[0]."\n";
    # print @sym[1]."\n";

	# @sym[1] =~ s/[;,]//;

	# $url = @sym[1];

	$url = $_;
	$url =~ /(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:\/~\+#]*[\w\-\@?^=%&\/~\+#])?/;
	$url = $&;

	if (!$url)
	{
		$text = $text.$_;
		next;
	}

	print $url;
	print "\n";

	# Create a user agent object
	use LWP::UserAgent;
	my $ua = LWP::UserAgent->new;
	$ua->agent("MyApp/0.1 ");
	
	# Create a request
	my $req = HTTP::Request->new(GET => $url);
	# $req->content_type('application/x-www-form-urlencoded');
	# $req->content('query=libwww-perl&mode=dist');
	
	# Pass request to the user agent and get a response back
	# my $res = $ua->request($req);
	
	# # Check the outcome of the response
	# if ($res->is_success) {
	# 	# print $res->content;
	# 	# my ($title) = $res.content =~ m/>(.+)<\/title>/si;
	# 	$title = $res.content;
	# 	$title =~ m/>(.+)<\/title>/;
	# 	$title = $&;
	# 	# print $res.content;
	# 	print "\n";
	# }
	# else {
	# 	$text = $text.$_;
	# 	print $res->status_line, "\n";
	# 	next;
	# }

	# my ($title) = $res.content =~ m/<title>(.+)<\/title>/si;
	# print $res.content;
	print "\n";

	my $doc = get($url);
	# # # 获取网页内容后可以对内容进行提取或者其它处理
	# # # 将网页内容打印出来
	# print $doc;
	$title = $doc;
	$title =~ m/<title.*>(.+)<\/title>/;
	$title = $1;
	print $title;
	print "\n";
	print "\n";

	$_ =~ s/[0-9]+<\/A>/$title<\/A>/;
	$text = $text.$_;

	# open(OUT, ">" , "./getterSetter.cpp" );
	# print OUT $text;
	# close(OUT)
}

# print "中文";

close(IN);

open(OUT, ">" , "./getterSetter.cpp" );
print OUT $text;
close(OUT)
