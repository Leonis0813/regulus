pipeline {
  agent any

  parameters {
    string(name: 'REGULUS_VERSION', defaultValue: '', description: 'デプロイするバージョン')
    string(name: 'SUBRA_BRANCH', defaultValue: 'master', description: 'Chefのブランチ')
    choice(name: 'SCOPE', choices: 'app\nfull', description: 'デプロイ範囲')
  }

  stages {
    stage('Test') {
      steps {
        sh 'touch test'
      }
    }

    stage('Clone Chef') {
      steps {
        git url: 'https://github.com/Leonis0813/subra.git', branch: params.SUBRA_BRANCH
      }
    }

    stage('Deploy') {
      steps {
        script {
          def version = (params.REGULUS_VERSION == '' ? env.GIT_BRANCH : params.REGULUS_VERSION)
          version = version.replaceFirst(/^.+\//, '')
          def recipe = ('app' == params.SCOPE ? 'app' : 'default')
          deleteDir()
          //sh "sudo REGULUS_VERSION=${version} chef-client -z -r regulus::${recipe} -E ${env.ENVIRONMENT}"
        }
      }
    }
  }
}
