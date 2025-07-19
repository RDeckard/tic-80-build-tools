#!/usr/bin/env ruby

# frozen_string_literal: true

require 'fileutils'
require 'time'
require 'open3'
require 'optparse'

DIST_DIR = 'dists'
TIC_EXECUTABLE = 'tic80'

# --- HELPERS ---
def error_exit(message)
  puts "💥 \e[31mError: #{message}\e[0m"
  exit 1
end

def success_exit(message)
  puts "✅ \e[32m#{message}\e[0m"
  exit 0
end

def check_executable(name)
  Open3.capture3("#{name} --version")
  true
rescue Errno::ENOENT
  false
end

def cleanup_dists
  puts "🧹 Starting cleanup of '#{DIST_DIR}' directory..."
  unless Dir.exist?(DIST_DIR)
    success_exit("Directory '#{DIST_DIR}' not found. Nothing to clean.")
  end

  dist_dirs = Dir.glob(File.join(DIST_DIR, '*/')).sort

  if dist_dirs.length <= 1
    msg = "No old distributions to clean. At most one distribution exists in '#{DIST_DIR}'."
    success_exit(msg)
  end

  dirs_to_delete = dist_dirs[0...-1]
  last_dist = dist_dirs.last

  dirs_to_delete.each do |dir|
    puts "   - Deleting old distribution: #{File.basename(dir.chomp('/'))}"
    FileUtils.rm_r(dir)
  end

  success_exit("Cleanup complete. Kept most recent distribution: #{File.basename(last_dist.chomp('/'))}")
end

class TicMaker
  attr_reader :cart_path

  def initialize(cart_path)
    error_exit("Cart file not found at '#{cart_path}'.") unless File.exist?(cart_path)
    @cart_path = cart_path
  end

  def make!(zip: false, with_sources: false)
    message = "Preparing to make binaries from '#{@cart_path}'"
    message << ' with sources included' if with_sources
    message << ' and zip them' if zip
    puts "🔎 #{message}..."

    error_exit("Could not find '#{TIC_EXECUTABLE}' executable. Please ensure it's in your PATH.") unless check_executable(TIC_EXECUTABLE)
    error_exit("Could not find 'zip' executable. Please ensure it's in your PATH.") if zip && !check_executable('zip')

    base_name = File.basename(@cart_path, '.*')
    timestamp = Time.now.strftime('%Y-%m-%d-%H%M%S')
    output_dir = File.join(DIST_DIR, "#{base_name}-#{timestamp}")
    FileUtils.mkdir_p(output_dir)

    exports = {
      html: '-html',
      win: '-win',
      linux: '-linux',
      mac: '-mac',
      rpi: '-rpi'
    }

    exports.each do |format, suffix|
      puts "   - Exporting for #{format.to_s.capitalize}..."
      base_export_path = File.join(output_dir, "#{base_name}#{suffix}")

      alone_option = with_sources ? '' : ' alone=1'
      cmd = "#{TIC_EXECUTABLE} --cli --fs . --cmd 'load #{@cart_path} & export #{format} #{base_export_path}#{alone_option}'"

      files_before = Dir.glob(File.join(output_dir, '*'))
      _stdout, stderr, status = Open3.capture3(cmd)
      files_after = Dir.glob(File.join(output_dir, '*'))

      new_artifacts = files_after - files_before

      if !status.success? || new_artifacts.empty?
        puts "     \e[31mFailed to export for #{format.to_s.capitalize}.\e[0m"
        puts "     \e[33mTIC-80 output:\n#{stderr}\e[0m"
        next
      end

      puts "     - Created: #{new_artifacts.map { |p| File.basename(p) }.join(', ')}"

      next unless zip

      if new_artifacts.length == 1 && new_artifacts.first.end_with?('.zip')
        puts "     - Skipping zip for already compressed file."
        next
      end

      zip_path = "#{base_export_path}.zip"
      artifact_basenames = new_artifacts.map { |p| "'#{File.basename(p)}'" }.join(' ')

      zip_cmd = "cd '#{output_dir}' && zip -r '#{File.basename(zip_path)}' #{artifact_basenames}"

      _zip_stdout, zip_stderr, zip_status = Open3.capture3(zip_cmd)

      if zip_status.success?
        puts "     - Zipped:  #{File.basename(zip_path)}"
        FileUtils.rm_r(new_artifacts)
      else
        puts "     \e[31mFailed to zip artifact(s): #{artifact_basenames}.\e[0m"
        puts "     \e[33mZip output:\n#{zip_stderr}\e[0m"
      end
    end

    action_desc = zip ? 'created and zipped' : 'created'
    success_exit("Successfully #{action_desc} distributions in: #{output_dir}")
  end
end

# --- MAIN LOGIC ---
if ARGV.first == 'cleanup'
  cleanup_dists
end

options = { zip: false, with_sources: false }

OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] <path_to_cart_file>"

  opts.on('-z', '--zip', 'Zip the output binaries after creation.') do
    options[:zip] = true
  end

  opts.on('-s', '--with-sources', 'Include sources in the output binaries.') do
    options[:with_sources] = true
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

if ARGV.empty?
  error_exit("Usage: #{$0} <path_to_cart_file>\nUse -h or --help for more options.")
end

cart_file_path = ARGV.first
maker = TicMaker.new(cart_file_path)
maker.make!(zip: options[:zip], with_sources: options[:with_sources])
