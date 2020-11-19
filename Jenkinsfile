pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        script {
          step([$class: 'SQLPlusRunnerBuilder', credentialsId: 'DB_login',
          customOracleHome: '', customSQLPlusHome: '', customTNSAdmin: '',
          instance: 'PTGPS6T.ikeadt.com', script: 'Package_test.sql', ])
        }

      }
    }

  }
}