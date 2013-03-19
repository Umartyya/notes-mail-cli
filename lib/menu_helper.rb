module NotesMailCLI
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
      sel = ask("Selection: ") {|input| input.echo = true}
      puts
      sel.chomp.to_i
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
end
