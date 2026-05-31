// Define any required imports for this specific workflow
import java.nio.file.Paths
import nextflow.file.FileHelper

// Include any necessary methods
include { \
    summaryOfParams; stopNow; fastqEntryPointHelp; sendMail; conciseHelp; \
    addPadding; wrapUpHelp           } from "${params.routines}"
include { fastpHelp                  } from "${params.toolshelp}${params.fs}fastp"
include { megahitHelp                } from "${params.toolshelp}${params.fs}megahit"
include { minimap2Help               } from "${params.toolshelp}${params.fs}minimap2"
include { semibin2sebHelp            } from "${params.toolshelp}${params.fs}semibin2seb"
include { vambbindefHelp             } from "${params.toolshelp}${params.fs}vambbindef"
include { metabat2Help              } from "${params.toolshelp}${params.fs}metabat2"
include { binetteHelp                } from "${params.toolshelp}${params.fs}binette"
include { covermgenomeHelp           } from "${params.toolshelp}${params.fs}covermgenome"
include { gtdbtkclassifywfHelp       } from "${params.toolshelp}${params.fs}gtdbtkclassifywf"
include { amrfinderplusHelp          } from "${params.toolshelp}${params.fs}amrfinderplus"


// Exit if help requested before any subworkflows
if (params.help) {
    log.info help()
    exit 0
}

// Include any necessary modules and subworkflows
include { PROCESS_FASTQ              } from "${params.subworkflows}${params.fs}process_fastq"
include { FASTP                      } from "${params.modules}${params.fs}fastp${params.fs}main"
include { MEGAHIT_ASSEMBLE           } from "${params.modules}${params.fs}megahit${params.fs}assemble${params.fs}main"
include { MINIMAP2_ALIGN             } from "${params.modules}${params.fs}custom${params.fs}minimap2${params.fs}align${params.fs}main"
// include { MINIMAP2_ALIGN as \
//     REFINED_BIN_ALIGN                } from "${params.modules}${params.fs}custom${params.fs}minimap2${params.fs}align${params.fs}main"
include { SEMIBIN2_SEB               } from "${params.modules}${params.fs}semibin2${params.fs}seb${params.fs}main"
include { VAMB_BIN_DEF               } from "${params.modules}${params.fs}vamb${params.fs}bin${params.fs}default${params.fs}main"
include { METABAT2                   } from "${params.modules}${params.fs}metabat2${params.fs}main"
include { BINETTE                    } from "${params.modules}${params.fs}binette${params.fs}main"
// include { CAT_CAT                    } from "${params.modules}${params.fs}cat_cat${params.fs}main"
include { GENOMAD_ENDTOEND           } from "${params.modules}${params.fs}genomad${params.fs}endtoend${params.fs}main"
include { AMRFINDERPLUS_RUN          } from "${params.modules}${params.fs}amrfinderplus${params.fs}run${params.fs}main"
include { COVERM_GENOME              } from "${params.modules}${params.fs}coverm${params.fs}genome${params.fs}main"
include { GTDBTK_CLASSIFY_WF         } from "${params.modules}${params.fs}gtdbtk${params.fs}classify_wf${params.fs}main"
include { MAGGIC_RESULTS             } from "${params.modules}${params.fs}maggic_results${params.fs}main"
include { TABLE_SUMMARY              } from "${params.modules}${params.fs}cat${params.fs}tables${params.fs}main"
include { DUMP_SOFTWARE_VERSIONS     } from "${params.modules}${params.fs}custom${params.fs}dump_software_versions${params.fs}main"
include { MULTIQC                    } from "${params.modules}${params.fs}multiqc${params.fs}main"



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INPUTS AND ANY CHECKS FOR THE MAGGIC WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def reads_platform = 0
def strata_size = (params.strata_size ?: 15)
def abn_key = "${params.pipeline}-GlobalAbundance"
def res_key = "${params.pipeline}-Results"
def skip_key = "${params.pipeline}-SkippedBins"
def chrom_key = "${params.pipeline}-Results-Chromosome"
def plasmid_key = "${params.pipeline}-Results-Plasmid"
def virus_key = "${params.pipeline}-Results-Virus"

reads_platform += (params.input ? 1 : 0)

if (reads_platform < 1 || reads_platform == 0) {
    stopNow("Please mention at least one absolute path to input folder which contains\n" +
            "FASTQ files sequenced using the --input option.\n" +
        "Ex: --input (Illumina or Generic short reads in FASTQ format)")
}

// MetaDecoder requires container runtime (singularity or docker)
// if (!params.metadecoder_container) {
//     stopNow(
//         "MetaDecoder process requires a container image (--metadecoder_container).\n" +
//         "The MetaDecoder process uses a pre-built Singularity container.\n" +
//         "\n" +
//         "Place the container at path: ${params.container_cacheDir}:\n" +
//         "  nextflow run ... --metadecoder_container ${params.container_cacheDir}${params.fs}metadecoder.sif\n"
//     )
// }

// GTDB-Tk requires data path
checkMetadataExists(params.gtdbtk_classify_wf_data_path, 'GTDB-Tk reference database')
checkMetadataExists(params.binette_checkm2_db, 'CheckM2 database')
checkMetadataExists(params.genomad_db, 'geNomad database')
checkMetadataExists(params.amrfinderplus_db, 'NCBI AMRFinderPlus database')

if (!params.gtdbtk_classify_wf_data_path) {
    stopNow(
        "GTDB-Tk classify_wf requires a data path (--gtdbtk_classify_wf_data_path).\n" +
        "The data directory contains GTDB-Tk reference databases.\n" +
        "\n" +
        "Example: --gtdbtk_classify_wf_data_path /hpc/db/gtdb-tk/release220\n"
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN THE MAGGIC WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MAGGIC {
    main:
        log.info summaryOfParams()

        PROCESS_FASTQ()

        PROCESS_FASTQ.out.versions
            .set { software_versions }

        PROCESS_FASTQ.out.processed_reads
            .set { ch_processed_reads }

        FASTP( ch_processed_reads )

        FASTP.out.passed_reads
            .toSortedList { a, b -> a[0].id <=> b[0].id }
            .flatMap{ all_reads -> all_reads }
            .set { ch_processed_reads }

        FASTP.out.json
            .map { meta, json -> [ json ] }
            .collect( sort: true )
            .set { ch_multiqc }

        MEGAHIT_ASSEMBLE( ch_processed_reads )

        // Filter out reads for which megahit assembly failed
        ch_processed_reads
            .join( MEGAHIT_ASSEMBLE.out.assembly )
            .map { meta, reads, asm -> [meta, reads] }
            .tap { ch_strata_reads }
            .set { ch_processed_reads }

        // ch_processed_reads
        //     .map { meta, filtered_reads ->
        //         def new_meta = meta + [id: abn_key]
        //         [ new_meta, filtered_reads ]
        //     }
        //     .groupTuple()
        //     .map { meta, filtered_reads_list ->
        //         [ meta, filtered_reads_list.flatten() ]
        //     }
        //     .set { ch_coverm_genome_input_reads }

        // Multi-sample binning
        if (!params.multi_sample_strata) {
            ch_processed_reads
                .combine( MEGAHIT_ASSEMBLE.out.assembly )
                // .map { meta, reads, asm_meta, asm ->
                //     // def new_meta = meta + [id: "${meta.id}_v_${meta2.id}"]
                //     [meta, reads, asm_meta, asm]
                // }
                .set { ch_mapping_all_v_all }
        } else {
            // Systematic staggered sampling: selects strata_size samples
            // equidistant across the full sorted list to maximize
            // coverage diversity while preserving cache validity.
            ch_strata_reads
                .toSortedList { a, b -> a[0].id <=> b[0].id }
                .flatMap { all_reads ->
                    def n = all_reads.size()
                    def k = strata_size.toInteger()

                    if (n <= k) {
                        all_reads
                    } else {
                        def indices = (0..<k).collect { idx ->
                            Math.floor(idx * n / k).toInteger()
                        }
                        indices.collect { idx -> all_reads[idx] }
                    }
                }
                .combine( MEGAHIT_ASSEMBLE.out.assembly )
                .set { ch_mapping_all_v_all }
            
            // ch_mapping_all_v_all.subscribe( onComplete: { 
            //     println "Inspect indices..."
            //     System.exit(0) 
            // })

            // This is asynchronous, but not sure if cache is not invalidated
            // ch_strata_reads
            //     .combine( MEGAHIT_ASSEMBLE.out.assembly )
            //     .groupTuple( by: 2, size: strata_size.toInteger(), remainder: true )
            //     .flatMap { read_metas, reads_list, asm_meta, asm ->
            //         [ read_metas, reads_list ]
            //             .transpose()
            //             .sort { a, b -> a[0].id <=> b[0].id }
            //             .take( strata_size.toInteger() )
            //             .collect { read_meta, read ->
            //                 tuple( read_meta, read, asm_meta, asm )
            //             }
            //     }
            //     .view()
            //     .set { ch_mapping_all_v_all }
        }

        MINIMAP2_ALIGN( ch_mapping_all_v_all )

        MINIMAP2_ALIGN.out.bam
            .groupTuple()
            .set { ch_mm2_all_aligned }

        MINIMAP2_ALIGN.out.bai
            .groupTuple()
            .set { ch_mm2_all_aligned_bai }

        VAMB_BIN_DEF(
            MEGAHIT_ASSEMBLE.out.assembly
            .join( ch_mm2_all_aligned )
        )

        SEMIBIN2_SEB(
            MEGAHIT_ASSEMBLE.out.assembly
                .join( ch_mm2_all_aligned )
        )

        METABAT2(
            MEGAHIT_ASSEMBLE.out.assembly
                .join( ch_mm2_all_aligned )
                .join( ch_mm2_all_aligned_bai )
        )

        MEGAHIT_ASSEMBLE.out.assembly
            .join( VAMB_BIN_DEF.out.bins, remainder: true )
            .join( SEMIBIN2_SEB.out.bins, remainder: true )
            .join( METABAT2.out.bins, remainder: true )
            .map { meta, asm, vamb_bins, seb_bins, md_bins ->
                def all_bins = [vamb_bins, seb_bins, md_bins]
                    .flatten()
                    .findAll { bin -> bin != null }
                [ meta, asm, all_bins ]
            }
            .set { ch_binette_input }

        ch_binette_input
            .filter { meta, asm, all_bins -> 
                all_bins.size() >= 2
            }
            .set { ch_binette_passed }

        ch_binette_input
            .filter { meta, asm, all_bins ->
                all_bins.size() < 2 
            }
            .map { meta, asm, all_bins ->
                [
                    meta.id,
                    "${all_bins.size()}\tBins from at least two binners are required."
                ]
            }
            .set { ch_binette_skipped }

        BINETTE( ch_binette_passed )

        // What samples failed BINETTE merge
        ch_processed_reads
            .map { meta, reads ->
                [ meta.id, meta ]
            }
            .join( ch_binette_skipped, remainder: true)
            .filter{ id, reads_meta, bins_skipped_reason ->
                bins_skipped_reason == null
            }
            .map { id, reads_meta, bins_skipped_reason ->
                [ reads_meta, bins_skipped_reason ]
            }
            .join( BINETTE.out.bins, remainder: true )
            .filter { meta, bins_skipped_reason, binette_failed ->
                binette_failed == null
            }
            .map { meta, reads, binette_failed ->
                "${meta.id}\t>= 2\tBinette failed to created merged bins.\n"
            }
            .mix(
                ch_binette_skipped
                    .map { id, reason ->
                        "${id}\t${reason}\n"
                    }
            )
            .collectFile(
                name:     'FAILED_SAMPLES.tsv',
                seed:     "Sample\tNumber of Binners Succeeded\tReason\n",
                newLine:  false
            )
            .map { skipped_samples ->
                def new_meta = Map[:]
                new_meta.id = skip_key
                [ new_meta, skipped_samples ]
            }
            .set { ch_skipped_samples }


        BINETTE.out.bins
            .map { meta, bins ->
                [ meta, [bins].flatten() ]
            }
            .flatMap { meta, bins ->
                bins.collect { faFile ->
                    def binName = faFile.baseName
                    def newMeta = meta + [id: binName]
                    [ newMeta, file( faFile ) ]
                }
                .sort { bin -> bin[0].id }
            }
            .set { ch_indiv_bins }

        GENOMAD_ENDTOEND(
            ch_indiv_bins,
            channel.value( file( params.genomad_db ) )
        )

        GENOMAD_ENDTOEND.out.virus_summary
            .mix( GENOMAD_ENDTOEND.out.plasmid_summary )
            .map { meta, file -> file }
            .collect( sort: true )
            .map { all_files ->
                def meta = [ id: res_key ]
                [ meta, all_files ]
            }
            .set { ch_maggic_results_genomad }

        AMRFINDERPLUS_RUN(
            ch_indiv_bins,
            channel.value( file( params.amrfinderplus_db ) )
        )

        AMRFINDERPLUS_RUN.out.report
            .map { meta, report -> report }
            .collect( sort: true )
            .map { reports ->
                def new_meta = Map[:]
                new_meta.id = res_key
                [ new_meta, reports ]
            }
            .set { ch_maggic_results_amrfinderplus }

        GTDBTK_CLASSIFY_WF(
            BINETTE.out.bins
        )

        GTDBTK_CLASSIFY_WF.out.results
            .map { meta, results_dir -> results_dir }
            .collect( sort: true )
            .map { results_dirs ->
                def new_meta = Map[:]
                new_meta.id = res_key
                [ new_meta, results_dirs ]
            }
            .set { ch_maggic_results_gtdbtk_classify_wf }

        BINETTE.out.bins
            .map { meta, bins -> bins } 
            .collect( sort: true )
            .flatten()
            .map { bins -> 
                def new_meta = Map[:]
                new_meta.id = abn_key
                [ new_meta, bins ]
            }
            .groupTuple()
            .set { ch_binette_refined_bins }

        BINETTE.out.quality_report
            .map { meta, quality_report -> quality_report }
            .collectFile(
                name: 'ALL_REFINED_BINS_QUALITY_REPORT.tsv',
                keepHeader: true,
                skip: 1,
                sort: true
            )
            .map { quality_report -> 
                def new_meta = Map[:]
                new_meta.id = abn_key
                [ new_meta, quality_report ]
            }
            .set { ch_all_refined_bins_qual_report }

        COVERM_GENOME (
            ch_processed_reads
                .combine(
                    ch_binette_refined_bins
                        .join( ch_all_refined_bins_qual_report )
                ),
            false,
            false,
        )

        COVERM_GENOME.out.coverage
            .map { meta, cov -> cov }
            .collect( sort: true )
            .map { all_covs ->
                def meta = [ id: res_key ]
                [ meta, all_covs ]
            }
            .set { ch_maggic_results_coverm }

        MAGGIC_RESULTS(
            ch_maggic_results_gtdbtk_classify_wf
                .join( ch_maggic_results_genomad )
                .join( ch_maggic_results_amrfinderplus )
                .join( ch_maggic_results_coverm )
                .join(
                    ch_all_refined_bins_qual_report
                        .map { meta, all_bins_qual_reports ->
                            def new_meta = meta + [id: res_key]
                            [ new_meta, all_bins_qual_reports ]
                    }
                )
        )

        TABLE_SUMMARY(
            ch_skipped_samples
                .mix(
                    MAGGIC_RESULTS.out.results,
                    MAGGIC_RESULTS.out.chromosome_results
                        .map { meta, tsv ->
                            def new_meta = [ id: chrom_key ]
                            [ new_meta, tsv ]
                        },
                    MAGGIC_RESULTS.out.plasmid_results
                        .map { meta, tsv ->
                            def new_meta = [ id: plasmid_key ]
                            [ new_meta, tsv ]
                        },
                    MAGGIC_RESULTS.out.virus_results
                        .map { meta, tsv ->
                            def new_meta = [ id: virus_key ]
                            [ new_meta, tsv ]
                        },
                    MAGGIC_RESULTS.out.abundance
                        .map { meta, abn ->
                            def new_meta = meta + [id: abn_key]
                            [ new_meta, abn ]
                        }
                )
        )

        DUMP_SOFTWARE_VERSIONS (
            software_versions
                .mix(
                    FASTP.out.versions.ifEmpty(null),
                    MEGAHIT_ASSEMBLE.out.versions.ifEmpty(null),
                    MINIMAP2_ALIGN.out.versions.ifEmpty(null),
                    VAMB_BIN_DEF.out.versions.ifEmpty(null),
                    SEMIBIN2_SEB.out.versions.ifEmpty(null),
                    METABAT2.out.versions.ifEmpty(null),
                    BINETTE.out.versions.ifEmpty(null),
                    AMRFINDERPLUS_RUN.out.versions.ifEmpty(null),
                    GENOMAD_ENDTOEND.out.versions.ifEmpty(null),
                    COVERM_GENOME.out.versions.ifEmpty(null),
                    GTDBTK_CLASSIFY_WF.out.versions.ifEmpty(null),
                    MAGGIC_RESULTS.out.versions.ifEmpty(null),
                    TABLE_SUMMARY.out.versions.ifEmpty(null)
                )
                .unique()
                .collectFile( name: 'collected_versions.yml' )
        )

        MULTIQC(
            ch_multiqc
                .mix(
                    TABLE_SUMMARY.out.mqc_yml,
                    MAGGIC_RESULTS.out.mqc_yml,
                    DUMP_SOFTWARE_VERSIONS.out.mqc_yml
                )
                .collect( sort: true )
        )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ON COMPLETE, SHOW GORY DETAILS OF ALL PARAMS WHICH WILL BE HELPFUL TO DEBUG
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (workflow.success) {
        sendMail()
    }
}

workflow.onError {
    sendMail()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    METHOD TO CHECK METADATA EXISTENCE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def checkMetadataExists(file_path, msg) {
    file_path_obj = file( file_path )

    if (!file_path_obj.exists() || file_path_obj.size() == 0) {
        stopNow("Please check if your ${msg} path (or file)\n" +
            "[ ${file_path} ]\nexists and is not of size 0.")
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELP TEXT METHODS FOR MAGGIC WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def help() {

    Map helptext = [:]
    Map maggicConcatHelp = [:]
    Map fastpAdapterHelp = [:]
    Map nH = [:]
    def uHelp = (params.help.getClass().toString() =~ /String/ ? params.help.tokenize(',').join(' ') : '')

    Map defaultHelp = [
        '--help fastp'                  : 'Show fastp CLI options',
        '--help megahit'                : 'Show megahit CLI options',
        '--help minimap2'               : 'Show minimap2 CLI options',
        '--help seb'                    : 'Show SemiBin2 `single_easy_bin` CLI options',
        '--help vamb'                   : 'Show vamb `bin def` CLI options',
        '--help binette'                : 'Show binette CLI options',
        '--help gtdbtk'                 : 'Show gtdbtk classify_wf CLI options',
        '--help abundance'              : 'Show coverm `genome` CLI options',
        '--help amrfinderplus'          : 'Show AMRFinderPlus CLI options',
        '--help metabat2'               : 'Show metabat2 CLI options'
    ]

    fastpAdapterHelp['--fastp_use_custom_adapaters'] = "Use custom adapter FASTA with fastp on top of " +
        "built-in adapter sequence auto-detection. Enabling this option will attempt to find and remove " +
        "all possible Illumina adapter and primer sequences but will make the workflow run slow. " +
        "Default: ${params.fastp_use_custom_adapters}"

    if (params.help.getClass().toString() =~ /Boolean/ || uHelp.size() == 0) {
        println conciseHelp('fastp,megahit')
        helptext.putAll(defaultHelp)
    } else {
        params.help.tokenize(',').each { h ->
            if (defaultHelp.keySet().findAll{ it =~ /(?i)\b${h}\b/ }.size() == 0) {
                println conciseHelp('fastp,megahit')
                stopNow("Tool [ ${h} ] is not a part of ${params.pipeline} pipeline.")
            }
        }

        helptext.putAll(
            fastqEntryPointHelp() +
            maggicConcatHelp +
            (uHelp =~ /(?i)\bfastp/ ? fastpHelp(params).text + fastpAdapterHelp : nH) +
            (uHelp =~ /(?i)\bmegahit/ ? megahitHelp(params).text : nH) +
            (uHelp =~ /(?i)\bseb/ ? semibin2sebHelp(params).text : nH) +
            (uHelp =~ /(?i)\bvamb/ ? vambbindefHelp(params).text : nH) +
            (uHelp =~ /(?i)\bbinette/ ? binetteHelp(params).text : nH) +
            (uHelp =~ /(?i)\bgtdbtk/ ? gtdbtkclassifywfHelp(params).text : nH) +
            (uHelp =~ /(?i)\bminimap2/ ? minimap2Help(params).text : nH) +
            (uHelp =~ /(?i)\babundance/ ? covermgenomeHelp(params).text : nH) +
            (uHelp =~ /(?i)\bamrfinderplus/ ? amrfinderplusHelp(params).text : nH) +
            (uHelp =~ /(?i)\bmetabat2/ ? metabat2Help(params).text : nH) +
            wrapUpHelp()
        )
    }

    return addPadding(helptext)
}