#!/usr/bin/perl -w
use strict;
use IO::File;
my @xpclrs=<*.xpclr>;
my $high = 4.5;
my $low = 2.5;
for my $xpclr(@xpclrs) {
	my $fh_in = IO::File->new("$xpclr",'r');
	my $fh_out = IO::File->new(">$xpclr.filter.txt");
	my %xpclr;
	my $line_count=-1;
	while(<$fh_in>){
		chomp;
		my $line = $_;
		$line_count++;
		if($line_count>0){
			my @eles = split /\s+/, $line;
			my $xpclr_norm;
			my $eles_num=@eles;
			my $start;
			my $stop;
			my $chr;
			if($eles_num<13){
				$chr=$eles[1];
				$start=$eles[2];
				$stop = $eles[3];
				$xpclr_norm=9999;
			}
			else{
				$chr = $eles [1];
				$start=$eles[4];
				$stop = $eles[5];
				$xpclr_norm=$eles[12];
			}
			$xpclr{$chr}{$line_count}{start}=$start;
			$xpclr{$chr}{$line_count}{stop}=$stop;
			$xpclr{$chr}{$line_count}{xpclr}=$xpclr_norm;
		}
	}
	
	my %merged_window;
	for my $chr (sort {$a<=>$b} keys %xpclr ) {
		for my $window_count(sort {$a<=>$b} keys %{$xpclr{$chr}}) {
				my $xpclr_norm=$xpclr{$chr}{$window_count}{xpclr};
				# Values bigger than 4.5
				if( $xpclr_norm !=9999 && $xpclr_norm>$high){
					my $start=$xpclr{$chr}{$window_count}{start};
					my $stop=$xpclr{$chr}{$window_count}{stop};
					my %target;
					my @starts;
					my @stops;
					push @starts, $start;
					push @stops, $stop;
					my $forward=1;
					my $backward=1;
					my $backward_count=$window_count;
					my $forward_count=$window_count;
					while($backward){
						$backward_count--;
						if(exists $xpclr{$chr}{$backward_count}){
							my $backward_xpclr=$xpclr{$chr}{$backward_count}{xpclr};
							if($backward_xpclr != 9999 && $backward_xpclr>$low){
								my $backward_start=$xpclr{$chr}{$backward_count}{start};
								my $backward_stop=$xpclr{$chr}{$backward_count}{stop};
								push @starts, $backward_start;
								push @stops, $backward_stop;
							}
							else{
								$backward=0;
							}
						}else{
							$backward=0;
						}
					}
					while($forward){
						$forward_count++;
						if(exists $xpclr{$chr}{$backward_count}){
							my $forward_xpclr=$xpclr{$chr}{$forward_count}{xpclr};
							if($forward_xpclr != 9999 &&  $forward_xpclr>$low){
								if($forward_xpclr>$xpclr_norm){
									$xpclr_norm=$forward_xpclr;
								}
								my $forward_start=$xpclr{$chr}{$forward_count}{start};
								my $forward_stop=$xpclr{$chr}{$forward_count}{stop};
								push @starts, $forward_start;
								push @stops, $forward_stop;
							}
							else{
								$forward=0;
							}
						}else{
							$forward=0;
						}
					}
					@starts = sort @starts;
					@stops = sort {$b<=>$a} @stops;
					my $merge_start = shift@starts;
					my $merge_stop = shift @stops;
					#$fh_out ->print("$chr\t$merge_start\t$merge_stop\t$xpclr_norm\n");
					if(exists $merged_window{$chr}{$merge_start}){
						my $previous_xpclr_norm=$merged_window{$chr}{$merge_start}{xpclr};
						if($xpclr_norm > $previous_xpclr_norm){
							$merged_window{$chr}{$merge_start}{xpclr}=$xpclr_norm;
						}
					}else{
						$merged_window{$chr}{$merge_start}{start}=$merge_start;
						$merged_window{$chr}{$merge_start}{stop}=$merge_stop;
						$merged_window{$chr}{$merge_start}{xpclr}=$xpclr_norm;
					}
				}

				#Values smaller than -4.5
				if( $xpclr_norm !=9999 && $xpclr_norm<-$high){
					my $start=$xpclr{$chr}{$window_count}{start};
					my $stop=$xpclr{$chr}{$window_count}{stop};
					my %target;
					my @starts;
					my @stops;
					push @starts, $start;
					push @stops, $stop;
					my $forward=1;
					my $backward=1;
					my $backward_count=$window_count;
					my $forward_count=$window_count;
					while($backward){
						$backward_count--;
						if(exists $xpclr{$chr}{$backward_count}){
							my $backward_xpclr=$xpclr{$chr}{$backward_count}{xpclr};
							if($backward_xpclr != 9999 && $backward_xpclr<-$low){
								my $backward_start=$xpclr{$chr}{$backward_count}{start};
								my $backward_stop=$xpclr{$chr}{$backward_count}{stop};
								push @starts, $backward_start;
								push @stops, $backward_stop;
							}
							else{
								$backward=0;
							}
						}else{
							$backward=0;
						}
					}
					while($forward){
						$forward_count++;
						if(exists $xpclr{$chr}{$backward_count}){
							my $forward_xpclr=$xpclr{$chr}{$forward_count}{xpclr};
							if($forward_xpclr != 9999 &&  $forward_xpclr<-$low){
								if($forward_xpclr>$xpclr_norm){
									$xpclr_norm=$forward_xpclr;
								}
								my $forward_start=$xpclr{$chr}{$forward_count}{start};
								my $forward_stop=$xpclr{$chr}{$forward_count}{stop};
								push @starts, $forward_start;
								push @stops, $forward_stop;
							}
							else{
								$forward=0;
							}
						}else{
							$forward=0;
						}
					}
					@starts = sort @starts;
					@stops = sort {$b<=>$a} @stops;
					my $merge_start = shift@starts;
					my $merge_stop = shift @stops;
					#$fh_out ->print("$chr\t$merge_start\t$merge_stop\t$xpclr_norm\n");
					if(exists $merged_window{$chr}{$merge_start}){
						my $previous_xpclr_norm=$merged_window{$chr}{$merge_start}{xpclr};
						if($xpclr_norm < $previous_xpclr_norm){
							$merged_window{$chr}{$merge_start}{xpclr}=$xpclr_norm;
						}
					}else{
						$merged_window{$chr}{$merge_start}{start}=$merge_start;
						$merged_window{$chr}{$merge_start}{stop}=$merge_stop;
						$merged_window{$chr}{$merge_start}{xpclr}=$xpclr_norm;
					}
				}
		}
	}
	for  my $chr (sort {$a<=>$b} keys %merged_window) {
		for my $start (sort {$a<=>$b} keys %{$merged_window{$chr}}) {
			my $stop = $merged_window{$chr}{$start}{stop};
			my $xpclr_norm=$merged_window{$chr}{$start}{xpclr};
			my $window_size = $stop-$start+1;
			$fh_out->print("$chr\t$start\t$stop\t$window_size\t$xpclr_norm\n");
		}
	}
}
