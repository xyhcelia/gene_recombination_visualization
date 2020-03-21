## gene_recombination_visualization
   Sequence exchange between genes can produce differenct combinations of segments,which play an important role in rapid evolution of some genes,such as immunoglobulin encoding genes. Sequence recombination among genes usually produce  a "patchwork"-like pattern.So the script patchwork.sh can give a clear picture of recombination anong a set of genes.

## Usage
```
sh patchwork.sh sequence.fasta    gene_structure.txt
sequence.fasta: A fasta file containing sequences of a set of  genes;
gene_structure.txt:     A file containing  gene structure annotaions in the Jalview feature format;
```

## work flow
The script take usage the blast software to detect homologous sequences among genes.
 ![image](https://github.com/xyhcelia/Readme_images/blob/master/gene_recombination_visualization/patwork_work_flow.png)
For the overlap merging step,the priority is decided by the sequence clustering result. All genes are divided into diffrent groups and genes in groups with more members will have a higher priority;
![image](https://github.com/xyhcelia/Readme_images/blob/master/gene_recombination_visualization/wtf_hclust.png)
##  Final result
![image](https://github.com/xyhcelia/Readme_images/blob/master/gene_recombination_visualization/JB22_wtf_patchwork.png)
