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

#����ű��ļ���
my $oneselfFile = $0;

my $outputResultFile = "analysisResult.txt";

my $inputType = "0";
main();

sub main {

	#ȥ��·�����ļ��������
	$oneselfFile =~ s/((.*\\)+)|((.*\/)+)//;

	printf"��ѡ����Ҫִ�е�����1�����ҹؼ��ʣ�2���̶��ַ������滻Ϊ�գ�3��CC2541\n";
	printf "�����Ӧ�����ְ��س���ȷ�ϡ�\n";

	my $workTypeKey = <>;
	chomp($workTypeKey);

	if ( $workTypeKey == 1 ) {
		printf "������Ҫ���ҵĹؼ���,���س���ȷ�ϡ�\n";
		my $keywordsStr = <>;
		chomp($keywordsStr);
		printf "������Ĺؼ�����:$keywordsStr\n";
		searchKeywords( $currentDir, $keywordsStr );
	}
	elsif ( $workTypeKey == 2 ) {
		#ƥ��ؼ���
		my $search_regex = qr/^\/\*.+?\*./;
		#�滻�������
		my $replaceStr = "";   
		searchReplace( $currentDir, $search_regex,$replaceStr);
	}
	elsif ( $workTypeKey == 3 ) {

	}
	
	printf "��ȷ�����˳�\n";
	$workTypeKey = <>;
	
}


#/****************************************************************************
#NAME
#    searchReplace
#DESCRIPTION
#    ����Ŀ¼��(���������ļ�)��ѯ�ؼ���,�Բ��ҵ������滻
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
					$rearchResult = $rearchResult."��"
						  . $fileName . "��"
						  . $lineCount . "��  "
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
#    ����Ŀ¼��(���������ļ�)��ѯ�ؼ���
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
	# �����ļ�,��ȡ��׺Ϊtxt��log���ļ�
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
					$rearchResult = $rearchResult."��"
						  . $fileName . "��"
						  . $lineCount . "��  "
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


#������д���ļ�
sub writeFile {
	my $msg = shift;
	open( RESULTFILE, ">>$outputResultFile" );
	print RESULTFILE "$msg";
	close(RESULTFILE);
}

