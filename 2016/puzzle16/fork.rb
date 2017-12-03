#!/usr/bin/env ruby

rd, wr = IO.pipe

puts 'before fork'
pid = fork do
  puts 'In fork'
  wr.close
  puts "Parent got: <#{rd.read}>"
  rd.close
end
puts 'after fork'

rd.close
puts 'Sending message to parent'
wr.write 'Hi Dad'
wr.close

Process.waitpid(pid)
