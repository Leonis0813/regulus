pipeline {
  agent any

  environment {
    PATH = '/usr/local/rvm/bin:/usr/bin:/bin'
    RUBY_VERSION = '2.3.7'
  }

  parameters {
    string(name: 'REGULUS_VERSION', defaultValue: '', description: 'デプロイするバージョン')
    string(name: 'SUBRA_BRANCH', defaultValue: 'master', description: 'Chefのブランチ')
    choice(name: 'SCOPE', choices: 'app\nfull', description: 'デプロイ範囲')
    booleanParam(name: 'ModuleTest', defaultValue: true, description: '')
    booleanParam(name: 'FunctionalTest', defaultValue: true, description: '')
    booleanParam(name: 'Deploy', defaultValue: true, description: '')
    booleanParam(name: 'SystemTest', defaultValue: true, description: '')
  }

  stages {
    stage('Install Gems') {
      when {
        expression { return env.ENVIRONMENT == 'development' }
      }

      steps {
        script {
          sh "rvm ${RUBY_VERSION} do bundle install --path=vendor/bundle"
        }
      }
    }

    stage('Module Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' && params.ModuleTest }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:models"
      }
    }

    stage('Functional Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' && params.FunctionalTest }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:controllers"
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:views"
      }
    }

    stage('Deploy') {
      when {
        expression { return params.Deploy }
      }

      steps {
        ws("${env.WORKSPACE}/../chef") {
          script {
            git url: 'https://github.com/Leonis0813/subra.git', branch: params.SUBRA_BRANCH
            def version = params.REGULUS_VERSION.replaceFirst(/^.+\//, '')
            def recipe = ('app' == params.SCOPE ? 'app' : 'default')
            sh "sudo REGULUS_VERSION=${version} chef-client -z -r regulus::${recipe} -E ${env.ENVIRONMENT}"
          }
        }
      }
    }

    stage('System Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' && params.SystemTest }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do env REMOTE_HOST=http://localhost/regulus bundle exec rake spec:requests"
      }
    }
  }
}
