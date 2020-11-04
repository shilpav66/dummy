node('master') {
    stage('checkout') {
    }
    stage('build') {
    bat script: '''C:/Users/shilv/.jenkins/workspace/GPSV3/GPSV3_2015.sln /p:Configuration=Release /p:Platform=x86'''
    }
    stage('Testing') {
    echo 'Testing'
    }
    stage('Deploy') {
    echo 'Deploying'
    }
}
