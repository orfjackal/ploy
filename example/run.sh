#!/bin/bash

# This command will run first the built-in 'prepare' task (which processes and 
# copies all template files) for all servers specified in example.rb, after which 
# it will run the 'deploy' task (which is defined in example.rb) for all of them. 
# Any Maven artifacts are copied from the local Maven repository defined here (no 
# remote repository support yet). The results will be in the output directory.
java -jar ../target/ploy-*.jar \
    --maven-repository "../src/test/ruby/testdata/maven-repository" \
    --config-file example.rb \
    --output-dir output \
    prepare deploy
