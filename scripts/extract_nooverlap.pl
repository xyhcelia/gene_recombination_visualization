#!/usr/bin/perl
use strict;

system("cat $ARGV[1]|awk '{print \$1\"\t\"\$2-1\"\t\"\$3\"\t\"\$4;}'| bedtools intersect -a $ARGV[0] -b - -v|awk '{print \$1\"\t\"\$2+1\"\t\"\$3\"\t\"\$4;}'");
system("cat $ARGV[1]|awk '{print \$1\"\t\"\$2-1\"\t\"\$3\"\t\"\$4;}'|bedtools intersect -a $ARGV[0] -b - -wo |awk '{print \$1\"\t\"\$2+1\"\t\"\$3\"\t\"\$4\"\t\"\$5\"\t\"\$6+1\"\t\"\$7\"\t\"\$8;}'|sort -k1,1 -k2,2n -k5,5 -k6,6n >$ARGV[0]_$ARGV[1].overlap");

open IN,"<$ARGV[0]_$ARGV[1].overlap";
my $gene;
my $start;
my $end;
my $type;
my @seg_start;
my @seg_end;

$_=<IN>;
chomp;
my @array=split;
$gene=$array[0];
$start=$array[1];
$end=$array[2];
$type=$array[3];
push(@seg_start,$array[5]);
push(@seg_end,$array[6]);

while(<IN>){
    chomp;
    my @array=split;
    if($array[0] eq $gene && $array[1] eq $start && $array[2] eq $end){
          push(@seg_start,$array[5]);
          push(@seg_end,$array[6]);
    }else{
          print $gene,"\t",$start,"\t",$seg_start[0]-1,"\t",$type,"\n";
          my $n=@seg_end;
          foreach my $i(0..$n-2){
              print $gene,"\t",$seg_end[$i]+1,"\t",$seg_start[$i+1]-1,"\t",$type,"\n";
          }
          print $gene,"\t",$seg_end[-1]+1,"\t",$end,"\t",$type,"\n";
          $gene=$array[0];
          $start=$array[1];
          $end=$array[2];
          $type=$array[3];
          undef  @seg_start;
          undef  @seg_end;
          push(@seg_start,$array[5]);
          push(@seg_end,$array[6]);
    }
}
print $gene,"\t",$start,"\t",$seg_start[0]-1,"\t",$type,"\n";
my $n=@seg_end;
foreach my $i(0..$n-2){
    print $gene,"\t",$seg_end[$i]+1,"\t",$seg_start[$i+1]-1,"\t",$type,"\n";
}
print $gene,"\t",$seg_end[-1]+1,"\t",$end,"\t",$type,"\n";

close IN;
system("rm $ARGV[0]_$ARGV[1].overlap");
