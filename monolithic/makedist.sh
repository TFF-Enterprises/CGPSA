#!/bin/sh
echo "Creating cgpsa-$1.tgz"
mkdir cgpsa-$1
cp -p cgpsa cgpsa.conf CLI.pm README documentation.html style.css cgpsa-$1
tar cvfz /data/www/tff/content/cgpsa/releases/cgpsa-$1.tgz cgpsa-$1 
echo "Updating documentation..."
cp documentation.html /data/www/tff/content/cgpsa/index.html
echo "Updating symlink..."
cd /data/www/tff/content/cgpsa
rm cgpsa.tgz
ln -s releases/cgpsa-$1.tgz cgpsa.tgz
echo "Done!"
