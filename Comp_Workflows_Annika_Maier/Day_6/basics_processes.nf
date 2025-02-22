params.step = 0
params.zip = 'zip'



process UPPERCASE{

        debug true

        input:
        val input_string

        output:
        path "helloWorld_Uppercase.txt"

        script:

        uppercase = input_string.toUpperCase()

        """
        echo "Changing ${input_string} to ${uppercase}"
        echo ${uppercase} > helloWorld_Uppercase.txt
        """

        }


process ZIP{
            debug true 

            input:
            path uppercase

            output:
            path "*.*"

            script:
            if (params.zip == 'gzip') {
                """
                echo input ${uppercase}
                gzip -c ${uppercase} > ${uppercase}.gz
                echo output ${uppercase}.gz
                """
            } else if (params.zip == 'bzip2') {
                """
                echo input ${uppercase}
                bzip2 -c ${uppercase} > ${uppercase}.bz2
                echo output ${uppercase}.bz2
                """
            } else if (params.zip == 'zip') {
                """
                echo input ${uppercase}
                zip ${uppercase}.zip ${uppercase}
                echo output ${uppercase}.zip
                """
            } else {
                error "Unsupported compression method: ${params.zip}"
            }
        }


workflow {

    // Task 1 - create a process that says Hello World! 
    //(add debug true to the process right after initializing 
    //to be sable to print the output to the console)
    if (params.step == 1) {

        process SAYHELLO {
        debug true

        """
        echo 'Hello world!' 
        """
        }

        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! 
    // using Python
    if (params.step == 2) {

        process SAYHELLO_PYTHON {
        debug true

        """
        #!/usr/bin/python3

        x = 'Hello '
        y = 'world!'
        print(x,y)
        """
        }

        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string 
    // "Hello world!" from a channel and write it to command line
    if (params.step == 3) {

        process SAYHELLO_PARAM{

        debug true

        input:
        val input_string

        script:
        """
        echo ${input_string}
        """

        }

        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string
    // "Hello world!" from a channel and write it to a file.
    // WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {

        process SAYHELLO_FILE{

        debug true

        input:
        val input_string

        output:
        path 'helloWorld.txt'

        script:


        """
        echo "Writing helloWorld.txt file to " $PWD
        echo ${input_string} > helloWorld.txt
        """

        }

        greeting_ch = Channel.of("Hello world!")
        greeting_ch.dump(tag: "checking greeting_ch")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and
    // converts it to uppercase and saves it to a file as output.
    // View the path to the file in the console
    if (params.step == 5) {

        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file 
    // from UPPERCASE and print the content to the console (debug true).
    // WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {

        process PRINTUPPER{

        debug true

        input:
        path uppercase

        script:

        """
        less ${uppercase}
        """
        }

        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" 
    // (see at the head of the file), 
    //create a process that zips the file created in the 
    // UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    // Print out the path to the zipped file in the console
    if (params.step == 7) {


        greeting_ch = Channel.of("Hello world!")
        println "params.zip"
        println params.zip
        uppercase_path = UPPERCASE(greeting_ch)
        ZIP(uppercase_path)
        
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {

        process ZIP_FILES{


            debug true

            input:
            path uppercase_path

            output:
            path "*.zip"
            path "*.gz"
            path "*.bz2"

            script:
            """
            echo "uppercase_path"
            echo ${uppercase_path}
            gzip -c "${uppercase_path}" > "${uppercase_path}.gz"
            bzip2 -c "${uppercase_path}" > "${uppercase_path}.bz2"
            zip "${uppercase_path}.zip" "${uppercase_path}"
            echo "Zipped file locations:"
            echo "${uppercase_path}.gz"
            echo "${uppercase_path}.bz2"
            echo "${uppercase_path}.zip"
            """
        }

    

    greeting_ch = Channel.of("Hello world!")
    uppercase_path = UPPERCASE(greeting_ch)
    println "uppercase path nextflow"
    println uppercase_path
    ZIP_FILES(uppercase_path)

   
}

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

if (params.step == 9) {

    in_ch = Channel.of(
        ['name': 'Harry', 'title': 'student'],
        ['name': 'Ron', 'title': 'student'],
        ['name': 'Hermione', 'title': 'student'],
        ['name': 'Albus', 'title': 'headmaster'],
        ['name': 'Snape', 'title': 'teacher'],
        ['name': 'Hagrid', 'title': 'groundkeeper'],
        ['name': 'Dobby', 'title': 'hero'],
    )

    process WRITETOFILE {
        
        input:
        val input_data

        output:
        path 'results/names.tsv'

        script:
        output = "${input_data['name']}\t${input_data['title']}"
        """
        mkdir -p results
        echo -e '${output}' > results/names.tsv
        """
    }

    WRITETOFILE(in_ch)
}



}