
## Acknowledgement
Thanks to Samer Alban for providing the actual code to run MicrobiomeGS. As users of the package please include him in your list of authors, further include Thomas Dost if you deem the transformation of Samer's code into a Snakemake pipeline enough for inclusion.


![Alt text](https://i.kym-cdn.com/photos/images/newsfeed/000/016/809/rtfm.jpg?1318992465)

# MSB GAPSEQ PIPELINE
Ever wanted to fast and easily build gapseqs? Now is your chance! Just 4.99$ per month. Please contact your local HiWi



## Prerequisites 
* mamba
* git
* Snakemake
* Have a ssh key registered in GitLab
* Love for metabolic modelling 

## Starting a new project
DISCLAIMER: You should most likely read the `Integrating it into an existing project` section down below. The current section will make it quite annoying to integrate this pipeline into an existing git project. And because you are a good person you adhere to Thomas' idea of how to structure a project you want to use git for everything :).


`cd` to your local project folder and run `git clone  git@cau-git.rz.uni-kiel.de:MSB/pipelines/gapseq_pipeline.git` and activate your mamba env containing snakemake

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

## Integrating it into an existing project
`cd` to your local project folder and create a folder called `submodules` and cd into this directory. There create a directory called `configs` which will be empty for now,
and run `git submodule add  git@cau-git.rz.uni-kiel.de:MSB/pipelines/gapseq_pipeline.git`.
The next step is then .... contact Thomas because this is currently not fully implemented



## Contributing 

Please contact Thomas or open a pull request 



