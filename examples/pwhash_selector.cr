require "../src/cox"

if ARGV.empty?
  puts "Help select Pwhash ops/mem limits for your application."
  puts "Usage: #{PROGRAM_NAME} time_min [time_max] [mem_max]"
  puts "\ttime is in seconds"
  puts "\tmem is in K"
  exit 1
end

time_min = ARGV.shift?.try &.to_f || 0.1
time_limit = if t = ARGV.shift?
               t.to_f
             else
               time_min * 4
             end
mem_limit = (ARGV.shift?.try &.to_i || (128*1024)).to_u64
pwhash = Cox::Pwhash.new
pass = "1234"

pwhash.memlimit = Cox::Pwhash::MEMLIMIT_MIN
loop do
  pwhash.opslimit = Cox::Pwhash::OPSLIMIT_MIN

  loop do
    # p pwhash
    t = Time.measure { pwhash.hash_str pass }.to_f
    s = String.build do |sb|
      sb << "mem_limit "
      sb << "%7d" % pwhash.memlimit
      sb << "K       ops_limit "
      sb << "%7d" % pwhash.opslimit
      sb << "       "
      sb << "%8.4fs" % t
    end
    puts s if t >= time_min

    break if t >= time_limit
    pwhash.opslimit *= 2
  end
  puts ""

  break if pwhash.memlimit >= mem_limit
  pwhash.memlimit *= 2
end

# TODO: table format