pipeline {
  agent any
  stages {
    stage('Build') {
      parallel {
        stage('6T') {
          steps {
            script {
              step([$class: 'SQLPlusRunnerBuilder', credentialsId: 'DB_login',
              customOracleHome: '', customSQLPlusHome: '', customTNSAdmin: '',
              instance: 'PTGPS6T.ikeadt.com', script: 'Package_test.sql', ])
            }

          }
        }

        stage('3T') {
          steps {
            script {
              step([$class: 'SQLPlusRunnerBuilder', credentialsId: 'DB_login',
              customOracleHome: '', customSQLPlusHome: '', customTNSAdmin: '',
              instance: 'PTGPS6T.ikeadt.com', script: 'Package_test.sql',
              //scriptContent: 'ALTER PACKAGE TEST_SCIPT COMPILE PACKAGE', scriptType: 'file'
            ])
          }

        }
      }

    }
  }

  stage('Test') {
    steps {
      script {
        bat script:'pytest --html=report.html --disable-warnings --cov=test_scripts .'
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, includes: '**/*', keepAll: false, reportDir: 'C:\\Users\\shilv\\.jenkins\\workspace\\Database_deploy_pipe', reportFiles: 'report.html', reportName: 'HTML Report'])
      }

    }
  }

}
}