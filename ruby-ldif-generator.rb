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
  resultfile = File.open(RESULT, 'w')
  templatearray = File.readlines(USERTEMPLATE)
  templatearray.each do |t|
    t.gsub!('SERVER', SERVER)
    t.gsub!('FIRSTNAME', ARGV[0])
    t.gsub!('LASTNAME', ARGV[1])
    t.gsub!('FIRSTCPT', ARGV[0].capitalize)
    t.gsub!('LASTCPT', ARGV[1].capitalize)
    t.gsub!('PASSWORD', pwd[1])
    t.gsub!('EMAIL', EMAIL)
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
      t.gsub!('GROUPNAME',path.to_s)
      t.gsub!('SERVER', SERVER)
      t.gsub!('FIRSTNAME', ARGV[0])
      t.gsub!('LASTNAME', ARGV[1])
      resultfile << t
    end
    resultfile.close
  end
end
