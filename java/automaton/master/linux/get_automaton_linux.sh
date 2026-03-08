#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/cs-au-dk/dk.brics.automaton.git automaton
cd automaton
mvn clean package
ls target/
