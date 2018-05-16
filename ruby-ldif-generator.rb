#!/usr/bin/env ruby
require 'securerandom'

USERTEMPLATE = 'template-user.ldif'.freeze
GROUPTEMPLATE = 'template-group.ldif'.freeze
RESULT = 'result.ldif'.freeze
SERVER = 'dc=internal,dc=vandelayindustries,dc=com'.freeze
EMAIL = 'vandelayindustries.com'.freeze

if ARGV[0].nil? || ARGV[1].nil?
  puts 'Insufficient amount of arguments provided,
        please consult the README.md file for further instructions.'
  exit
end

def genpwd
  pwd = SecureRandom.urlsafe_base64(24)
  hashpwd = pwd.crypt('$6$' + SecureRandom.random_number(36**8).to_s(36))
  [pwd, hashpwd]
end

pwd = genpwd

if File.exist?(USERTEMPLATE)
  replacements = { 'SERVER': SERVER,
                   'FIRSTNAME': ARGV[0],
                   'LASTNAME': ARGV[1],
                   'FIRSTCPT': ARGV[0].capitalize,
                   'LASTCPT': ARGV[1].capitalize,
                   'PASSWORD': pwd[1],
                   'EMAIL': EMAIL }
  resultfile = File.open(RESULT, 'w')
  templatearray = File.readlines(USERTEMPLATE)
  templatearray.each do |t|
    replacements.each do |key,value|
      t.gsub!("#{key}", "#{value}")
    end
    resultfile << t
  end
  resultfile.close
  puts "Username: #{ARGV[0]}.#{ARGV[1]}"
  puts "Password: #{pwd[0]}"
  puts "Hashed Password: #{pwd[1]}"
else
  puts 'No user template found, exiting.'
end

unless ARGV[2].nil?
  grouparray = File.readlines(ARGV[2])
  grouparray.each do |g|
    resultfile = File.open(RESULT, 'r+')
    resultfile.read # go to end of file
    resultfile << "\n"
    templatearray = File.readlines(GROUPTEMPLATE)
    templatearray.each do |t|
      path = ''
      ldapgroups = g.split(',')
      if ldapgroups[1].nil?
        path = ldapgroups[0].chomp
      else
        path << ldapgroups[0]
        ldapunits = ldapgroups.drop(1)
        ldapunits.each do |l|
          path << ",ou=#{l.chomp}"
        end
      end
      replacements = { 'GROUPNAME': path.to_s,
                       'SERVER': SERVER,
                       'FIRSTNAME': ARGV[0],
                       'LASTNAME': ARGV[1] }
      replacements.each do |key,value|
        t.gsub!("#{key}", "#{value}")
      end
      resultfile << t
    end
    resultfile.close
  end
end
