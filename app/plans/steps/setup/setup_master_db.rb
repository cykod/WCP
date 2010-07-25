

class Steps::Setup::SetupMasterDb < Steps::Base

  step_info "(I1) Create the master Webiva database and primary cms users"

  class Options < HashModel

  end

  def execute!(step)
     machine = cloud.migrator
     master_db = cloud.master_db

     # Get us some passwords
     cloud.initialize_database_passwords!

     ssh = machine.ssh

     sftp = ssh.sftp
     sftp.file.open('setup_mysql.sql','w') do |f|
       f.puts(<<-EOF)
CREATE DATABASE `webiva`;
GRANT SELECT,INSERT,UPDATE,DELETE ON  `webiva`.*  to '#{cloud.config.db_user}'@'%' identified by '#{cloud.config.db_user_password}';
       EOF
     end

     ssh.exec!("mysql -u #{master_db.master_username} --password=#{master_db.master_password} -h #{master_db.hostname} < setup_mysql.sql && rm setup_mysql.sql")
     ssh.close
  end


  def finished?(step)
    true
  end
end
