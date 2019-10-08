namespace :daemon do
  namespace :resque do
    require File.expand_path('../../config/application', __dir__)

    desc 'Start rescue'
    task :start do
      worker :start
    end

    desc 'Stop rescue'
    task :stop do
      worker :stop
    end

    desc 'Restart rescue'
    task :restart do
      worker :restart
    end

    def worker(operation)
      system "#{Rails.root}/bin/resque #{operation}"
    end
  end

  namespace :tensorboard do
    require File.expand_path('../../config/application', __dir__)

    desc 'Start tensorboard'
    task :start do
      worker :start
    end

    desc 'Stop tensorboard'
    task :stop do
      worker :stop
    end

    desc 'Restart tensorboard'
    task :restart do
      worker :restart
    end

    def worker(operation)
      system "#{Rails.root}/bin/tensorboard #{operation}"
    end
  end
end
