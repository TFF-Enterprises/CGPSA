#!/bin/sh
echo "Creating cgpsa-$1.tgz"
mkdir cgpsa-$1
cp -p beta/cgpsa beta/cgpsa.conf beta/CLI.pm beta/README beta/documentation.html beta/style.css cgpsa-$1
tar cvfz /data/www/tff/content/cgpsa/betas/cgpsa-$1.tgz cgpsa-$1 
echo "Updating documentation..."
cp documentation.html /data/www/tff/content/cgpsa/index.html
cp beta/documentation.html /data/www/tff/content/cgpsa/betas/index.html
echo "Done!"