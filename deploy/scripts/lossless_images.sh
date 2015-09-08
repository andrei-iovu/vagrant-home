#!/usr/bin/env bash

echo
echo "###########################################################"
echo
echo ">>> INSTALARE PACHETE PT RECOMPRESIE LOSSLESS A IMAGINILOR"

echo "*** INSTALARE DEPENDINTE ... ***"
echo
apt-get install -y checkinstall libjpeg62-dev
echo "DONE"
echo

echo "*** INSTALARE OPTIPNG ... ***"
echo
cd ~
wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-0.7.5/optipng-0.7.5.tar.gz
tar xvf optipng-0.7.5.tar.gz
cd optipng-0.7.5/
./configure
make
checkinstall --install -y
echo

echo "*** INSTALARE JPEGOPTIM ... ***"
echo
cd ~
wget http://www.kokkonen.net/tjko/src/jpegoptim-1.4.3.tar.gz
tar xvf jpegoptim-1.4.3.tar.gz
cd jpegoptim-1.4.3/
./configure
make
checkinstall --install -y
echo

echo "DONE INSTALARE PACHETE PT RECOMPRESIE LOSSLESS A IMAGINILOR"
echo