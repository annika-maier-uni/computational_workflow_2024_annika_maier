#!/usr/bin/env nextflow

// creates a metamap and returns it
def create_metamap(path){

    samplesheet = channel.fromPath(path)


        // Parse the CSV and create meta-map
        metaMap = samplesheet
            .splitCsv(header: true) // Split the CSV and use the first row as header
            .map { row ->
                [
                    block_size: row.block_size,
                    input_str: row.input_str,
                    out_name: row.out_name,
                ]
            }

    return metaMap
}


// takes as input a metaMap
// with block_size (int) and input_str(string)
process SPLITLETTERS {
    publishDir "results", mode: 'copy'

    debug true

    input:
    tuple val(block_size), val(in_str), val(out_name)

    output:
    path "${out_name}_*.txt"

    script:
    """
    #echo "printing SPLITLETTERS info"
    #echo "Block Size: ${block_size}"
    #echo "String: ${in_str}"
    #echo "Prefix: ${out_name}"
    echo "$in_str" | fold -w $block_size | awk '{ print > "${out_name}_"NR".txt" }'
  
    #for file in ${out_name}_*.txt; do
        #echo "Contents of \$file:"
        #cat \$file
        #echo ""
    #done
    """
} 


process CONVERTTOUPPER{

    debug true

    input:
    path input_path

    script:
    """
    upper_str=\$(cat ${input_path} | tr '[:lower:]' '[:upper:]')
    echo \$upper_str
    """

    }


workflow { 

    metaMap = create_metamap('samplesheet_2.csv')

    block_size_path = SPLITLETTERS(metaMap)

    CONVERTTOUPPER(block_size_path)
}