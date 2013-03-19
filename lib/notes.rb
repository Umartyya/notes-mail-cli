require_relative "env.rb"
require 'java'

module NotesMailCLI
  module LotusNotes
    class Mail
      attr_reader :running, :notes, :env

      def initialize(env)
        @env = env
        import_notes_jar
        @running = false
      end

      def start(pw)
        NotesThread.sinitThread
        begin
          @notes = NotesFactory.createSessionWithFullAccess pw
        rescue NotesException=>ne
          puts "Password might be wrong!"
          puts ne.message
        else
          @running = true
        end
        @running
      end

      def stop
        NotesThread.stermThread
        @running = false
      end

      def running?
        @running
      end

      def unread_mail
        mail_docs_for :unread
      end

      def all_mail
        mail_docs_for :all
      end

      def mark_mail_as_read(unids)
        db = mail_database
        unids.each do |unid|
          mail_doc = nil
          mail_doc = db.getDocumentByUNID unid
          mail_doc.markRead unless mail_doc.nil?
        end
      end

      private

      def import_notes_jar
        require @env.notes_jar_location
        java_import "lotus.domino.NotesThread"
        java_import "lotus.domino.NotesFactory"
        java_import "lotus.domino.Session"
        java_import "lotus.domino.Database"
        java_import "lotus.domino.Document"
        java_import "lotus.domino.View"
        java_import "lotus.domino.ViewEntryCollection"
        java_import "lotus.domino.ViewEntry"
        java_import "lotus.domino.NotesException"
      end

      def mail_database
        @notes.getDatabase(@env.mail_server, @env.mail_file)
      end

      def mail_inbox
        mail_database.getView '($Inbox)'
      end

      def each_entry_in (entries, &block)
        entry = entries.getFirstEntry
        loop do
          break if entry.nil?
          block.call entry
          entry.getNextEntry
        end
      end

      def mail_docs_for(entry_type)
        mail_entries = case entry_type
          when :unread
            mail_inbox.getAllUnreadEntries
          when :all
            mail_inbox.getAllEntries
          else
            nil
        end
        mail_from mail_entries
      end

      def mail_from(mail_entries)
        mail = Array.new
        each_entry_in mail_entries do |mail_entry|
          m = Hash.new
          mail_doc = mail_entry.getDocument
          m[:from] = mail_doc.getItemValueString("From")
          m[:subject] = mail_doc.getItemValueString("Subject")
          m[:body] = mail_doc.getItemValueString("Body")
          m[:unid] = mail_doc.getUniversalID
          mail.push m
        end
        mail
      end
    end
  end
end
