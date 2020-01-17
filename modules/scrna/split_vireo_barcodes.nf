params.run = true

process 'split_vireo_barcodes' {
    tag "$samplename"

    errorStrategy = { task.attempt <= 4 ? 'retry' : 'ignore' }
    cpus =   1
    memory = 2.GB
    maxRetries 4
    time '100m'
    
    publishDir "${params.outdir}/split_vireo_barcodes/", mode: 'symlink'

    when:
    params.run 

    input:
    set val(samplename), file(vireo_dir), val(n_pooled), file(cellranger_dir)
    
    output:
    tuple val(samplename), file("cellranger_deconv_${samplename}_*"), emit: cellranger_deconv_dirs

  script:
   """
cat $vireo_dir/donor_ids.tsv | sed s/unassigned/donor4/g > copy_ids.tsv

cat copy_ids.tsv | grep -v unassigned | grep -v doublet | cut -f 1,2 | awk '{print \$1 > \$2\".tsv\"}'
##  cat $vireo_dir/donor_ids.tsv | grep -v unassigned | grep -v doublet | cut -f 1,2 | awk '{print \$1 > \$2\".tsv\"}'

for donor_barcodes_file in donor*.tsv
do
   donor_n=\$(echo \$donor_barcodes_file | tr -dc '0-9')
   cp -Lr $cellranger_dir cellranger_deconv_${samplename}_\${donor_n}
   cp \$donor_barcodes_file cellranger_deconv_${samplename}_\${donor_n}/barcodes_subset.tsv
done
   """
}

// find . -maxdepth 1 -name 'donor*.tsv' -exec gzip {} \\;
