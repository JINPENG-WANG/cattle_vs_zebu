#!/usr/bin/perl -w
use strict;
use IO::File;
my @xpehhs=<*.xpehh>;
my $high = 3.5;
my $low = 1.5;
my %xpehh;
for my $xpehh(@xpehhs) {
	my $fh_in = IO::File->new("$xpehh",'r');
	my $line_count=-1;
	while(<$fh_in>){
		chomp;
		my $line = $_;
		$line_count++;
		if($line_count>0){
			my @eles = split /\s+/, $line;
			my ($chr, $pos, $std_XPEHH, $comp)=@eles[1,2,8,9];
			$xpehh{$comp}{$chr}{$line_count}{pos}=$pos;
			$xpehh{$comp}{$chr}{$line_count}{xpehh}=$std_XPEHH;
		}
	}
}

	

for my $comp (keys %xpehh) {
	my %merged_window;
	my $fh_out = IO::File->new(">$comp.filter.xpehh.txt");

	for my $chr (sort {$a<=>$b} keys %{$xpehh{$comp}} ) {
		
		for my $window_count(sort {$a<=>$b} keys %{$xpehh{$comp}{$chr}}) {

			my $xpehh=$xpehh{$comp}{$chr}{$window_count}{xpehh};

			# Values bigger than 4.5
			if( $xpehh>$high){
				my $pos = $xpehh{$comp}{$chr}{$window_count}{pos};
				my @pos;
				my @xpehh;
				push @pos, $pos;
				push @xpehh, $xpehh;
				my $forward=1;
				my $backward=1;
				my $backward_count=$window_count;
				my $forward_count=$window_count;
				while($backward){
					$backward_count--;
					if(exists $xpehh{$comp}{$chr}{$backward_count}){
						my $backward_xpehh=$xpehh{$comp}{$chr}{$backward_count}{xpehh};
						if($backward_xpehh>$low){
							my $backward_pos=$xpehh{$comp}{$chr}{$backward_count}{pos};
							
							push @pos, $backward_pos;
							push @xpehh, $backward_xpehh;
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
					if(exists $xpehh{$comp}{$chr}{$forward_count}){
						my $forward_xpehh=$xpehh{$comp}{$chr}{$forward_count}{xpehh};
						if($forward_xpehh>$low){
							my $forward_pos = $xpehh{$comp}{$chr}{$forward_count}{pos};
							push @pos, $forward_pos;
							push @xpehh, $forward_xpehh;
						}
						else{
							$forward=0;
						}
					}else{
						$forward=0;
					}
				}
				@pos = sort @pos;
				@xpehh = sort @xpehh;
				
				my $merge_start = $pos[0];
				my $merge_stop = $pos[$#pos];
				my $max_xpehh = $xpehh[$#xpehh];

				if(exists $merged_window{$chr}{$merge_start}){
					my $previous_xpehh=$merged_window{$chr}{$merge_start}{xpehh};
					if($max_xpehh > $previous_xpehh){
						$merged_window{$chr}{$merge_start}{xpehh}=$max_xpehh;
					}
				}else{
					$merged_window{$chr}{$merge_start}{start}=$merge_start;
					$merged_window{$chr}{$merge_start}{stop}=$merge_stop;
					$merged_window{$chr}{$merge_start}{xpehh}=$max_xpehh;
				}
			}

			#Values smaller than -4.5
			if( $xpehh<-$high){
				my $pos = $xpehh{$comp}{$chr}{$window_count}{pos};
				my @pos;
				my @xpehh;
				push @pos, $pos;
				push @xpehh, $xpehh;
				my $forward=1;
				my $backward=1;
				my $backward_count=$window_count;
				my $forward_count=$window_count;
				while($backward){
					$backward_count--;
					if(exists $xpehh{$comp}{$chr}{$backward_count}){
						my $backward_xpehh=$xpehh{$comp}{$chr}{$backward_count}{xpehh};
						if($backward_xpehh<-$low){
							my $backward_pos=$xpehh{$comp}{$chr}{$backward_count}{pos};
							
							push @pos, $backward_pos;
							push @xpehh, $backward_xpehh;
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
					if(exists $xpehh{$comp}{$chr}{$forward_count}){
						my $forward_xpehh=$xpehh{$comp}{$chr}{$forward_count}{xpehh};
						if($forward_xpehh<-$low){
							my $forward_pos = $xpehh{$comp}{$chr}{$forward_count}{pos};
							push @pos, $forward_pos;
							push @xpehh, $forward_xpehh;
						}
						else{
							$forward=0;
						}
					}else{
						$forward=0;
					}
				}
				@pos = sort @pos;
				@xpehh = sort @xpehh;
				
				my $merge_start = $pos[0];
				my $merge_stop = $pos[$#pos];
				my $max_xpehh = $xpehh[$#xpehh];

				if(exists $merged_window{$chr}{$merge_start}){
					my $previous_xpehh=$merged_window{$chr}{$merge_start}{xpehh};
					if($max_xpehh > $previous_xpehh){
						$merged_window{$chr}{$merge_start}{xpehh}=$max_xpehh;
					}
				}else{
					$merged_window{$chr}{$merge_start}{start}=$merge_start;
					$merged_window{$chr}{$merge_start}{stop}=$merge_stop;
					$merged_window{$chr}{$merge_start}{xpehh}=$max_xpehh;
				}
			}
		}
	}
	for  my $chr (sort {$a<=>$b} keys %merged_window) {
		for my $start (sort {$a<=>$b} keys %{$merged_window{$chr}}) {
			my $stop = $merged_window{$chr}{$start}{stop};
			my $xpehh=$merged_window{$chr}{$start}{xpehh};
			my $window_size = $stop-$start+1;
			$fh_out->print("$chr\t$start\t$stop\t$window_size\t$xpehh\n");
		}
	}
}
