require_relative 'notes.rb'
require_relative 'action.rb'
require_relative 'menu_helper.rb'

module NotesMailCLI
  module Menu
    class Main
      include MenuHelper

      attr_reader :env

      def initialize(env)
        @env = env
        begin
          loop do
            @notes_pw = ask_for_notes_password
            @notes = LotusNotes::Mail.new @env
            puts "Logging in to Notes..."
            puts
            break if @notes.start(@notes_pw)
          end
          puts "Notes successfully logged in."
          puts
          start
        ensure
          @notes.stop
        end
      end

      def ask_for_notes_password
        ask("Enter Notes password: ") {|input| input.echo = "*"}
      end

      def show_options
        puts '(1) Check for new mail'
        puts '(0) Quit'
      end

      def valid?(sel)
        case sel
        when 1 then true
        else false
        end
      end

      def perform_action(sel)
        case sel
        when 1
          Unread.new @notes
        else
          raise "Internal Error!"
        end
      end
    end

    class Unread
      include MenuHelper
      include Action

      def initialize(notes)
        @notes = notes
        @unread_mails = Action::retrieve_unread_mail @notes
        start
      end

      def show_options
        puts "There are #{@unread_mails.length} unread mails."
        puts '(1) Show one at a time'
        puts '(2) Show all at once (subject headers only)'
        puts '(0) Back'
      end

      def valid?(sel)
        case sel
        when 1,2 then true
        else false
        end
      end

      def perform_action(sel)
        case sel
        when 1 then show_each_mail
        when 2 then show_all_mails
        else raise "Internal Error!"
        end
      end

      def show_each_mail
        @unread_mails.each do |mail|
          puts "From: #{mail[:from]}"
          puts "Subject: #{mail[:subject]}"
          EachMail.new @notes, mail
        end
      end

      def show_all_mails
        i = 0
        unids = Array.new
        @unread_mails.each do |mail|
          i += 1
          puts "(#{i}) #{mail[:subject]}"
          unids.push mail[:unid]
        end
        AllMail.new @notes, unids
      end
    end

    class EachMail
      include MenuHelper

      def initialize(notes, mail)
        @notes = notes
        @mail = mail
        start
      end

      def show_options
        puts '(1) Mark as read'
        puts '(2) Show contents'
        puts '(0) Skip'
      end

      def valid?(sel)
        case sel
        when 1,2 then true
        else
          false
        end
      end

      def perform_action(sel)
        case sel
        when 1 
          Action::mark_as_read @notes, [@mail[:unid]]
          false
        when 2
          Action::show_mail_content @mail
          true
        else
          raise "Internal Error!"
        end
      end
    end

    class AllMail
      include MenuHelper

      attr_reader :mail_unid

      def initialize(notes, unids)
        @notes = notes
        @mail_unids = unids
        start
      end

      def show_options
        puts '(1) Mark everything as read'
        puts '(0) Back'
      end

      def perform_action(sel)
        case sel
          when 1 then Action::mark_as_read @notes, @mail_unids
          else raise "Internal Error!"
        end
        false
      end
    end
  end
end
