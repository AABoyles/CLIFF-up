#!/usr/bin/env bash

CLAVIN_VERSION=2.0.0
CLIFF_VERSION=2.1.1
TOMCAT_VERSION=7.0.59

echo "Installing basic packages..."
sudo apt-get update
sudo apt-get -y install git curl vim unzip htop openjdk-7-jre openjdk-7-jdk maven
sudo apt-get -y upgrade

echo "Configuring Java and things"

curl https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/bashrc > ~/.bashrc
source .bashrc

sudo chmod 777 /usr/lib/jvm/java-7-openjdk-amd64
sudo chmod 777 -R /usr/lib/jvm/java-7-openjdk-amd64/*

echo "Downloading Tomcat..."
curl http://archive.apache.org/dist/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar -xz

# get tomcat users set up correctly
curl https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/tomcat-users.xml > apache-tomcat-$TOMCAT_VERSION/conf/tomcat-users.xml

echo "Booting Tomcat..."
sudo apache-tomcat-$TOMCAT_VERSION/bin/startup.sh

echo "Downloading CLIFF..."
curl https://github.com/c4fcm/CLIFF/releases/download/v$CLIFF_VERSION/CLIFF-$CLIFF_VERSION.war > apache-tomcat-$TOMCAT_VERSION/webapps/CLIFF-$CLIFF_VERSION.war

echo "Downloading CLAVIN..."
curl https://codeload.github.com/Berico-Technologies/CLAVIN/tar.gz/$CLAVIN_VERSION | tar -xz
cd CLAVIN-$CLAVIN_VERSION
echo "Downloading placenames file from Geonames..."
#curl http://download.geonames.org/export/dump/allCountries.zip > allCountries.zip
cp /vagrant/allCountries.zip .
unzip allCountries.zip
rm allCountries.zip

echo "Compiling CLAVIN..."
mvn compile

echo "Building Lucene index of placenames..."
MAVEN_OPTS="-Xmx6g" mvn exec:java -Dexec.mainClass="com.bericotech.clavin.index.IndexDirectoryBuilder"

sudo mkdir /etc/cliff2
sudo ln -s `pwd`/IndexDirectory /etc/cliff2/IndexDirectory

cd ..
mkdir .m2
curl https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/settings.xml > .m2/settings.xml

echo "Moving files around and redeploying..."
sudo apache-tomcat-$TOMCAT_VERSION/bin/shutdown.sh
sudo apache-tomcat-$TOMCAT_VERSION/bin/startup.sh

