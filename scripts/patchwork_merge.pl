#!/usr/bin/perl
use strict;

system("less $ARGV[0] |awk '{if(\$3-\$2+1>=20) print \$0;}'|sort -k1,1 -k2,2n >patchwork_merge.large");
system("less $ARGV[0] |awk '{if(\$3-\$2+1<20) print \$0;}'|sort -k1,1 -k2,2n >patchwork_merge.small");
system("bedtools closest -a patchwork_merge.small -b patchwork_merge.large |awk '{print \$0\"\t\"\$7-\$6+1;}'|sort -k1,1 -k2,2n -k9,9nr >patchwork_merge.input");

my $gene;
my $start;
my @posi;
open IN,"<patchwork_merge.input";
open OUT,">patchwork_merge.output";
while(<IN>){
    chomp;
    my @array=split;
    if($array[0] eq $gene && $array[1] eq $start){
    }else{
    undef @posi;
    @posi=($array[1],$array[2],$array[5],$array[6]);
    @posi=sort {$a<=>$b}@posi;
    print OUT "$array[0]\t$posi[0]\t$posi[-1]\t$array[7]\n";
     $gene=$array[0];
     $start=$array[1];
    }    
}
close IN;
close OUT;
system("cat patchwork_merge.large patchwork_merge.output |sort -k1,1 -k2,2n |bedtools merge -i - -c 4 -o distinct>$ARGV[1]");
system("rm patchwork_merge.large patchwork_merge.small patchwork_merge.input patchwork_merge.output");
