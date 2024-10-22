params.step = 0


// creates a metamap channel and returns it
def create_metamap(path){

    samplesheet = channel.fromPath(path)

        // Parse the CSV and create meta-map
        metaMap = samplesheet
            .splitCsv(header: true) // Split the CSV and use the first row as header
            .map { row ->
                [
                    sample: row.sample,
                    strandedness: row.strandedness,
                    fastq_1: row.fastq_1,
                    fastq_2: row.fastq_2
                ]
            }
        
    return metaMap
}


def split_by_strandedness(metaMap){

     def strandednessValues = ['auto', 'forward', 'reverse']

        // Create channels for each strandedness value
        def strandedChannels = strandednessValues.collectEntries { strandednessValue ->
            def channel = metaMap
                .filter { it.strandedness == strandednessValue }
                .map { [it.sample, it.strandedness, it.fastq_1, it.fastq_2] }

            [(strandednessValue): channel]
        }

}



workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        channel.fromPath('samplesheet.csv')
        
    }

    // Task 2 - Read in the samplesheet and create a meta-map 
    // with all metadata and another list with the filenames 
    //([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    // Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {

        in_ch = create_metamap('samplesheet.csv')
        in_ch.view()
        
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {

        metaMap = create_metamap('samplesheet.csv')
        metaMapSplit = split_by_strandedness(metaMap)
        
        metaMapSplit.each { strandednessValue, channel ->

            if (strandednessValue == 'auto') {
                println strandednessValue
                channel.view() 
            }     
        }
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {

        metaMap = create_metamap('samplesheet.csv')

        metaList = metaMap.toList() 

        groupedMap = metaList.groupBy { [it.sample, it.strandedness] }
        groupedMap.view()

    }

}