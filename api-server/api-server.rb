require 'sinatra'
require 'json'
require 'down'
require 'fileutils'
post '/payload' do
  payload = JSON.parse(request.body.read)
  if payload['action'] == 'published'
    package = payload['package']
    if package['package_type'] == 'maven'
      package_files = package['package_version']['package_files']
      package_files.each { |asset|
      if asset['name'].end_with? "jar"
        begin
            tempFile = Down.download(asset['download_url']);
            deleteFile = tempFile.original_filename[0..5].concat('*');
            system("pwd")
            system("find ./api-server/target/maven/ -type f -name #{deleteFile} -delete");
            system("sudo docker exec aps find /usr/share/tomcat/webapps/activiti-app/WEB-INF/lib -type f -name #{deleteFile} -delete");
            FileUtils.mv(tempFile.path, "./api-server/target/maven/#{tempFile.original_filename}");
            system("sudo docker cp /home/ubuntu/alfresco-docker-compose/api-server/target/maven/#{tempFile.original_filename} aps:/usr/share/tomcat/webapps/activiti-app/WEB-INF/lib");
            system("sudo docker container stop aps");
            system("sudo docker container start aps");
        rescue => exception
          puts "Exception Message: #{ exception.message }"
          puts "Exception Backtrace: #{ exception.backtrace }"
        end
      end
      }
    if package['package_type'] == 'npm'
      puts 'Write Code here for npm packaging'
    end
  end
end
end
