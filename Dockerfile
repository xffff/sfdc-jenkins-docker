################################################################
# Dockerfile for SFDC continuous integration container
#
# Michael Murphy
################################################################

FROM jenkins
MAINTAINER Michael Murphy

ARG sfdc_ant_version=35.0
ARG sfdc_instance=cs18
ARG git_username=xffff
ARG jenkins_config_repo_name=sfdc-jenkins-config
ARG filesToIncludeInBuild_repo_name=filesToIncludeInBuild
ARG jenkins_config_plugins_filename=plugins.txt
ARG jenkins_config_git_uri=http://github.com/${git_username}/${jenkins_config_repo_name}.git

ARG filesToIncludeInBuild_uri=http://github.com/${git_username}/${filesToIncludeInBuild_repo_name}.git


USER root

# Make sure the package repository is up to date.
RUN apt-get update
RUN apt-get upgrade -y

# get required packages
RUN apt-get install -y apt-utils  \
    	    	       git  \
		       wget  \
		       unzip  \
		       ant \
                       python3 \
                       python3-lxml

# make a home directory
RUN mkdir -p /home/jenkins

# get the force.com migration tool and push to right directory
WORKDIR /home/jenkins
RUN wget https://${sfdc_instance}.salesforce.com/dwnld/SfdcAnt/salesforce_ant_${sfdc_ant_version}.zip \
    && unzip salesforce_ant_${sfdc_ant_version}.zip -d ./salesforce_ant_${sfdc_ant_version} \
    && cp ./salesforce_ant_${sfdc_ant_version}/ant-salesforce.jar /usr/share/ant/lib/ant-salesforce.jar

# clone the repo with the config and get the filesToIncludeInBuild script
WORKDIR /home/jenkins
RUN git clone ${jenkins_config_git_uri} \
    && git clone ${filesToIncludeInBuild_uri}

# install all packages required & import jobs
RUN cp ${jenkins_config_repo_name}/${jenkins_config_plugins_filename} /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt \
    && mkdir /usr/share/jenkins/ref/jobs \
    && cp -rf ./${jenkins_config_repo_name}/jobs/* /usr/share/jenkins/ref/jobs/

# drop back to the jenkins user
USER jenkins
