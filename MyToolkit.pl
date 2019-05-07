#!/usr/bin/perl
##
##  Define packages being used
##
use strict;
use Cwd;

our $VERSION = '1.0.0';
my $arrayLength;

#Access to the software's path
my $currentDir = getcwd();

#自身脚本文件名
my $oneselfFile = $0;

my $outputResultFile = "analysisResult.txt";

my $inputType = "0";
main();

sub main {

	#去掉路径除文件名以外的
	$oneselfFile =~ s/((.*\\)+)|((.*\/)+)//;

	printf"请选择需要执行的任务：1、查找关键词，2、固定字符查找替换为空，3、CC2541\n";
	printf "输入对应的数字按回车键确认。\n";

	my $workTypeKey = <>;
	chomp($workTypeKey);

	if ( $workTypeKey == 1 ) {
		printf "请输入要查找的关键词,按回车键确认。\n";
		my $keywordsStr = <>;
		chomp($keywordsStr);
		printf "你输入的关键词是:$keywordsStr\n";
		searchKeywords( $currentDir, $keywordsStr );
	}
	elsif ( $workTypeKey == 2 ) {
		#匹配关键字
		my $search_regex = qr/^\/\*.+?\*./;
		#替换后的内容
		my $replaceStr = "";   
		searchReplace( $currentDir, $search_regex,$replaceStr);
	}
	elsif ( $workTypeKey == 3 ) {

	}
	
	printf "按确定键退出\n";
	$workTypeKey = <>;
	
}


#/****************************************************************************
#NAME
#    searchReplace
#DESCRIPTION
#    所在目录中(查找所有文件)查询关键词,对查找的内容替换
#RETURNS
#    void
#@fileList = grep { /\.txt/ } @fileList;
#/****************************************************************************
sub searchReplace {
	my $dir         = shift;
	my $keywordsStr = shift;
	my $replaceStr = shift;

	opendir( DIR, $dir );
	my @fileList;
	while ( my $file = readdir(DIR) ) {
		@fileList = readdir(DIR);
		#		print "fileList=@fileList\n";
	}
	closedir(DIR);
	my $arrayLength = @fileList;
	my $fileName;
	my $rearchResult = "";
	foreach (@fileList) {
#		print $_. "\n";
		if (   $_ eq "."
			|| $_ eq ".."
			|| $_ =~ $oneselfFile
			|| $_ =~ $outputResultFile )
		{
			next;
		}

		$fileName = $dir . "/" . $_;
		print "fileName=$fileName\n";
		if ( -f $fileName ) {
			open( DIRFILE, $fileName );
			my $allContent = "";
			my $lineCount = 1;
			my $matchSign = 0;
			while (<DIRFILE>) {
				my ($FileContent) = $_;
				my $OldFileContent = $FileContent;
				if ( $FileContent =~ s/$keywordsStr/$replaceStr/g ) {
					$rearchResult = $rearchResult."在"
						  . $fileName . "第"
						  . $lineCount . "行  "
						  . $OldFileContent;
					$matchSign = 1;
					$allContent = $allContent.$FileContent;
				}else{
					$allContent = $allContent.$FileContent;
				}
				$lineCount++;
			}
			close(DIRFILE);
			
			if($matchSign == 1)
			{
				open FILE1,">$fileName" ;
				print FILE1 $allContent;
				close FILE1;
				$matchSign = 0;
			}
			
		}
		elsif ( -d $fileName ) {
			printf "this is doc:$fileName\n";
			searchReplace( $fileName, $keywordsStr,$replaceStr);
		}
	}
	
	writeFile($rearchResult);
	
}


#/****************************************************************************
#NAME
#    searchKeywords
#DESCRIPTION
#    所在目录中(查找所有文件)查询关键词
#RETURNS
#    void
#@fileList = grep { /\.txt/ } @fileList;
#/****************************************************************************
sub searchKeywords {
	my $dir         = shift;
	my $keywordsStr = shift;
	opendir( DIR, $dir );
	my @fileList;
	while ( my $file = readdir(DIR) ) {
		@fileList = readdir(DIR);

		#		print "fileList=@fileList\n";
	}
	closedir(DIR);
	# 过滤文件,获取后缀为txt和log的文件
	# @fileList = grep { /^.+\.(txt|log)/ }@fileList;
	my $arrayLength = @fileList;
	my $fileName;
	my $rearchResult = "";
	foreach (@fileList) {
#		print $_. "\n";
		if (   $_ eq "."
			|| $_ eq ".."
			|| $_ =~ $oneselfFile
			|| $_ =~ $outputResultFile )
		{
			next;
		}

		$fileName = $dir . "/" . $_;
		print "fileName=$fileName\n";
		if ( -f $fileName ) {
			open( DIRFILE, $fileName );
			my $lineCount = 1;
			while (<DIRFILE>) {
				my ($FileContent) = $_;
				if ( $FileContent =~ $keywordsStr ) {
					$rearchResult = $rearchResult."在"
						  . $fileName . "第"
						  . $lineCount . "行  "
						  . $FileContent;
				}
				$lineCount++;
			}
			close(DIRFILE);
		}
		elsif ( -d $fileName ) {
			printf "this is doc:$fileName\n";
			searchKeywords( $fileName, $keywordsStr );
		}
	}
	writeFile($rearchResult);
}


#把内容写入文件
sub writeFile {
	my $msg = shift;
	open( RESULTFILE, ">>$outputResultFile" );
	print RESULTFILE "$msg";
	close(RESULTFILE);
}

