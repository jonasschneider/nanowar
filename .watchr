watch( /spec\/.*\.spec\.coffee/ )  {|mod| run("jasmine-node --coffee .") }
watch( /app\/.*\.coffee/ )  {|mod| run("jasmine-node --coffee .") }

def run cmd
  puts cmd
  system cmd
end