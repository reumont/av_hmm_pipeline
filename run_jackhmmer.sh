#!/bin/bash

# Adapted JackHmmer script based on the animal venomics hmmer pipeline (av_hmmer_pipeline, see *greatfireball*, see *AnimalVenomics*)
# For single or multiple sequences (.fas) located in /alignment folder a jackhmmer search is performed against protein translated assembly in folder /assemblies.
# Matching sequences are extracted via Seqfilter.

# Take sequence(s) from fas file
for sequencefas in $(find alignments/ -type f | grep -P "\.fa[^.]*$")
do
	# create a temporary file for the ids used later as SeqFilter input
	TEMP_ID_FILE=$(tempfile)

	# run jackhmmer for sequence(s) fas.file(s) against protein assembl(ies) in /assemblies ending in *.fa
	for assemblyfile in $(find assemblies/ -type f | grep -P "\.fa[^.]*$")
	do
		date +"[%Y-%m-%d %H:%M:%S] Started jackhmmer for '${sequencefas}' vs '${assemblyfile}'"
		OUTFILE_BASENAME=alignments/$(basename "${sequencefas}")_vs_$(basename "${assemblyfile}")
		jackhmmer -T15 \
            	--tblout "${OUTFILE_BASENAME}".tblout \
	    	--domtblout "${OUTFILE_BASENAME}".domtblout \
	    	--chkhmm "${OUTFILE_BASENAME}".chkmmtblout \
	    	"${sequencefas}" \
	    	"${assemblyfile}" \
	    	> "${OUTFILE_BASENAME}".out
		date +"[%Y-%m-%d %H:%M:%S] Finished jackhmmer for '${sequencefas}' vs '${assemblyfile}'"

		date +"[%Y-%m-%d %H:%M:%S] Starting sequence extraction for '${sequencefas}' vs '${assemblyfile}'"
		grep -v "^#" "${OUTFILE_BASENAME}".tblout | \
	    		cut -f 1 -d " " | sort | uniq >"${TEMP_ID_FILE}"
		if [ -s "${TEMP_ID_FILE}" ]
		then 
	    		SeqFilter/bin/SeqFilter -o "${OUTFILE_BASENAME}".fasta --ids "${TEMP_ID_FILE}" "${assemblyfile}"
		else
	   		echo ":/ so sad... no match for this potential toxin '${OUTFILE_BASENAME}.fasta', but generating empty file while my guitar gently weeps..."
	   		touch "${OUTFILE_BASENAME}".fasta
		fi
		date +"[%Y-%m-%d %H:%M:%S] Finished sequence extraction for '${sequencefas}' vs '${assemblyfile}'"
	done
done

# Deleting of temporary file
rm "${TEMP_ID_FILE}"
