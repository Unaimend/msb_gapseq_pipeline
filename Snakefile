####
from os import listdir
from os.path import isfile, join
configfile: "config.yaml"
out_folder   =  config["out_folder"]
input_folder =  config["input_folder"]
medium       =  config["medium"]
mag_ending   =  config["mag_ending"]
use_medium   =  config["use_medium"]


filenames = [f for f in listdir(input_folder)]
binnames = [item for item in filenames if item.endswith(mag_ending)]


rule all:
        input: 
                "gapseq",
                expand(os.path.join(out_folder, "prodigal/{file}.faa"), file = binnames),
		expand(os.path.join(out_folder, "gapseq_find/{file}-all-Pathways.tbl"), file = binnames),
		expand(os.path.join(out_folder, "gapseq_find/{file}-all-Reactions.tbl"), file = binnames),
                expand(os.path.join(out_folder, "gapseq_transport/{file}-Transporter.tbl"), file = binnames),
                expand(os.path.join(out_folder, "gapseq_draft/{file}-draft.RDS"), file = binnames),
                expand(os.path.join(out_folder, "gapseq_draft/{file}-rxnWeights.RDS"), file = binnames),
                expand(os.path.join(out_folder, "gapseq_draft/{file}-rxnXgenes.RDS"), file = binnames),
		expand(os.path.join(out_folder, "generated_medium/{file}-medium.csv"), file = binnames),
                expand(os.path.join(out_folder, "final_model/{file}.RDS"), file = binnames),
                expand(os.path.join(out_folder, "final_model/{file}.xml"), file = binnames)

rule clone_gs:
        output:
                directory("gapseq")
        shell: 
                """
                git clone https://github.com/jotech/gapseq && mv gapseq/gapseq_env.yml gapseq.yml

                """

rule prodigal:
	input:
		bin= os.path.join(input_folder,"{file}")
	output:
		out= os.path.join(out_folder, "prodigal/{file}.faa")
	conda:
		"prodigal.yml"
	shell:
		"""
		prodigal -i {input.bin} -o /dev/null -a {output.out}
		"""

rule pathway:
	input:
                "gapseq/",
		faa=  os.path.join(out_folder, "prodigal/{file}.faa")
	output:
		out=os.path.join(out_folder, "gapseq_find/{file}-all-Pathways.tbl"),
		react=os.path.join(out_folder, "gapseq_find/{file}-all-Reactions.tbl")
	conda:
               "gapseq.yml"
        resources:
                slurm_extra="--cpus-per-task=10"
	shell:
		"""
		./gapseq/gapseq find -v 0 -k -b 200 -p all -t auto {input.faa} && 
		mv {wildcards.file}-all-Pathways.tbl {output.out} &&
		mv {wildcards.file}-all-Reactions.tbl {output.react}
		"""

rule transporter:
	input:
                "gapseq/",
		faa=os.path.join(out_folder, "prodigal/{file}.faa")
	output: 
                out=os.path.join(out_folder, "gapseq_transport/{file}-Transporter.tbl")
	conda:
               "gapseq.yml"
        resources:
                slurm_extra="--cpus-per-task=10"
	shell:
		"""
		./gapseq/gapseq find-transport -v 0 -K -b 200 {input.faa} &&
		mv {wildcards.file}-Transporter.tbl {output.out}
		"""
rule draft_model:
	input:
                "gapseq/",
                faa   =os.path.join(out_folder, "prodigal/{file}.faa"),
                path  =os.path.join(out_folder, "gapseq_find/{file}-all-Pathways.tbl"),
                react =os.path.join(out_folder, "gapseq_find/{file}-all-Reactions.tbl"),
		trans =os.path.join(out_folder, "gapseq_transport/{file}-Transporter.tbl")	
	output:
                draft_rds =os.path.join(out_folder, "gapseq_draft/{file}-draft.RDS"),
                draft_xml =os.path.join(out_folder, "gapseq_draft/{file}-draft.xml"),
                weights   =os.path.join(out_folder, "gapseq_draft/{file}-rxnWeights.RDS"),
                genes     =os.path.join(out_folder, "gapseq_draft/{file}-rxnXgenes.RDS")
	conda: 
               "gapseq.yml"
	shell: 
		"""
	./gapseq/gapseq draft -r {input.react} -t {input.trans} -c {input.faa} -u 200 -l 100 -p {input.path} #&&
	mv {wildcards.file}-draft.RDS {output.draft_rds} &&
	mv {wildcards.file}-draft.xml {output.draft_xml} &&
	mv {wildcards.file}-rxnWeights.RDS {output.weights} &&
	mv {wildcards.file}-rxnXgenes.RDS {output.genes}
		"""
rule medium:
	input:
                "gapseq/",
		draft =os.path.join(out_folder, "gapseq_draft/{file}-draft.RDS"),
		path  =os.path.join(out_folder, "gapseq_find/{file}-all-Pathways.tbl")
	output:
		med= os.path.join(out_folder, "generated_medium/{file}-medium.csv")
	conda:
                "gapseq.yml"
	shell:
		"""
		./gapseq/gapseq medium -m {input.draft} -p {input.path} &&
		mv {wildcards.file}-medium.csv {output.med}
               """

rule gap_filling:
	input:
                "gapseq/",
		draft   = os.path.join(out_folder, "gapseq_draft/{file}-draft.RDS"),
                weights = os.path.join(out_folder, "gapseq_draft/{file}-rxnWeights.RDS"),
                genes   = os.path.join(out_folder, "gapseq_draft/{file}-rxnXgenes.RDS"),
		med     = os.path.join(out_folder, "generated_medium/{file}-medium.csv")
	output:
		rds_model=os.path.join(out_folder,"final_model/{file}.RDS"),
		xml_model=os.path.join(out_folder,"final_model/{file}.xml")
	conda:
               "gapseq.yml"
	shell:
		"""
                # TODO MUCH CLEAN TO SET A VARIABLE IN THE IF AND THEN EXECUTE GS
                if [ {use_medium} == "true" ]; then
                    ./gapseq/gapseq fill -m {input.draft} -n {medium} -c {input.weights} -b 100 -g {input.genes} &&  mv {wildcards.file}.xml  {output.xml_model} && mv {wildcards.file}.RDS  {output.rds_model}
                else
                    ./gapseq/gapseq fill -m {input.draft} -n {input.med} -c {input.weights} -b 100 -g {input.genes} &&  mv {wildcards.file}.xml  {output.xml_model} && mv {wildcards.file}.RDS  {output.rds_model}
                fi
		"""


                

#
