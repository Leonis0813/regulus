pipeline {
  agent any

  environment {
    PATH = '/usr/local/rvm/bin:/usr/bin:$PATH'
  }

  parameters {
    string(name: 'REGULUS_VERSION', defaultValue: '', description: 'デプロイするバージョン')
    string(name: 'SUBRA_BRANCH', defaultValue: 'master', description: 'Chefのブランチ')
    choice(name: 'SCOPE', choices: 'app\nfull', description: 'デプロイ範囲')
  }

  stages {
    stage('Install gems') {
      steps {
        script {
          def version = (params.REGULUS_VERSION == '' ? env.GIT_BRANCH : params.REGULUS_VERSION)
          version = version.replaceFirst(/^.+\//, '')
          git url: 'https://github.com/Leonis0813/regulus.git', branch: version
          sh 'bundle install --path=vendor/bundle'
        }
      }
    }

    stage('Test') {
      steps {
        sh 'rvm 2.3.7 do bundle exec rake spec:models'
      }
    }

    stage('Clone Chef') {
      steps {
        sh "sudo rm -rf ${env.WORKSPACE}/* ${env.WORKSPACE}/.chef* ${env.WORKSPACE}/.git*"
        sh 'ls -a'
        git url: 'https://github.com/Leonis0813/subra.git', branch: params.SUBRA_BRANCH
      }
    }

    stage('Deploy') {
      steps {
        script {
          def version = (params.REGULUS_VERSION == '' ? env.GIT_BRANCH : params.REGULUS_VERSION)
          version = version.replaceFirst(/^.+\//, '')
          def recipe = ('app' == params.SCOPE ? 'app' : 'default')
          //sh "sudo REGULUS_VERSION=${version} chef-client -z -r regulus::${recipe} -E ${env.ENVIRONMENT}"
        }
      }
    }
  }
}
