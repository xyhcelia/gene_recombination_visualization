#!/usr/bin/perl
use strict;

if(@ARGV!=3){die "Usage:perl $0 genelist gene_structure.featrue.txt patchwork.tmp2 >htmlfile\n";}
print '<svg xmlns="http://www.w3.org/2000/svg" width="3000" height="3000" >',"\n";
open IN,$ARGV[0];
my @points;
my %col;
my $y;
while(<IN>){
    chomp;
    my $id=$_;
    $y=100*$.;
    print '  <text x="1" y="',$y+12,'" fill="black" font-weight="bold" font-size="28px" font-style="italic" ">',$id,'</text>',"\n";
    system("cat $ARGV[1]|awk '{if(\$2==\"$id\") print \$0;}'|sort -k2,2 -k4,4nr >$id.genestructure.tmp");
    open STRUC,"<$id.genestructure.tmp";
        while(<STRUC>){
             chomp;
             my @arr=split;
             if($arr[0]=~/cds/ || $arr[0]=~/CDS/){
                 my$x1=$arr[3]+200-0.5;my$y1=$y-10;
                 my$x2=$arr[4]+200+0.5;my$y2=$y-10;
                 my$x3=$arr[3]+200-0.5;my$y3=$y+10;
                 my$x4=$arr[4]+200+0.5;my$y4=$y+10;
                 unshift(@points,$x2.",".$y2);
                 unshift(@points,$x1.",".$y1);
                 push(@points,$x4.",".$y4);
                 push(@points,$x3.",".$y3);        
             }elsif($arr[0]=~/conserve/){
                 my$x1=$arr[3]+200-0.5;my$y1=$y-7;
                 my$x2=$arr[4]+200+0.5;my$y2=$y-7;
                 my$x3=$arr[3]+200-0.5;my$y3=$y+7;
                 my$x4=$arr[4]+200+0.5;my$y4=$y+7;
                 unshift(@points,$x2.",".$y2);
                 unshift(@points,$x1.",".$y1);
                 push(@points,$x4.",".$y4);
                 push(@points,$x3.",".$y3);
             }else{
                 my$x1=$arr[3]+200-0.5;my$y1=$y-5;
                 my$x2=$arr[4]+200+0.5;my$y2=$y-5;
                 my$x3=$arr[3]+200-0.5;my$y3=$y+5;
                 my$x4=$arr[4]+200+0.5;my$y4=$y+5;
                 unshift(@points,$x2.",".$y2);  
                 unshift(@points,$x1.",".$y1);
                 push(@points,$x4.",".$y4);   
                 push(@points,$x3.",".$y3);             
             }
        } 
    close STRUC;
    print '  <clipPath id="',$id,'">',"\n";
    print '    <polygon points="',join(" ",@points),'"/>',"\n";
    print '  </clipPath>',"\n";
    
    system("cat $ARGV[2]|awk '{if(\$1==\"$id\") print \$0;}' >$id.patchwork.tmp");
    open PATCH,"<$id.patchwork.tmp";
    while(<PATCH>){
        chomp;
        my @arr=split;
        if( exists $col{$arr[3]}){
             print ' <rect x="',$arr[1]+200-0.5,'" y="',$y-10,'" width="',$arr[2]-$arr[1]+1,'" height="20" clip-path="url(#',$id,')" style="fill:',$col{$arr[3]},'"/>',"\n";
        }else{
             my $rgb1=rand(255);
             my $rgb2=rand(255);
             my $rgb3=rand(255);
             $col{$arr[3]}="rgb($rgb1,$rgb2,$rgb3)";
             print '  <rect x="',$arr[1]+200-0.5,'" y="',$y-10,'" width="',$arr[2]-$arr[1]+1,'" height="20" clip-path="url(#',$id,')" style="fill:',$col{$arr[3]},'"/>',"\n";
        }
    }
    close PATCH;
    print '  <polygon points="',join(" ",@points),'" style="fill:none;stroke:black;stroke-width:2"/>',"\n";
    system("rm $id.genestructure.tmp");
    system("rm $id.patchwork.tmp");
    undef @points;
}
close IN;
print '</svg>',"\n";
