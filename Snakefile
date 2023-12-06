####
from os import listdir
from os.path import isfile, join
path = "/zfshome/sukem124/aging/mice_cogn2/seqs/"
filenames = [f for f in listdir(path)]
binnames = [item[:-3] for item in filenames]

gapseq = "~/gapseq/gapseq"
out_folder = "/zfshome/sukem124/aging/mice_cogn2/out/"

rule all:
	input:
		expand(out_folder + "{file}"+ ".RDS", file = binnames)
			
rule prodigal:
	input:
		bin=path+"{file}.fa"
	output:
		out=out_folder + "{file}.faa"
	resources:
		time="2:00:00",
		slurm_extra="--cpu-per-task=6 --mem=50GB"
	conda:
		"gapseq.yaml"
	shell:
		"""
		prodigal -i {input.bin} -o /dev/null -a {output.out}
		"""

rule pathway:
	input:
		faa=out_folder + "{file}.faa"
	output:
		out=out_folder + "{file}"+ "-all-Pathways.tbl",
		react=out_folder + "{file}"+ "-all-Reactions.tbl"
	resources:
                time="10:00:00",
                slurm_extra="--cpu-per-task=6 --mem=50GB"
	conda:
               "gapseq.yaml"
	shell:
		"""
		{gapseq} find -v 0 -k -b 200 -p all -t auto {input.faa} && 
		mv {wildcards.file}-all-Pathways.tbl {output.out} &&
		mv {wildcards.file}-all-Reactions.tbl {output.react}
		"""

rule transporter:
	input:
		faa=out_folder + "{file}.faa"
	output: 
                out=out_folder + "{file}"+ "-Transporter.tbl"
	resources:
                time="10:00:00",
                slurm_extra="--cpu-per-task=6 --mem=50GB"
	conda:
               "gapseq.yaml"
	shell:
		"""
		{gapseq} find-transport -v 0 -k -b 200 {input.faa} &&
		mv {wildcards.file}-Transporter.tbl {output.out}
		"""
rule draft_model:
	input:
                faa=out_folder + "{file}.faa",
                path=out_folder + "{file}"+ "-all-Pathways.tbl",
                react=out_folder + "{file}"+ "-all-Reactions.tbl",
		trans=out_folder + "{file}"+ "-Transporter.tbl"	
	output:
                draft=out_folder + "{file}"+ "-draft.RDS",
                weights=out_folder + "{file}"+ "-rxnWeights.RDS",
                genes=out_folder + "{file}"+ "-rxnXgenes.RDS"
	resources:
                time="10:00:00",
                slurm_extra="--cpu-per-task=6 --mem=50GB"
	conda: 
               "gapseq.yaml"
	shell: 
		"""
	{gapseq} draft -r {input.react} -t {input.trans} -c {input.faa} -u 200 -l 100 -p {input.path} &&
	mv {wildcards.file}-draft.RDS {output.draft} &&
	mv {wildcards.file}-rxnWeights.RDS {output.weights} &&
	mv {wildcards.file}-rxnXgenes.RDS {output.genes}
		"""
rule medium:
	input:
		draft=out_folder + "{file}"+ "-draft.RDS",
		path=out_folder + "{file}"+ "-all-Pathways.tbl"
	output:
		med=out_folder + "{file}"+ "-medium.csv"
	resources:
                 time="10:00:00",
                 slurm_extra="--cpu-per-task=6 --mem=50GB"
	conda:
                "gapseq.yaml"
	shell:
		"""
		{gapseq} medium -m {input.draft} -p {input.path} &&
		mv {wildcards.file}-medium.csv {output.med}

		"""
rule gap_filling:
	input:
		draft=out_folder + "{file}"+ "-draft.RDS",
                weights=out_folder + "{file}"+ "-rxnWeights.RDS",
                genes=out_folder + "{file}"+ "-rxnXgenes.RDS"
	output:
		rds_model=out_folder + "{file}"+ ".RDS",
		xml_model=out_folder + "{file}"+ ".xml"
	resources:
                time="10:00:00",
                slurm_extra="--cpu-per-task=6 --mem=50GB"
	conda:
               "gapseq.yaml"
	shell:
		"""
		{gapseq} fill -m {input.draft} -n /zfshome/sukem124/aging/mice_cogn2/metamouse_diet2.csv -c {input.weights} -b 100 -g {input.genes} &&
		mv {wildcards.file} + ".RDS"  {output.rds_model} &&
		mv {wildcards.file} + ".xml"  {output.xml_model}
		"""

#
#
#
