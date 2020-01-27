require "awesome_print"
require "yaml"

DISPLAYS_FILE = "displays.yaml".freeze

unless `which displayplacer`.start_with?("/")
  puts "Error: displayplacer not found. Please see https://github.com/jakehilborn/displayplacer to install."
  exit(1)
end

# Read the displays file
displays = YAML.load_file(DISPLAYS_FILE)

# Get current display config
display_command = `displayplacer list`.split("\n").last

# Select only those displays marked as Swap=true
display_ids = display_command.scan(/id:(\S*)/).flatten.select do |id|
  displays.values.any? { |d| d["Id"] == id && d["Swap"] }
end
unless display_ids.size == 2
  puts "Error: found #{display_ids.size} displays to swap, not sure how to proceed. Update #{DISPLAYS_FILE} so only two displays can be swapped."
  exit(1)
end

# Swap the displays in command
id1, id2 = display_ids
display_command
  .sub!(id1, "XXX")
  .sub!(id2, id1)
  .sub!("XXX", id2)
output = `#{display_command}`
puts "Displays swapped"
puts "Command output: #{output}" unless output.empty?
