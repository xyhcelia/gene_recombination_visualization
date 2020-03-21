if [ $# -ne 2 ]
then
cat<<EOF
Usage:  sh $0 sequence.fasta    gene_structure.txt
sequence.fasta:	A fasta file containing sequences of wtf genes;
gene_structure.txt:	A file containing  gene structure annotaions in the Jalview feature format;
EOF
     exit
fi

path=$(cd `dirname $0`; pwd)

#####iterative  blast to search similar sequences######
db=`echo $1| awk '{split($1,a,".fa"); print a[1];}'`;
less $1 |grep ">"|sed 's/>//' >$db.seq.list
makeblastdb -in $1  -out $db -dbtype nucl
for seq in ` cat $db.seq.list`;do
   cat $1 |awk 'BEGIN{RS=">";}{if($1=="'$seq'") print ">"$0; }'|grep -v '^$'  >$db.$seq.fa
#   blastn -query $db.$seq.fa  -db $db  -word_size 20 -reward 1 -penalty -4 -outfmt 7  -out $db.$seq.out
   blastn -query $db.$seq.fa  -db $db  -outfmt 7  -out $db.$seq.out
   less $db.$seq.out |awk '{if($1!~"#" && $9<$10 ) print $2"\t"$9-1"\t"$10"\t"$1"-like";}' >$db.$seq.out.bed
   less $db.$seq.out.bed |sort -k1,1 -k2,2n -k3,3n |bedtools merge -i -  -c 4 -o distinct >$db.$seq.out.merge.bed
   rm $db.$seq.fa
done

#######sequence clustering########

mafft --quiet $1 >$db.mafft.fa
Rscript $path/scripts/seq_hclust.R -i $db.mafft.fa   -o $db

#######remove repetitious result#####
cat $db.groups.txt|awk '{if(NR>1) print $0;}'|sort -k4,4nr -k5,5nr|cut -f 1 >$db.seq.list
seq1=` head -n1 $db.seq.list`;
cat $db.$seq1.out.merge.bed |awk '{print $1"\t"$2+1"\t"$3"\t"$4;}' >$db.tmp0
less $db.seq.list|awk '{if(NR>1) print $1;}' >$db.seq.list2
n1=0;
n2=1;
for seq in ` cat $db.seq.list2`;do
    perl $path/scripts/extract_nooverlap.pl $db.$seq.out.merge.bed  $db.tmp$n1 |awk '{if($2>0 && $3>=$2) print $0;}'|cat $db.tmp$n1 - >$db.tmp$n2

n1=$[$n1+1];
n2=$[$n2+1];

done
mv  $db.tmp$n1 $db.patchwork.tmp1
rm $db.tmp* $db.*.out $db.*.bed 
rm $db.seq.list2

perl $path/scripts/patchwork_merge.pl  $db.patchwork.tmp1 $db.patchwork.tmp2


#######for heatmap##########
#perl /data/XYH/script/type2num.pl $db.patchwork.tmp2 $db.patchwork.tmp3
#mafft $1 >$1.aln.fa
#sort -k1,1 -k2,2n $db.patchwork.tmp3|perl /data/XYH/script/aln_to_matrix.pl $1.aln.fa - $db.patchwork.matrix.txt
#perl /data/XYH/script/rm_smallgap.pl $db.patchwork.matrix.txt $db.patchwork.matrix.rmsmgap.txt

#######SVG plot ######
perl $path/scripts/patchwork_plot_withstructure.pl $db.seq.list  $2  $db.patchwork.tmp2 >$db.patchwork.html 
