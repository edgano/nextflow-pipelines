nextflow.preview.dsl=2
params.run_vqsr = true


params.vcfs_dir = "/lustre/scratch118/humgen/hgi/projects/interval_wes/joint_calls/output_vcf/stripped_vcf"
Channel.fromPath("${params.vcfs_dir}/interval_wes_stripped.vcf.gz")
	.set{ch_vcfs_gz}
Channel.fromPath("${params.vcfs_dir}/interval_wes_stripped.vcf.gz.tbi")
	.set{ch_vcfs_gz_tbi}

include vqsr_vcf_first_step from '../modules/variant_calling/as_vqsr_vcf_1st_step.nf' params(run: true, outdir: params.outdir)
include vqsr_vcf_second_step from '../modules/variant_calling/as_vqsr_vcf_2nd_step.nf' params(run: true, outdir: params.outdir)

workflow {
    ch_vcfs_gz
	.map{vcf -> tuple(vcf.getSimpleName(),vcf)}
	.combine(
	ch_vcfs_gz_tbi
	    .map{tbi -> tuple(tbi.getSimpleName(),tbi)}, by: 0)
	.take(8) // replace with take(-1) to select all inputs
	.set{ch_name_vcf_tbi}

    ch_vcfs_gz.view()
    ch_vcfs_gz_tbi.view()

   // ch_name_vcf_tbi.view()
   if (params.run_vqsr) {
     vqsr_vcf_first_step(ch_name_vcf_tbi.map{name,vcf,tbi -> tuple(file(vcf),file(tbi))})
    vqsr_vcf_first_step.out.view()
   }

//vqsr_vcf(concat_vcfs.out.concat_vcf.map{vcf,csi,tbi -> tuple(vcf,tbi)})
  //  vqsr_vcf(ch_name_vcf_tbi)

      println "End of workflow."
}