class ApplicationJob < ActiveJob::Base
  def execute_script(filename, args = [])
    ENV['PYENV_ROOT'] = '/usr/local/pyenv'
    ENV['PATH'] = [
      "#{ENV['PYENV_ROOT']}/versions/3.6.6/bin",
      "#{ENV['PYENV_ROOT']}/bin",
      '/usr/bin',
      '/bin',
    ].join(':')

    command = [
      'eval "$(pyenv init -)"',
      'eval "$(pyenv virtualenv-init -)"',
      'pyenv activate regulus',
      "python #{Rails.root.join('scripts', filename)} #{args.join(' ')}",
    ].join(' && ')
    is_success = system command
    raise StandardError unless is_success
  end
end
