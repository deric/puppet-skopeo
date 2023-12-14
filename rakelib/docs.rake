require 'rake'
require 'rake/tasklib'

module PuppetDocs
  class RakeTask < ::Rake::TaskLib

    def initialize(*args, &task_block)
      @build = true
      @task_name = args.shift || "docs"
      @desc = args.shift || "Generate markdown docs"
      define(args, &task_block)
    end

    def define(args, &task_block)

      task_block.call(*[self, args].slice(0, task_block.arity)) if task_block

      # clear any (auto-)pre-existing task
      [
        :md,
      ].each do |t|
        Rake::Task.task_defined?("module:#{t}") && Rake::Task["module:#{t}"].clear
      end

      namespace :docs do

        desc "Generate markdown docs"
        task :md do |t, targs|
          puts "Generating docs..."
          FileUtils.mkdir_p 'docs'
          system('puppet strings generate --format markdown --out docs/REFERENCE.md')
        end
      end
    end
  end
end

PuppetDocs::RakeTask.new
