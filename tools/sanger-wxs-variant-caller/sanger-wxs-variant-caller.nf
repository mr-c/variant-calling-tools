#!/usr/bin/env nextflow

/*
 * Copyright (c) 2020, Ontario Institute for Cancer Research (OICR).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

/*
 * author Linda Xiang <linda.xiang@oicr.on.ca>
 */

nextflow.preview.dsl=2
version = '3.1.6-3'

params.ref_genome_tar = ""
params.vagrent_annot = ""
params.ref_snv_indel_tar = ""
params.tumour = ""
params.tumourIdx = ""
params.normal = ""
params.normalIdx = ""
params.exclude = "chrUn%,HLA%,%_alt,%_random,chrM,chrEBV"
params.species = "human"
params.assembly = "GRCh38"
params.skipannot = false
params.container_version = ""
params.cpus = 18
params.mem = 32  // GB


def getSangerWxsSecondaryFiles(main_file){  //this is kind of like CWL's secondary files
  def all_files = []
  for (ext in ['.bas']) {
    all_files.add(main_file + ext)
  }
  return all_files
}

process sangerWxsVariantCaller {
  container "quay.io/icgc-argo/sanger-wxs-variant-caller:sanger-wxs-variant-caller.${params.container_version ?: version}"

  cpus params.cpus
  memory "${params.mem} GB"

  tag "${tumour.size()}"

  input:
    path reference
    path annot
    path snv_indel
    path tumour
    path tidx
    path tumour_bas
    path normal
    path nidx
    path normal_bas

  output:
    path "run.params", emit: run_params
    path "WXS_*_vs_*.result.tar.gz", emit: result_archive
    path "WXS_*_vs_*.timings.tar.gz", emit: timings

  script:
    arg_skipannot = params.skipannot ? "-skipannot" : ""
    """
    /opt/wtsi-cgp/bin/ds-cgpwxs.pl \
      -cores ${task.cpus} \
      -reference ${reference} \
      -annot ${annot} \
      -snv_indel ${snv_indel} \
      -tumour ${tumour} \
      -tidx ${tidx} \
      -normal ${normal} \
      -nidx ${nidx} \
      -exclude ${params.exclude} \
      -species ${params.species} \
      -assembly ${params.assembly} \
      ${arg_skipannot} \
      -outdir \$PWD
    """
}
