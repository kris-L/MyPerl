
#!/usr/bin/perl
##
##  Define packages being used
##
use strict;
use Cwd;

my @fileList;
my $arrayLength;

my $count          = 0;
my $RSSIFailCount  = 0;
my $rssiValue      = 0;
my $totalFail      = 0;
my $failData       = "";
my $failDUTRX0_37  = 0;
my $failDUTRX23_37 = 0;
my $failDUTRX0_17  = 0;
my $failDUTRX23_17 = 0;
my $failDUTRX0_39  = 0;
my $failDUTRX23_39 = 0;

my $failDUTTX0_37 = 0;
my $failDUTTX6_37 = 0;
my $failDUTTX0_17 = 0;
my $failDUTTX6_17 = 0;
my $failDUTTX0_39 = 0;
my $failDUTTX6_39 = 0;

my $dutRX0_37  = qr/DUT_RX 0dBm CH:37.+:/;
my $dutRX23_37 = qr/DUT_RX -23dBm CH:37.+:/;
my $dutRX0_17  = qr/DUT_RX 0dBm CH:17.+:/;
my $dutRX23_17 = qr/DUT_RX -23dBm CH:17.+:/;
my $dutRX0_39  = qr/DUT_RX 0dBm CH:39.+:/;
my $dutRX23_39 = qr/DUT_RX -23dBm CH:39.+:/;

my $dutTX0_37 = qr/DUT_TX 0dBm CH:37.+:/;
my $dutTX6_37 = qr/DUT_TX -6dBm CH:37.+:/;
my $dutTX0_17 = qr/DUT_TX 0dBm CH:17.+:/;
my $dutTX6_17 = qr/DUT_TX -6dBm CH:17.+:/;
my $dutTX0_39 = qr/DUT_TX 0dBm CH:39.+:/;
my $dutTX6_39 = qr/DUT_TX -6dBm CH:39.+:/;

#Access to the software's path
my $dir = getcwd();

my $moduleType = "0";

printf
  "请选择分析模块的类型：1、BC05ROM，2、BC8610ROM，3、CC2541\n";
printf "输入对应的数字按回车键确认。\n";

my $moduleTypeKey = <>;
chomp($moduleTypeKey);

if ( $moduleTypeKey == 1 ) {
	$moduleType = "BC05ROM";
	analysisModuleLogFile($moduleTypeKey);
}
elsif ( $moduleTypeKey == 2 ) {
	$moduleType = "BC8610";
	analysisModuleLogFile($moduleTypeKey);
}
elsif ( $moduleTypeKey == 3 ) {
	analysisBLELogFile();
}

#/****************************************************************************
#NAME
#    analysisModuleLogFile
#DESCRIPTION
#    Find records beyond the standard value,And write analysisResult. TXT file.
#RETURNS
#    void
sub analysisModuleLogFile {
	my $moduleTypeKey   = shift;
	my $rssi_1          = 0;
	my $rssi_2          = 0;
	my $FailCountRSSI_1 = 0;
	my $FailCountRSSI_2 = 0;

	my $bc05ROM_lowlimit1 = 100;
	my $bc05ROM_lowlimit2 = 80;
	my $bc8610_lowlimit1  = 65;
	my $bc8610_lowlimit2  = 50;
	my $lowlimit_rssi_1   = 0;
	my $lowlimit_rssi_2   = 0;
	my $regexp_power;

	my $regexp_bc05rom = qr/.+BC5MMRPA POWER test/;
	my $regexp_bc8610  = qr/.+BC8610 POWER test/;
	my $regexp_okAddr  = qr/.+OK-BDADDR/;
	my $totalOKAddr    = 0;

	if ( $moduleTypeKey == 1 ) {
		$lowlimit_rssi_1 = $bc05ROM_lowlimit1;
		$lowlimit_rssi_2 = $bc05ROM_lowlimit2;
		$regexp_power    = $regexp_bc05rom;
	}
	if ( $moduleTypeKey == 2 ) {
		$lowlimit_rssi_1 = $bc8610_lowlimit1;
		$lowlimit_rssi_2 = $bc8610_lowlimit2;
		$regexp_power    = $regexp_bc8610;
	}

	opendir( DIR, $dir );
	while ( my $file = readdir(DIR) ) {
		@fileList = readdir(DIR);
		@fileList = grep { /\.txt/ } @fileList;
	}
	closedir(DIR);

	$arrayLength = @fileList;
	$count       = 0;
	while ( $count < $arrayLength ) {

		open( LOGFILE, $fileList[$count] );
		while (<LOGFILE>) {
			my ($DUTLog) = $_;
			if ( $DUTLog =~ /$regexp_power.+RSSI_1=(\d+).+RSSI_2=(\d+)/ ) {
				$rssi_1 = $1;
				$rssi_2 = $2;
			}

			#	  printf"rssi_1 = $rssi_1    rssi_2 = $rssi_2\n";
			if ( ( $rssi_1 < $lowlimit_rssi_1 ) && ( $rssi_1 > 0 ) ) {
				$FailCountRSSI_1++;
				$failData = " RSSI_1=$rssi_1";
				print "FailCountRSSI_1=$FailCountRSSI_1\n";
			}
			if ( ( $rssi_2 < $lowlimit_rssi_2 ) && ( $rssi_2 > 0 ) ) {
				$FailCountRSSI_2++;
				$failData = $failData . " RSSI_2=$rssi_2";
			}
			if ( $DUTLog =~ /$regexp_okAddr/ ) {
				$totalOKAddr++;
			}

   #printf"FailCountRSSI_1=$FailCountRSSI_1,FailCountRSSI_2=$FailCountRSSI_2\n";
			if ( ( $FailCountRSSI_1 > 0 ) || ( $FailCountRSSI_2 > 0 ) ) {

				#	print"RSSIFailCount=$RSSIFailCount\n";
				open( ANALYSIS, ">>analysisResult.txt" );
				print ANALYSIS "FailFileName=$fileList[$count]";
				print ANALYSIS "$failData FAIL\n";
				close(ANALYSIS);
				$totalFail++;
			}
			$rssi_1   = 0;
			$rssi_2   = 0;
			$failData = "";

			$FailCountRSSI_1 = 0;
			$FailCountRSSI_2 = 0;
		}
		$count++;
	}
	open( ANALYSIS, ">>analysisResult.txt" );
	print ANALYSIS "FailTotal = $totalFail\n";
	print ANALYSIS "totalOKAddr = $totalOKAddr\n";
	close(ANALYSIS);

}

#/****************************************************************************
#NAME
#    analysisBLELogFile
#DESCRIPTION
#    Find records beyond the standard value,And write analysisResult. TXT file.
#RETURNS
#    void
sub analysisBLELogFile {

	opendir( DIR, $dir );
	while ( my $file = readdir(DIR) ) {
		@fileList = readdir(DIR);
		@fileList = grep { /\.lgf/ } @fileList;
	}
	closedir(DIR);

	$arrayLength = @fileList;
	$count       = 0;
	while ( $count < $arrayLength ) {

		open( LOGFILE, $fileList[$count] );

		while (<LOGFILE>) {
			my ($DUTLog) = $_;

			#matching DUT_RX RSSI
			($rssiValue) = ( $DUTLog =~ /$dutRX0_37.(.{5})/ );
			if ( $rssiValue > 38 ) {
				$RSSIFailCount++;
				$failDUTRX0_37++;
				$failData = "  DUTRX0_37=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutRX23_37.(.{5})/ );
			if ( $rssiValue > 63 ) {
				$RSSIFailCount++;
				$failDUTRX23_37++;
				$failData = $failData . "  DUTRX-23_37=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutRX0_17.(.{5})/ );
			if ( $rssiValue > 36 ) {
				$RSSIFailCount++;
				$failDUTRX0_17++;
				$failData = $failData . "  DUTRX0_17=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutRX23_17.(.{5})/ );
			if ( $rssiValue > 60 ) {
				$RSSIFailCount++;
				$failDUTRX23_17++;
				$failData = $failData . "  DUTRX-23_17=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutRX0_39.(.{5})/ );
			if ( $rssiValue > 38 ) {
				$RSSIFailCount++;
				$failDUTRX0_39++;
				$failData = $failData . "  DUTRX0_39=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutRX23_39.(.{5})/ );
			if ( $rssiValue > 61 ) {
				$RSSIFailCount++;
				$failDUTRX23_39++;
				$failData = $failData . "  DUTRX-23_39=$rssiValue";
			}

			#matching DUT_TX RSSI
			($rssiValue) = ( $DUTLog =~ /$dutTX0_37.(.{5})/ );
			if ( $rssiValue > 42 ) {
				$RSSIFailCount++;
				$failDUTTX0_37++;
				$failData = $failData . "  DUTTX0_37=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutTX6_37.(.{5})/ );
			if ( $rssiValue > 49 ) {
				$RSSIFailCount++;
				$failDUTTX6_37++;
				$failData = $failData . "  DUTTX-6_37=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutTX0_17.(.{5})/ );
			if ( $rssiValue > 40 ) {
				$RSSIFailCount++;
				$failDUTTX0_17++;
				$failData = $failData . "  DUTTX0_17=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutTX6_17.(.{5})/ );
			if ( $rssiValue > 46 ) {
				$RSSIFailCount++;
				$failDUTTX6_17++;
				$failData = $failData . "  DUTTX-6_17=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutTX0_39.(.{5})/ );
			if ( $rssiValue > 42 ) {
				$RSSIFailCount++;
				$failDUTTX0_39++;
				$failData = $failData . "  DUTTX0_39=$rssiValue";
			}
			($rssiValue) = ( $DUTLog =~ /$dutTX6_39.(.{5})/ );
			if ( $rssiValue > 48 ) {
				$RSSIFailCount++;
				$failDUTTX6_39++;
				$failData = $failData . "  DUTTX-6_39=$rssiValue";
			}

		}
		close(LOGFILE);

		if ( $RSSIFailCount > 0 ) {

			#	print"RSSIFailCount=$RSSIFailCount\n";
			open( ANALYSIS, ">>analysisResult.txt" );
			print ANALYSIS "FailFileName=$fileList[$count]";
			print ANALYSIS "$failData\n";
			close(ANALYSIS);
			$totalFail++;
		}

		$failData = "";
		$count++;
		$RSSIFailCount = 0;
	}

	open( ANALYSIS, ">>analysisResult.txt" );
	print ANALYSIS "failDUTRX0_37 = $failDUTRX0_37\n";
	print ANALYSIS "failDUTRX-23_37 = $failDUTRX23_37\n";
	print ANALYSIS "failDUTRX0_17 = $failDUTRX0_17\n";
	print ANALYSIS "failDUTRX-23_17 = $failDUTRX23_17\n";
	print ANALYSIS "failDUTRX0_39 = $failDUTRX0_39\n";
	print ANALYSIS "failDUTRX-23_39 = $failDUTRX23_39\n";
	print ANALYSIS "failDUTTX0_37 = $failDUTTX0_37\n";
	print ANALYSIS "failDUTTX-6_37 = $failDUTTX6_37\n";
	print ANALYSIS "failDUTTX0_17 = $failDUTTX0_17\n";
	print ANALYSIS "failDUTTX-6_17 = $failDUTTX6_17\n";
	print ANALYSIS "failDUTTX0_39 = $failDUTTX0_39\n";
	print ANALYSIS "failDUTTX-6_39 = $failDUTTX6_39\n";
	print ANALYSIS "FailTotal = $totalFail\n\n\n\n";
	close(ANALYSIS);

}
