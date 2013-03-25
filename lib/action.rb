require_relative 'notes.rb'
require_relative 'env.rb'

module NotesMailCLI
  module Action
    include LotusNotes

    def self.retrieve_unread_mail(notes)
      unread_mail = Array.new
      begin
        unread_mail = notes.unread_mail
      rescue Exception=>e
        puts "Error: #{e.class}"
        puts "Message: #{e.message}"
        puts "Backtrace:"
        puts e.backtrace
        puts
      end
      unread_mail
    end

    def self.mark_as_read(notes, unids)
      begin
        notes.mark_mail_as_read unids
      rescue Exception=>e
        puts "Error: #{e.class}"
        puts "Message: #{e.message}"
        puts "Backtrace:"
        puts e.backtrace
        puts
      end
    end

    def self.show_mail_content(mail)
      puts '---------------------{ EMAIL CONTENT }---------------------'
      puts mail[:body]
      puts '-----------------------------------------------------------'
    end
  end
end
