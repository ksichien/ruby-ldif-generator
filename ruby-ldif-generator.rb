#!/usr/bin/env ruby
require 'securerandom'

usertemplate = "template-user.ldif"
grouptemplate = "template-group.ldif"
result = "result.ldif"
server = "dc=example,dc=com"
email = "example.com"

def genpwd
  pwd = SecureRandom.urlsafe_base64(24)
  hashpwd = pwd.crypt('$6$' + SecureRandom.random_number(36 ** 8).to_s(36))
  pwdarray = [pwd, hashpwd]
  return pwdarray
end

pwd = genpwd

if File.exists?(usertemplate)
  resultfile = File.open(result, 'w')
  templatearray = File.open(usertemplate, 'r') { |templates| templates.readlines}
  templatearray.each do |t|
    t.gsub!("SERVER", server)
    t.gsub!("FIRSTNAME", ARGV[0])
    t.gsub!("LASTNAME", ARGV[1])
    t.gsub!("FIRSTCPT", ARGV[0].capitalize)
    t.gsub!("LASTCPT", ARGV[1].capitalize)
    t.gsub!("PASSWORD", pwd[1])
    t.gsub!("EMAIL", email)
    resultfile << t
  end
  resultfile.close

  puts "Username: #{ARGV[0]}.#{ARGV[1]}"
  puts "Password: #{pwd[0]}"
  puts "Hashed Password: #{pwd[1]}"

else
  puts "No user template found, exiting."
end

unless ARGV[2].nil?
  grouparray = File.open(ARGV[2], 'r') { |groups| groups.readlines }
  grouparray.each do |g|
    resultfile = File.open(result, 'r+')
    resultfile.read # go to end of file
    resultfile << "\n"
    templatearray = File.open(grouptemplate, 'r') { |templates| templates.readlines }
    templatearray.each do |t|
      path = ""
      ldapgroups = g.split(",")
      if ldapgroups[1].nil?
        path = ldapgroups[0].chomp
      else
        path << ldapgroups[0]
        ldapunits = ldapgroups.drop(1)
        ldapunits.each do |l|
          path << ",ou=#{l.chomp}"
        end
      end
      t.gsub!("GROUPNAME",path.to_s)
      t.gsub!("SERVER", server)
      t.gsub!("FIRSTNAME", ARGV[0])
      t.gsub!("LASTNAME", ARGV[1])
      resultfile << t
    end
    resultfile.close
  end
end
