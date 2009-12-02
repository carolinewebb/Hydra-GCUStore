namespace :shelver do
  
  desc 'Index a fedora object of the given pid.'
  task :shelve_object do 
    INDEX_FULL_TEXT = ENV['FULL_TEXT'] == 'true'
    if ENV['PID']
      puts "indexing #{ENV['PID'].inspect}"
      shelver = Shelver::Shelver.new
      shelver.shelve_object()
      puts "Finished shelving #{ENV[PID]}"
    else
      puts "You must provide a pid using the format 'shelver::shelve_object PID=sample:pid'."
    end
  end
  
  desc 'Index all objects in the repository.'
  task :shelve_objects => :environment do
    INDEX_FULL_TEXT = ENV['FULL_TEXT'] == 'true'
    puts "Re-indexing Fedora Repository."
    puts "Fedora URL: #{ActiveFedora.fedora_config[:url]}"
    puts "Fedora Solr URL: #{ActiveFedora.solr_config[:url]}"
    puts "Blacklight Solr Config: #{Blacklight.solr_config}"
    puts "Doing full text index." if INDEX_FULL_TEXT
    shelver = Shelver::Shelver.new
    shelver.shelve_objects
    puts "Shelver task complete."
  end
  
end