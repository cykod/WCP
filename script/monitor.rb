#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'



monitor = File.join(File.dirname(__FILE__),'..','lib','daemons','monitor.rb')

options = {
  :app_name   => "monitor",
  :ARGV       => ARGV,
  :dir_mode   => :normal,
  :dir        => File.join(File.dirname(__FILE__), '..', 'log'),
  :log_output => true,
  :multiple   => false,
  :backtrace  => true,
  :monitor    => true
}
Daemons.run monitor, options


