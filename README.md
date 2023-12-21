# MSB GAPSEQ PIPELINE
Ever wanted to just fast and easy build gapseqs. Now is your chance. Just 4.99$ per month. Please contact your local HiWi



## Prerequisites 
* mamba
* git
* Snakemake
* Love for metabolic modelling 

## Starting a new project

`cd` to your local project folder and run `git clone git@github.com:Unaimend/msb_gapseq_pipeline.git` and activate your mamba env containing snakemake

Lets now assume there exist some folder called $MyMAGs$ with files called $mag1.fa$ to $magn.fa$ that contains your pre-build MAGs.
To tell the pipeline to use this folder as input open the `config.yaml` and change the `input_folder` and `mag_ending` to the appropriate values. 

ATTENTION: NO ZIPED FILES ALLOWED. This seems to be a limitation of prodigal nothing can be done there

Optionally you can specify and `out_folder` where all the produces files will end up.
Next step is then to specify a medium and set `use_medium` to true to use a custom medium.
If you instead want to use the gapseq-predicted media just set `use_medium` to false.

If for some reason you want to build models for a subset of your MAGs specify a path in the `keep_list` variable. If for example you just want to build models for $mag3$ and $mag4$. The keep file looks like this
```
mag3.fa
mag4,fa
``` 
I.e. a `\n` separated file of the mag names you want to build models for.

That's all of the input/output configuration you have to do.

To run locally execute
```
snakemake --cores <cores> --use-conda
```

To run it on the cluster just execute
```
snakemake --profile settings/
```

To test the pipeline (takes around 2 hours) run
```
snakemake --cores 2 --use-conda
```
