#!/usr/bin/perl -w
use strict;
my $threshold=50000;
my ($count,$bigdir);
sub count_inodes($);
sub count_inodes($)
{
	my $dir=shift;
	return if($count>=$threshold);
	if(opendir(my $dh,$dir))
	{
		while(defined(my $file=readdir($dh)))
		{
			next if ($file eq '.'||$file eq '..');
			$count++;
			my $path=$dir.'/'.$file;
			count_inodes($path) if (-d $path);
		}
		closedir($dh);
	}else
	{
		warn "couldn't open $dir - $!\n";
	}
}

push(@ARGV, '.') unless (@ARGV);
while (@ARGV)
{
	my $main=shift;
	$main.='/' unless($main=~/\/$/);
	if(opendir(my $dh, $main))
	{
		while(defined(my $file=readdir($dh)))
		{
			$count=0;
			next if($file eq '.'||$file eq '..'||! -d $main.$file);
			count_inodes($main.$file);
			$count=">".$threshold if($count>=$threshold);
			printf "%10s\t%s\n", $count, $main.$file;
		}
		closedir($dh);
	}
	else
	{
		warn "couldn't open $main - $!\n";
	}
}
