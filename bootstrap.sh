#!usr/bin/env bash

CLIFF_VERSION=2.1.1

echo "Installing basic packages..."
sudo apt-get update
sudo apt-get -y install git curl vim unzip htop openjdk-7-jre openjdk-7-jdk maven

echo "Configuring Java and things"

curl https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/bashrc > ~/.bashrc
source .bashrc

sudo chmod 777 /usr/lib/jvm/java-7-openjdk-amd64
sudo chmod 777 -R /usr/lib/jvm/java-7-openjdk-amd64/*

# Why does stupid Maven install Java 6? Tell it again that we do indeed want Java 7
set JRE_HOME=/usr/lib/jvm/java-7-openjdk-amd64
sudo update-alternatives --set java 2

echo "Download Tomcat"
wget http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.59/bin/apache-tomcat-7.0.59.tar.gz 
tar -xvzf apache-tomcat-7.0.59.tar.gz
#sudo rm apache-tomcat-7.0.59.tar.gz

# get tomcat users set up correctly
curl https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/tomcat-users.xml > apache-tomcat-7.0.59/conf/tomcat-users.xml

echo "Boot Tomcat"
$CATALINA_HOME/bin/startup.sh

echo "Download CLIFF"
curl https://github.com/c4fcm/CLIFF/releases/download/v$CLIFF_VERSION/CLIFF-$CLIFF_VERSION.war > apache-tomcat-7.0.59/webapps/CLIFF-$CLIFF_VERSION.war

echo "Downloading CLAVIN..."
git clone https://github.com/Berico-Technologies/CLAVIN.git
cd CLAVIN
git checkout 2.0.0
echo "Downloading placenames file from Geonames..."
sudo wget http://download.geonames.org/export/dump/allCountries.zip
sudo unzip allCountries.zip
sudo rm allCountries.zip

echo "Compiling CLAVIN"
sudo mvn compile

echo "Building Lucene index of placenames--this is the slow one"
MAVEN_OPTS="-Xmx4g" mvn exec:java -Dexec.mainClass="com.bericotech.clavin.index.IndexDirectoryBuilder"

sudo mkdir /etc/cliff2
sudo ln -s `pwd`/CLAVIN/IndexDirectory /etc/cliff2/IndexDirectory

cd ..
mkdir .m2
curl https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/settings.xml > .m2/settings.xml

echo "Move files around and redeploy"
sudo apache-tomcat-7.0.59/bin/shutdown.sh
sudo apache-tomcat-7.0.59/bin/startup.sh
