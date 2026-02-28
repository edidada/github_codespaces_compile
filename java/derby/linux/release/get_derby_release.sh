#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/apache/derby.git
cd derby
which ant
ant buildsource
ant buildjars
