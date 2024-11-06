process JELLYFISH_COUNT {
    tag "$meta.id"
    label 'process_medium'


    conda "jellyfish=2.2.10"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/jellyfish:2.2.10--h6bb024c_1':
        'biocontainers/jellyfish:2.2.10--h6bb024c_1' }"

    input:
    tuple val(meta), path(genome)
    val kmer_size

    output:
    tuple val(meta), path("*.jf"), emit: jf
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_${kmer_size}mers"
    def unzip  = genome ==~ /.*\.gz$/ ? 'zcat' : 'cat'
    """
    ${unzip} ${genome} |
    jellyfish count \
        -m ${kmer_size} \
        -t ${task.cpus} \
        -o ${prefix}.jf \
        ${args} \
        /dev/stdin

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jellyfish: \$(jellyfish --version |& sed '1!d ; s/jellyfish //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.jf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jellyfish: \$(jellyfish --version |& sed '1!d ; s/jellyfish //')
    END_VERSIONS
    """
}
