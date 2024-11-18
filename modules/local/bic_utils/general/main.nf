
def getFullConditionList() {
    def inputFile = file(params.input, checkIfExists: true)
    def cond_list = []
    def sample_list = []


    // Determine the separator based on the file extension
    def separator = params.input.endsWith('tsv') ? '\t' : ','

    // Parse the file content
    inputFile.withReader { reader ->
        def header = reader.readLine().split(separator)
        def sampleIndex = header.findIndexOf { it == "sample" }
        def conditionIndex = header.findIndexOf { it == "condition" }
        
        if (sampleIndex == -1) {
            error "sample column not found in the input file"
        }

        if (conditionIndex == -1) {
            error "Condition column not found in the input file"
        }

        reader.eachLine { line ->
            def columns = line.split(separator)
            
            if (!sample_list.contains(columns[sampleIndex])) {
                cond_list << columns[conditionIndex]
                sample_list << columns[sampleIndex]
            }
        }
    }
    return cond_list
}
