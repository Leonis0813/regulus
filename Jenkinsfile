pipeline {
  agent any

  environment {
    PATH = '/usr/local/rvm/bin:/usr/bin:/bin'
    RUBY_VERSION = '2.4.4'
  }

  options {
    disableConcurrentBuilds()
  }

  parameters {
    string(name: 'REGULUS_VERSION', defaultValue: '', description: 'デプロイするバージョン')
    string(name: 'SUBRA_BRANCH', defaultValue: 'master', description: 'Chefのブランチ')
    choice(name: 'SCOPE', choices: 'full\napp', description: 'デプロイ範囲')
    booleanParam(name: 'ModuleTest', defaultValue: true, description: 'Module Testを実行するかどうか')
    booleanParam(name: 'FunctionalTest', defaultValue: true, description: 'Functional Testを実行するかどうか')
    booleanParam(name: 'Deploy', defaultValue: true, description: 'Deployを実行するかどうか')
    booleanParam(name: 'SystemTest', defaultValue: true, description: 'System Testを実行するかどうか')
  }

  stages {
    stage('Test Setting') {
      when {
        expression {
          return env.ENVIRONMENT == 'development' &&
            (params.ModuleTest || params.FunctionalTest || params.SystemTest)
        }
      }

      steps {
        script {
          sh 'sudo rm -rf coverage'
          sh "rvm ${RUBY_VERSION} do bundle install --path=vendor/bundle"
          sh "rvm ${RUBY_VERSION} do env RAILS_ENV=test bundle exec rake db:drop"
          sh "rvm ${RUBY_VERSION} do env RAILS_ENV=test bundle exec rake db:setup"
        }
      }
    }

    stage('Module Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' && params.ModuleTest }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do env COVERAGE=on bundle exec rake spec:models"
        sh "rvm ${RUBY_VERSION} do env COVERAGE=on bundle exec rake spec:lib"
      }
    }

    stage('Functional Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' && params.FunctionalTest }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do env COVERAGE=on bundle exec rake spec:controllers"
        sh "rvm ${RUBY_VERSION} do env COVERAGE=on bundle exec rake spec:views"
      }
    }

    stage('Coverage') {
      when {
        expression {
          return env.ENVIRONMENT == 'development' &&
            (params.ModuleTest || params.FunctionalTest)
        }
      }

      steps {
        publishHTML(
          target: [
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: false,
            reportDir: 'coverage/rcov',
            reportFiles: 'index.html',
            reportName: 'RCov Report',
            reportTitles: ''
          ]
        )
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
