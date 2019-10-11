namespace :daemon do
  namespace :resque do
    require File.expand_path('../../config/application', __dir__)

    desc 'Start rescue'
    task :start do
      resque :start
    end

    desc 'Stop rescue'
    task :stop do
      resque :stop
    end

    desc 'Restart rescue'
    task :restart do
      resque :restart
    end

    def resque(operation)
      system "#{Rails.root}/bin/resque #{operation}"
    end
  end

  namespace :tensorboard do
    require File.expand_path('../../config/application', __dir__)

    desc 'Start tensorboard'
    task :start do
      tensorboard :start
    end

    desc 'Stop tensorboard'
    task :stop do
      tensorboard :stop
    end

    desc 'Restart tensorboard'
    task :restart do
      tensorboard :restart
    end

    def tensorboard(operation)
      system "#{Rails.root}/bin/tensorboard #{operation}"
    end
  end
end
