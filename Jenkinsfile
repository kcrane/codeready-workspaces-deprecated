#!/usr/bin/env groovy

// PARAMETERS for this pipeline:
// node == slave label, eg., rhel7-devstudio-releng-16gb-ram||rhel7-16gb-ram||rhel7-devstudio-releng||rhel7 or rhel7-32gb||rhel7-16gb||rhel7-8gb
// branchToBuildCRW = */master

def installNPM(){
	def nodeHome = tool 'nodejs-10.9.0'
	env.PATH="${env.PATH}:${nodeHome}/bin"
	sh "npm install -g yarn"
	sh "npm version"
}

def installGo(){
	def goHome = tool 'go-1.11'
	env.PATH="${env.PATH}:${goHome}/bin"
	sh "go version"
}

def CRW_path = "codeready-workspaces-deprecated"
timeout(120) {
	node("${node}"){ stage "Build ${CRW_path}"
		cleanWs()
		sh "cat /proc/cpuinfo; cat /proc/meminfo"
		sh "df -h; du -sch . ${WORKSPACE} /tmp 2>/dev/null || true"
		// for private repo, use checkout(credentialsId: 'devstudio-release')
		checkout([$class: 'GitSCM', 
			branches: [[name: "${branchToBuildCRW}"]], 
			doGenerateSubmoduleConfigurations: false, 
			poll: true,
			extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "${CRW_path}"]], 
			submoduleCfg: [], 
			userRemoteConfigs: [[url: "https://github.com/kcrane/${CRW_path}.git"]]])
		// sh "/usr/bin/time -v ${CRW_path}/build.sh"
		// archiveArtifacts fingerprint: true, artifacts: "${CRW_path}/*/target/*.tar.*"
                
                withCredentials([string(credentialsId:'devstudio-release.token', variable: 'GITHUB_TOKEN'), 
                                file(credentialsId: 'crw-build.keytab', variable: 'CRW_KEYTAB')]) {
                    def BOOTSTRAP = '''#!/bin/bash -xe
                    # initialize kerberos
                    export KRB5CCNAME=/var/tmp/crw-build_ccache
                    kinit "crw-build/codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com@REDHAT.COM" -kt ''' + CRW_KEYTAB + '''
                    klist # verify working
                    ''' + CRW_path + '''/beaker-build.sh
'''
                sh BOOTSTRAP
                }
		SHA_CRW = sh(returnStdout:true,script:"cd ${CRW_path}/ && git rev-parse --short=4 HEAD").trim()
		echo "Built ${CRW_path} from SHA: ${SHA_CRW}"
		sh "df -h; du -sch . ${WORKSPACE} /tmp 2>/dev/null || true"

		// sh 'printenv | sort'
		def descriptString="Build #${BUILD_NUMBER} (${BUILD_TIMESTAMP}) <br/> :: ${CRW_path} @ ${SHA_CRW}"
		echo "${descriptString}"
		currentBuild.description="${descriptString}"
	}
}
