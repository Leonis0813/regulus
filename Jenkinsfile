pipeline {
  agent any

  environment {
    PATH = '/usr/local/rvm/bin:/usr/bin:/bin'
  }

  parameters {
    string(name: 'REGULUS_VERSION', defaultValue: '', description: 'デプロイするバージョン')
    string(name: 'SUBRA_BRANCH', defaultValue: 'master', description: 'Chefのブランチ')
    choice(name: 'SCOPE', choices: 'app\nfull', description: 'デプロイ範囲')
  }

  stages {
    stage('Install Gems') {
      steps {
        ws("${env.WORKSPACE}/regulus") {
          script {
            def version = (params.REGULUS_VERSION == '' ? env.GIT_BRANCH : params.REGULUS_VERSION)
            version = version.replaceFirst(/^.+\//, '')
            git url: 'https://github.com/Leonis0813/regulus.git', branch: version
            sh 'rvm 2.3.7 do bundle install --path=vendor/bundle'
          }
        }
      }
    }

    stage('Test') {
      steps {
        ws("${env.WORKSPACE}/regulus") {
          sh 'rvm 2.3.7 do bundle exec rake spec:models'
          sh 'rvm 2.3.7 do bundle exec rake spec:controllers spec:views'
        }
      }
    }

    stage('Deploy') {
      steps {
        ws("${env.WORKSPACE}/subra") {
          script {
            git url: 'https://github.com/Leonis0813/subra.git', branch: params.SUBRA_BRANCH
            def version = (params.REGULUS_VERSION == '' ? env.GIT_BRANCH : params.REGULUS_VERSION)
            version = version.replaceFirst(/^.+\//, '')
            def recipe = ('app' == params.SCOPE ? 'app' : 'default')
            sh "sudo REGULUS_VERSION=${version} chef-client -z -r regulus::${recipe} -E ${env.ENVIRONMENT}"
          }
        }
      }
    }

    stage('System Test') {
      steps {
        ws("${env.WORKSPACE}/regulus") {
          sh 'rvm 2.3.7 do env REMOTE_HOST=http://localhost/regulus bundle exec rake spec:requests'
        }
      }
    }
  }
}
