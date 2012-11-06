module LotusNotes
  require 'java'

  require_relative "ext/jar/Notes.jar"
  require_relative "env.rb"

  java_import "lotus.domino.NotesThread"
  java_import "lotus.domino.NotesFactory"
  java_import "lotus.domino.Session"
  java_import "lotus.domino.Database"
  java_import "lotus.domino.Document"
  java_import "lotus.domino.View"
  java_import "lotus.domino.ViewEntryCollection"
  java_import "lotus.domino.ViewEntry"
  java_import "lotus.domino.NotesException"

  class Mail
    attr_reader :running, :notes, :mail_server, :mail_file
    def initialize
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
      mail_docs = Array.new
      unread_entries = mail_inbox.getAllUnreadEntries
      unread_mail_entry = unread_entries.nil? ? nil : unread_entries.getFirstEntry
      while (!unread_mail_entry.nil?)
        mail = Hash.new
        mail_doc = unread_mail_entry.getDocument
        mail[:from] = mail_doc.getItemValueString("From")
        mail[:subject] = mail_doc.getItemValueString("Subject")
        mail[:body] = mail_doc.getItemValueString("Body")
        mail[:unid] = mail_doc.getUniversalID
        mail_docs.push mail
        unread_mail_entry = unread_entries.getNextEntry
      end
      mail_docs
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

    def mail_database
      @notes.getDatabase(Env::mail_server, Env::mail_file)
    end

    def mail_inbox
      mail_database.getView '($Inbox)'
    end

  end
end