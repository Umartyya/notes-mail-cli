module MenuHelper
  def start
    loop do
      show_options
      sel = selection
      break if sel == 0
      break unless run(sel)
    end
  end

  def selection
    puts
    print "Selection: "
    sel = gets.chomp.to_i
    puts
    sel
  end

  def run(sel)
    if valid? sel
      perform_action sel
    else
      puts 'Invalid selection!'
      true
    end
  end
end