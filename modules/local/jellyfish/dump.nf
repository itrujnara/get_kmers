process JELLYFISH_DUMP {
    tag "$meta.id"
    label 'process_single'


    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/jellyfish:2.2.10--h2d50403_0':
        'biocontainers/jellyfish:2.2.10--h2d50403_0' }"

    input:
    tuple val(meta), path(jf)

    output:
    tuple val(meta), path("*_kmers.tsv"), emit: tsv
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "${prefix}\tkmer" > ${prefix}_kmers.tsv
    jellyfish dump ${jf} | \
        tr '\\n' '\\t' | \
        tr '>' '\\n' | \
        sed 's/\\t\$//g' | \
        tail -n +2 >> ${prefix}_kmers.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jellyfish: \$(jellyfish --version |& sed '1!d ; s/jellyfish //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${prefix}_kmers.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jellyfish: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
