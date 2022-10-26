SHELL = /usr/bin/bash
.PHONY: all 

# TODO figure out how to get shell variable sing cache dir into targets

username=darachm

define docker-builder
token/docker-$(1)-$(2) : $(1)/Dockerfile.$(1) 
	sudo docker build -f $(1)/Dockerfile.$(1) \
		--target $(2) \
		-t $$(username)/$(1):$(2) \
		$(1)
	touch $$@
endef

define docker-push
token/docker-push-$(1)-$(2) : token/docker-login token/docker-$(1)-$(2)
	sudo docker push $$(username)/$(1):$(2)
	touch $$@
endef

define singularity-builder
~/.singularity/$(1)-$(2).sif : token/docker-push-$(1)-$(2)
	sudo singularity pull -F $$@ docker://$$(username)/$(1):$(2) 
endef

define singularity-push-ghcr
token/singularity-push-$(1)-$(2) : ~/.singularity/$(1)-$(2).sif 
	singularity push $(word 1,$^) oras://ghcr.io/darachm/$(1):$(2) 
endef

token/docker-login:
	sudo docker login
	touch token/docker-login

token/ghcr-docker-login:
	sudo docker login ghcr.io -u ${username} --password ${GHCR_PAT}
	touch $@

token/ghcr-singularity-login:
	singularity remote login --username ${username} --password ${GHCR_PAT} oras://ghcr.io
	touch $@






seq-qc_tags = \
	fastqc
	#cuda-11-2 \
	#cuda-test \
	#cuda-11-2-py-3-8-tf-2-5-2 
docker-seq-qc: $(addprefix token/docker-push-seq-qc-,$(seq-qc_tags))
$(foreach tag,$(seq-qc_tags),\
	$(eval $(call docker-builder,seq-qc,$(tag))) )
$(foreach tag,$(seq-qc_tags),\
	$(eval $(call docker-push,seq-qc,$(tag))) )
singularity-seq-qc: $(addsuffix .sif,$(addprefix ~/.singularity/seq-qc-,$(seq-qc_tags)))
$(foreach tag,$(seq-qc_tags),\
	$(eval $(call singularity-builder,seq-qc,$(tag))) )




cuda-tensorflow_tags = \
	cuda-11-2-py-3-8-tf-2-5-2 \
	#cuda-11-5-py-3-9-tf-2-7-0 \
	#cuda-11-0-cudnn-8-0-py-3-8-tf-2-2-0
	#cuda-11-2 \
	#cuda-test \
docker-cuda-tensorflow: $(addprefix token/docker-push-cuda-tensorflow-,$(cuda-tensorflow_tags))
$(foreach tag,$(cuda-tensorflow_tags),\
	$(eval $(call docker-builder,cuda-tensorflow,$(tag))) )
$(foreach tag,$(cuda-tensorflow_tags),\
	$(eval $(call docker-push,cuda-tensorflow,$(tag))) )
singularity-cuda-tensorflow: $(addsuffix .sif,$(addprefix ~/.singularity/cuda-tensorflow-,$(cuda-tensorflow_tags)))
$(foreach tag,$(cuda-tensorflow_tags),\
	$(eval $(call singularity-builder,cuda-tensorflow,$(tag))) )

rr_tags = r-base r-tidy-db-viz r-tidy-db-viz-mod-bio r-tidy-db-viz-mod-bio-nvimr
#$(shell cat r/Dockerfile.rr | grep "FROM" | sed 's/.* AS //' )
docker-rr: $(addprefix token/docker-push-rr-,$(r_tags))
$(foreach tag,$(rr_tags),\
	$(eval $(call docker-builder,rr,$(tag))) )
$(foreach tag,$(rr_tags),\
	$(eval $(call docker-push,rr,$(tag))) )
singularity-rr: $(addsuffix .sif,$(addprefix ~/.singularity/rr-,$(rr_tags)))
$(foreach tag,$(rr_tags),\
	$(eval $(call singularity-builder,rr,$(tag))) )

bioinf_tags = \
	bioinf-base bioinf-python \
	bioinf-python-parallel \
	bioinf-sam-bedtools \
	bioinf-sam-bedtools-emboss-ncbi
#$(shell cat bioinf/Dockerfile.bioinf | grep "FROM" | sed 's/.* AS //' )
docker-bioinf: $(addprefix token/docker-push-bioinf-,$(bioinf_tags))
$(foreach tag,$(bioinf_tags),\
	$(eval $(call docker-builder,bioinf,$(tag))) )
$(foreach tag,$(bioinf_tags),\
	$(eval $(call docker-push,bioinf,$(tag))) )
singularity-bioinf: $(addsuffix .sif,$(addprefix ~/.singularity/bioinf-,$(bioinf_tags)))
$(foreach tag,$(bioinf_tags),\
	$(eval $(call singularity-builder,bioinf,$(tag))) )

bioconda_tags = bioconda-pacbio
#$(shell cat bioconda/Dockerfile.bioconda | grep "FROM" | sed 's/.* AS //' )
docker-bioconda: $(addprefix token/docker-push-bioconda-,$(bioconda_tags)) 
$(foreach tag,$(bioconda_tags),\
	$(eval $(call docker-builder,bioconda,$(tag))) )
$(foreach tag,$(bioconda_tags),\
	$(eval $(call docker-push,bioconda,$(tag))) )
singularity-bioconda: $(addsuffix .sif,$(addprefix ~/.singularity/bioconda-,$(bioconda_tags)))
$(foreach tag,$(bioconda_tags),\
	$(eval $(call singularity-builder,bioconda,$(tag))) )

nanopore_tags = medaka medaka-hack racon nanoplot \
	guppy-gpu-6.1.3 \
	guppy-gpu-6.0.1 \
	guppy-cpu-6.1.1 \
	guppy-gpu-6.1.1 
#$(shell cat nanopore/Dockerfile.nanopore | grep "FROM" | sed 's/.* AS //' )
docker-nanopore: $(addprefix token/docker-push-nanopore-,$(nanopore_tags)) 
$(foreach tag,$(nanopore_tags),\
	$(eval $(call docker-builder,nanopore,$(tag))) )
$(foreach tag,$(nanopore_tags),\
	$(eval $(call docker-push,nanopore,$(tag))) )
singularity-nanopore: $(addsuffix .sif,$(addprefix ~/.singularity/nanopore-,$(nanopore_tags)))
$(foreach tag,$(nanopore_tags),\
	$(eval $(call singularity-builder,nanopore,$(tag))) )



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

jupyter_tags = jupyter jupyter-plus
docker-jupyter: $(addprefix token/docker-push-jupyter-,$(jupyter_tags))
$(foreach tag,$(jupyter_tags),\
	$(eval $(call docker-builder,jupyter,$(tag))) )
$(foreach tag,$(jupyter_tags),\
	$(eval $(call docker-push,jupyter,$(tag))) )
singularity-jupyter: $(addsuffix .sif,$(addprefix ~/.singularity/jupyter-,$(jupyter_tags)))
$(foreach tag,$(jupyter_tags),\
	$(eval $(call singularity-builder,jupyter,$(tag))) )



lh3-aligners_tags = minimap2-bwa-bwamem2
docker-lh3-aligners: $(addprefix token/docker-push-lh3-aligners-,$(lh3-aligners_tags))
$(foreach tag,$(lh3-aligners_tags),\
	$(eval $(call docker-builder,lh3-aligners,$(tag))) )
$(foreach tag,$(lh3-aligners_tags),\
	$(eval $(call docker-push,lh3-aligners,$(tag))) )
singularity-lh3-aligners: $(addsuffix .sif,$(addprefix ~/.singularity/lh3-aligners-,$(lh3-aligners_tags)))
$(foreach tag,$(lh3-aligners_tags),\
	$(eval $(call singularity-builder,lh3-aligners,$(tag))) )


token/docker-nanopore-medaka-hack.sif: token/docker-push-cuda-tensorflow-cuda-11-2-py-3-8-tf-2-5-2
token/docker-nanopore-medaka: token/docker-push-cuda-tensorflow-cuda-11-2-py-3-8-tf-2-5-2
token/docker-nanopore-guppy-gpu*: token/docker-push-cuda-tensorflow-cuda-11-2 #-py-3-9-tf-2-6-2
token/docker-nanopore-guppy-cpu*: token/docker-push-bioinf-bioinf-base  #cuda-tensorflow-cuda-11-2 #-py-3-9-tf-2-6-2
token/docker-nanopore-racon: token/docker-push-bioinf-bioinf-sam-bedtools-parallel
token/docker-bioconda: token/docker-push-bioinf-bioinf-sam
token/docker-nanopore-nanoplot: token/docker-push-bioinf-bioinf-base
token/docker-kalign-bioinf-kalign: token/docker-push-bioinf-bioinf-sam-bedtools-parallel

docker-starcode: $(addprefix token/docker-push-starcode-,latest) 
$(foreach tag,latest,\
	$(eval $(call docker-builder,starcode,$(tag))) )
$(foreach tag,latest,\
	$(eval $(call docker-push,starcode,$(tag))) )
singularity-starcode: $(addsuffix .sif,$(addprefix ~/.singularity/starcode-,latest))
$(foreach tag,latest,\
	$(eval $(call singularity-builder,starcode,$(tag))) )

docker-flye: $(addprefix token/docker-push-flye-,latest) 
$(foreach tag,latest,\
	$(eval $(call docker-builder,flye,$(tag))) )
$(foreach tag,latest,\
	$(eval $(call docker-push,flye,$(tag))) )
singularity-flye: $(addsuffix .sif,$(addprefix ~/.singularity/flye-,latest))
$(foreach tag,latest,\
	$(eval $(call singularity-builder,flye,$(tag))) )

docker-kalign: $(addprefix token/docker-push-kalign-,bioinf-kalign) 
$(foreach tag,bioinf-kalign,\
	$(eval $(call docker-builder,kalign,$(tag))) )
$(foreach tag,bioinf-kalign,\
	$(eval $(call docker-push,kalign,$(tag))) )
singularity-kalign: $(addsuffix .sif,$(addprefix ~/.singularity/kalign-,bioinf-kalign))
$(foreach tag,bioinf-kalign,\
	$(eval $(call singularity-builder,kalign,$(tag))) )

docker-htseq: $(addprefix token/docker-push-htseq-,htseq) 
$(foreach tag,htseq,\
	$(eval $(call docker-builder,htseq,$(tag))) )
$(foreach tag,htseq,\
	$(eval $(call docker-push,htseq,$(tag))) )
singularity-htseq: $(addsuffix .sif,$(addprefix ~/.singularity/htseq-,htseq))
$(foreach tag,htseq,\
	$(eval $(call singularity-builder,htseq,$(tag))) )



docker-fitseq: token/docker-push-fitseq-latest
$(eval $(call docker-builder,fitseq,latest) )
$(eval $(call docker-push,fitseq,latest) )


~/.singularity/blast.sif : 
	sudo singularity pull -F $@ docker://ncbi/blast:2.12.0


#token/docker-push-itermae-plus: token/docker-login 
#	sudo docker push $(username)/itermae:plus
#	touch $$@
#$(eval $(call singularity-builder,itermae,plus))
~/.singularity/itermae-plus.sif : #token/docker-push-itermae-plus
	sudo singularity pull -F $@ docker://$(username)/itermae:plus 
#
#token/docker-push-itermae-plus: token/docker-login 
#	sudo docker push $(username)/itermae:plus
#	touch $$@
#$(eval $(call singularity-builder,itermae,plus))
#~/.singularity/itermae-plus.sif : #token/docker-push-itermae-plus
#	sudo singularity pull -F $@ docker://$(username)/itermae:plus 



all: singularity-cuda-tensorflow singularity-rr singularity-bioinf \
	singularity-bioconda singularity-nanopore \
	~/.singularity/itermae-plus.sif \
	singularity-starcode singularity-lh3-aligners singularity-htseq





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

#~/.singularity/%.sif : */Singularity.% 
#	sudo singularity build $@ $<

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



#riding_the_bench = alignparse enrich2 mummer4 \
#canu \
#flye \
#nanopolish \
#pycoqc \
#squeakr \
#t-coffee 


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



