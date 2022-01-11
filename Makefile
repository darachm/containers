SHELL = /usr/bin/bash
.PHONY: all 

# TODO figure out how to get shell variable sing cache dir into targets

username=darachm
define docker-builder
docker-$(1)-$(2) : $(1)/Dockerfile.$(1) 
	sudo docker build -f $(1)/Dockerfile.$(1) \
		--target $(2) \
		-t $$(username)/$(1):$(2) \
		$(1)
endef

cuda-tensorflow_tags = cuda cuda-py cuda-py-tf \
		cuda-2004 cuda-1804 \
		cuda-11-5-py-3-9-tf-2-7-0 \
		cuda-11-2-py-3-9-tf-2-6-2 \
		cuda-11-2-py-3-9-tf-2-5-2 \
		cuda-11-0-py-3-9-tf-2-4-4
docker-cuda-tensorflow: $(addprefix docker-cuda-tensorflow-,$(cuda-tensorflow_tags))
$(foreach tag,$(cuda-tensorflow_tags),\
	$(eval $(call docker-builder,cuda-tensorflow,$(tag))) )

r_tags = r-base r r-tidy r-tidy-db \
	r-tidy-db-viz r-tidy-db-viz-mod r-tidy-db-viz-mod-bio
docker-r: $(addprefix docker-r-,$(r_tags))
$(foreach tag,$(r_tags),\
	$(eval $(call docker-builder,r,$(tag))) )

bioinf_tags = bioinf-base bioinf-sam bioinf-sam-bedtools \
	bioinf-sam-bedtools-parallel
docker-bioinf: $(addprefix docker-bioinf-,$(bioinf_tags))
$(foreach tag,$(bioinf_tags),\
	$(eval $(call docker-builder,bioinf,$(tag))) )

bioconda_tags = bioconda-base bioconda-pacbio 
docker-bioconda: $(addprefix docker-bioconda-,$(bioconda_tags)) 
$(foreach tag,$(bioconda_tags),\
	$(eval $(call docker-builder,bioconda,$(tag))) )

nanopore_tags = medaka
docker-nanopore: $(addprefix docker-nanopore-,$(nanopore_tags)) 
$(foreach tag,$(nanopore_tags),\
	$(eval $(call docker-builder,nanopore,$(tag))) )

###### python
#~/.singularity/python3.sif : */Singularity.python3 ~/.singularity/ubuntu2004.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/python3-extra.sif : */Singularity.python3-extra ~/.singularity/python3.sif
#	bash -c "$(default_sif_build)"
#
###### bioinformatics
#~/.singularity/bioinfmunger.sif : */Singularity.bioinfmunger ~/.singularity/ubuntu2004.sif
#	bash -c "$(default_sif_build)"
#
###### bioconda, just in case, well actually for the pacbio I think
#~/.singularity/bioconda.sif : */Singularity.bioconda ~/.singularity/ubuntu2004.sif
#	bash -c "$(default_sif_build)"

~/.singularity/%.sif : */Singularity.% 
	sudo singularity build $@ $<

#default_sif_build = "echo $(word 1,$^) on top of $(word 2,$^) && \
#	sed 's/SEDmeTObase/$(subst /,\/,$(word 2,$^))/' $(word 1,$^) > tmp_recipie && \
#	sudo singularity build $@ tmp_recipie && \
#	rm tmp_recipie"

#ubuntu2004 bioinfmunger python3 python3-extra bioconda 
#	fitseq itermae-plus \
#	htseq \
#	bcl2fastq seq-qc \
#	bioinf-kalign3 \
#	lh3-aligners \
#	pacbio \
#	guppy-cpu guppy-gpu \
#	bioinf-racon \
#	medaka \
#	miniasm \
#	ncbi-blast \
#	starcode umi-tools 



#~/.singularity/base.sif : */Singularity.base ~/.singularity/.sif
#	bash -c "$(default_sif_build)"

###### THE BASE ubuntu2004 file
#~/.singularity/ubuntu2004.sif : */Singularity.ubuntu2004 
#	bash -c "$(default_sif_build)"
#
###### python
#~/.singularity/python3.sif : */Singularity.python3 ~/.singularity/ubuntu2004.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/python3-extra.sif : */Singularity.python3-extra ~/.singularity/python3.sif
#	bash -c "$(default_sif_build)"
#
###### bioinformatics
#~/.singularity/bioinfmunger.sif : */Singularity.bioinfmunger ~/.singularity/ubuntu2004.sif
#	bash -c "$(default_sif_build)"
#
###### bioconda, just in case, well actually for the pacbio I think
#~/.singularity/bioconda.sif : */Singularity.bioconda ~/.singularity/ubuntu2004.sif
#	bash -c "$(default_sif_build)"


###### r
#~/.singularity/r-base.sif : */Singularity.r-base ~/.singularity/ubuntu2004.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/r-tidy.sif : */Singularity.r-tidy ~/.singularity/r-base.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/r-tidy-some.sif : */Singularity.r-tidy-some ~/.singularity/r-tidy.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/r-tidy-extra.sif : */Singularity.r-tidy-extra ~/.singularity/r-tidy-some.sif
#	bash -c "$(default_sif_build)"
#
###### bioinf
#~/.singularity/fitseq.sif : */Singularity.fitseq ~/.singularity/python3.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/itermae-plus.sif : */Singularity.itermae-plus 
#~/.singularity/bcl2fastq.sif : */Singularity.bcl2fastq 
#~/.singularity/htseq.sif : */Singularity.htseq ~/.singularity/bioinfmunger.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/bioinf-kalign3.sif : */Singularity.bioinf-kalign3 ~/.singularity/bioinfmunger.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/lh3-aligners.sif : */Singularity.lh3-aligners ~/.singularity/bioinfmunger.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/pacbio.sif : */Singularity.pacbio ~/.singularity/bioconda.sif
#	bash -c "$(default_sif_build)"
#
#~/.singularity/guppy-gpu.sif : */Singularity.guppy-gpu ~/.singularity/cuda-tensorflow-v2.6.0.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/guppy-cpu.sif : */Singularity.guppy-cpu ~/.singularity/bioinfmunger.sif
#	bash -c "$(default_sif_build)"
#~/.singularity/bioinf-racon.sif : */Singularity.bioinf-racon ~/.singularity/lh3-aligners.sif
#	bash -c "$(default_sif_build)"

	#medaka \
	#miniasm \
	#ncbi-blast \ 
	#starcode 
	#umi-tools ))


#cuda_tensorflow = $(addprefix ~/.singularity/,$(addsuffix .sif,\
#	cuda-tensorflow-v2.6.0 ))
##cuda-tensorflow-v2.2.0 \
##cuda-tensorflow-v2.2.3 \
##cuda-v10.1-cudnn-v7.6-tensorflow-v2.2.0-pre1 \
##tensorflow-v1.15.4-compiled \
##tensorflow-v1.15.4-compiled-partial \
##tensorflow-v2.0.3-compiled \
##tensorflow-v2.0.3-compiled-partial \
##tensorflow-v2.0.3-compiled-partial2 \
##tensorflow-v2.0.3-compiled-partial3 \
##tensorflow-v2.0.3-compiled-partial4 \
##tensorflow-v2.2.0-compiled \
##tensorflow-v2.4.0-rc4-compiled \
##tensorflow-v2.5.0-compiled \
##
#cuda_tensorflow: $(cuda_tensorflow)
#
###### cuda tensorflow
#~/.singularity/cuda-tensorflow-v2.6.0.sif : */Singularity.cuda-tensorflow-v2.6.0 
#	bash -c "$(default_sif_build)"

#jupyter = $(addprefix ~/.singularity/,$(addsuffix .sif,\
#	jupyter \
#	extra-jupyter \
#	bioconda-jupyter \
#	cuda-tensorflow-v2.6.0-jupyter \
#	))
#jupyter = $(jupyter)
###### jupyter
#~/.singularity/%-jupyter.sif : */Singularity.plus-jupyter ~/.singularity/%.sif
#	bash -c "$(default_sif_build)"


riding_the_bench = alignparse enrich2 mummer4 \
canu \
flye \
nanopolish \
pycoqc \
squeakr \
t-coffee 


#all_containers = \
#	~/.singularity/fitseq.sif \
#	#~/.singularity/r-tidy-extra-nvimr.sif \
#	#~/.singularity/ncbi-blast.sif \
##~/.singularity/bioinfmunger.sif : 
##~/.singularity/starcode.sif : 
##~/.singularity/itermae-plus.sif : 
##~/.singularity/guppy-gpu.sif : 
##~/.singularity/racon.sif : 
##~/.singularity/medaka.sif : 
##~/.singularity/lh3-aligners.sif : 
##~/.singularity/htseq.sif : 
##~/.singularity/kalign2.sif : 
#
##	~/.singularity/darachm-containers-ubuntu2004.simg \
##	~/.singularity/darachm-containers-tensorflow-v2.2.0-compiled.simg \
##	~/.singularity/darachm-containers-tensorflow-v2.4.0-rc4-compiled.simg \
##	~/.singularity/darachm-containers-jupyter-plus.simg \
##	~/.singularity/darachm-containers-jupyter-plus-tensorflow-v2.2.0-compiled.simg \
##	~/.singularity/darachm-containers-tensorflow-v1.15.4-compiled-partial.simg \
##	~/.singularity/darachm-containers-tensorflow-v1.15.4-compiled.simg \
##	~/.singularity/darachm-containers-jupyter.simg 
#
## Additional dependencies for some
#~/.singularity/darachm-containers-jupyter-plus.simg : \
#		~/.singularity/darachm-containers-ubuntu2004.simg
##~/.singularity/darachm-containers-jupyter-plus-tfcompiled-v2.4.0-rc4-compiled.simg : \
##		~/.singularity/darachm-containers-tensorflow-v2.4.0-rc4-compiled.simg 
##~/.singularity/darachm-containers-jupyter-plus-tensorflow-v2.2.0-compiled.simg : \
##		~/.singularity/darachm-containers-tensorflow-v2.2.0-compiled-partial.simg 
##
##~/.singularity/darachm-containers-jupyter-plus-tensorflow-v2.0.3-compiled.simg : \
##		~/.singularity/darachm-containers-tensorflow-v2.0.3-compiled-partial.simg 
#
#
##~/.singularity/darachm-containers-tensorflow-v1.15.4-compiled.simg : \
##		~/.singularity/darachm-containers-tensorflow-v1.15.4-compiled-partial.simg
##~/.singularity/darachm-containers-tensorflow-v1.15.4-compiled-partial.simg :
#
#bps: ~/.singularity/bioinfmunger.sif ~/.singularity/starcode.sif ~/.singularity/itermae-plus.sif ~/.singularity/guppy-gpu.sif ~/.singularity/racon.sif ~/.singularity/lh3-aligners.sif ~/.singularity/htseq.sif ~/.singularity/bioinf-kalign2.sif 
#
#all: $(all_containers)
#
#~/.singularity/medaka.sif : ~/.singularity/cuda-tensorflow-v2.2.3.sif
#~/.singularity/cuda-tensorflow-v2.2.3.sif :
#
#~/.singularity/cuda-tensorflow-v2.6.0.sif :
#
#~/.singularity/ncbi-blast.sif : 
#~/.singularity/bioinfmunger.sif : 
#~/.singularity/starcode.sif : 
#~/.singularity/itermae-plus.sif : 
#~/.singularity/guppy-gpu.sif : 
#~/.singularity/racon.sif : 
#~/.singularity/medaka.sif : 
#~/.singularity/lh3-aligners.sif : 
#~/.singularity/htseq.sif : 
#~/.singularity/kalign2.sif : 
#~/.singularity/bioinf-kalign2.sif : ~/.singularity/bioinfmunger.sif 
#
#~/.singularity/r-tidy.sif : ~/.singularity/r.sif
#~/.singularity/r-tidy-extra.sif : ~/.singularity/r-tidy.sif
#~/.singularity/r-tidy-extra-nvimr.sif : ~/.singularity/r-tidy-extra.sif
#
#~/.singularity/python3-extra.sif : ~/.singularity/python3.sif
#~/.singularity/python3.sif : ~/.singularity/ubuntu2004.sif
#
#~/.singularity/bioconda.sif : ~/.singularity/ubuntu2004.sif
#~/.singularity/enrich2.sif : ~/.singularity/bioconda.sif
#
#~/.singularity/fitseq-dev.sif : 
#
#~/.singularity/jupyter-plus.sif : ~/.singularity/jupyter-plus.sif
#
#~/.singularity/darachm-containers-jupyter-plus-tensorflow-v2.4.0-rc4-compiled.simg: ~/.singularity/darachm-containers-tensorflow-v2.4.0-rc4-compiled.simg


all: $(all_containers)

