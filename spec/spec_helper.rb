$LOAD_PATH << File.join(File.dirname(__FILE__),"../RGD")
require 'rubygems'
require 'curb'
require 'spec'
require 'httparty'

require File.join(File.dirname(__FILE__), *%w[../RGD/RgdRecord])
require File.join(File.dirname(__FILE__), *%w[../RGD/GeneRecord])
require File.join(File.dirname(__FILE__), *%w[../RGD/QtlRecord])