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

      JAVA_LIB = %w(
      lotus.domino.NotesThread
      lotus.domino.NotesFactory
      lotus.domino.Session
      lotus.domino.Database
      lotus.domino.Document
      lotus.domino.View
      lotus.domino.ViewEntryCollection
      lotus.domino.ViewEntry
      lotus.domino.NotesException
      )

      def import_notes_jar
        require @env.notes_jar_location
        JAVA_LIB.each do |lib|
          java_import lib
        end
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
          entry = entries.getNextEntry
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

      ITEM_VALUE_STRINGS = %w(
      From
      Subject
      Body
      )

      def mail_from(mail_entries)
        [].tap do |arr|
          each_entry_in mail_entries do |mail_entry|
            arr << {}.tap do |hsh|
              mail_doc = mail_entry.getDocument
              hsh.merge! hashify_item_value_strings(mail_doc, ITEM_VALUE_STRINGS)
              hsh[:unid] = mail_doc.getUniversalID
            end
          end
        end
      end

      def hashify_item_value_strings(doc, strs)
        {}.tap do |hsh|
          strs.each do |str|
            hsh[str.downcase.to_sym] = doc.getItemValueString(str)
          end
        end
      end
    end
  end
end
