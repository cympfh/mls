dict = {}

n = 0
while line = gets

  line = line.chomp
  n += 1

  # num of fields
  fs = line.split("\t")
  if fs.length != 4
    STDERR.puts "[WARN] invalid line:#{n}:#{line}"
    next
  end

  type, cid, title, tags = fs
  tags = tags.split(',').select{|t| t!=''}

  # tags
  if tags.length == 0
    STDERR.puts "[ERROR] not allowed empty tags:#{n}:#{line}"
    next
  end

  # duplicate
  if dict[[type, cid]]
    STDERR.puts "[ERROR] duplicate:#{dict[[type, cid]][2]}:#{n} (#{cid},#{title})"
    next
  end

  dict[[type, cid]] = [title, tags.sort, n]
end

dict.each do |k, v|
  type, cid = k
  title, tags, _ = dict[[type, cid]]
  puts "#{type}\t#{cid}\t#{title}\t#{tags.join(',')}"
end
