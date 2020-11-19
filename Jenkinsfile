pipeline {
  agent any
  stages {
    stage('6T') {
      parallel {
        stage('Build') {
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

}
}