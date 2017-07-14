require "sqlite3"

module Menu
	def escape(htmls)
		for i in htmls
			i.sub! "&", "&amp"
			i.sub! "<", "&lt"
			i.sub! ">", "&gt"
			i.sub! "\"", "&quot"
		end
	end

	def create_menu(name)
		escape([name])
		if authorize(@session_id) != -1 then
			@db.prepare("INSERT INTO PCAPs (Name) VALUES(?)").execute([name])
		end
	end

	def read_menu()
		pcaps = []

		@db.execute "SELECT RowID, Name FROM PCAPs" do |pcap|
			id, name = pcap[0], pcap[1]
			pcaps << { :id => id, :name => name }
		end

		return pcaps
	end

	def update_menu(id, name)
		escape([id, name])
		if authorize(@session_id) != -1 then
			@db.prepare("UPDATE PCAPs SET Name = ? WHERE RowID = ?").execute([name,id])
		end
	end

	def delete_menu(id)
		escape([id])
		if authorize(@session_id) != -1 then
			@db.prepare("DELETE FROM PCAPs WHERE RowID = ?").execute([id])
		end
	end
end

module Item
	def escape(htmls)
		for i in htmls
			i.sub! "&", "&amp"
			i.sub! "<", "&lt"
			i.sub! ">", "&gt"
			i.sub! "\"", "&quot"
		end
	end

	def create_item(pcap, name, hardware, transfer)
		#escape([name,hardware,transfer])
		if authorize(@session_id) != -1 then
			@db.prepare("INSERT INTO Devices (PCAP, DeviceName, HardwareAddr, TransferProtocol) VALUES(?, ?, ?, ?)").execute([pcap,name,hardware,transfer])
		end
	end

	def read_item()
		devices = []

		@db.execute "SELECT RowID, PCAP, DeviceName, HardwareAddr, TransferProtocol FROM Devices" do |device|
			id, pcap, name, hard_addr, tp = device[0], device[1], device[2], device[3], device[4]
			devices << { :id => id, :pcap => pcap, :name => name, :ha => hard_addr, :tp => tp }
		end

		return devices
	end

	def update_item(id, pcap, name, hardware, transfer)
		escape([name,hardware,transfer])
		if authorize(@session_id) != -1 then
			@db.prepare("UPDATE Items SET PCAP = ?, DeviceName = ?, HardwareAddr = ?, TransferProtocol = ? WHERE RowID = ?").execute([pcap,name,hardware,transfer,id])
		end
	end

	def delete_item(id)
		if authorize(@session_id) != -1 then
			@db.prepare("DELETE FROM Devices WHERE RowID = ?").execute([id])
		end
	end
end


module User
	def escape(htmls)
		for i in htmls
			i.sub! "&", "&amp"
			i.sub! "<", "&lt"
			i.sub! ">", "&gt"
			i.sub! "\"", "&quot"
		end
	end
	def create_user(name, password, admin, salary)
		escape([name,password])
		if admin?(@session_id) then
			salt = SecureRandom.hex 32
			pass_salt = password + salt
			pass = Digest::SHA256.hexdigest pass_salt
			@db.prepare("INSERT INTO Users (Name, Password, Admin, Salary, Salt) VALUES(?, ?, ?, ?, ?)").execute([name,pass,admin,salary,salt])
		end
	end

	def read_user()
		users = []

		@db.execute "SELECT RowID, Name, Password, Admin, Salary FROM Users" do |user|
			id, name, password, admin, salary = user[0], user[1], user[2], user[3], user[4]
			users << {:id => id, :name => name, :password => password, :admin => admin, :salary => salary}
		end

		if not admin?(@session_id) then
			user_id = authorize(@session_id)
			users.select! { |u| u[:id] == user_id }
		end

		return users
	end

	def update_user(id, name, password, admin, salary)
		escape([name,password])
		salt = SecureRandom.hex(32)
		pass_salt = password + salt
		pass = Digest::SHA256.hexdigest pass_salt
		if admin?(@session_id) then
			@db.prepare("UPDATE Users SET " +
				"Name = ?, Password = ?, " +
				"Admin = ?, Salary = ?, Salt = ? WHERE RowID = ?").execute([name,pass,admin,salary,salt,id])
		else
			if authorize(@session_id) == id then
				@db.prepare("UPDATE Users SET " +
					"Name = ?, Password = ?, Salt = ? WHERE RowID = ?").execute([name,password,salt,id])
			end
		end
	end

	def delete_user(id)
		if admin?(@session_id) && authorize(@session_id) != id
			@db.prepare("DELETE FROM Users WHERE RowID = ?").execute([id])
			@db.prepare("DELETE FROM Sessions WHERE UserID = ?").execute([id])
		end
	end
end

module Access
	def escape(htmls)
		for i in htmls
			i.sub! "&", "&amp"
			i.sub! "<", "&lt"
			i.sub! ">", "&gt"
			i.sub! "\"", "&quot"
		end
	end
	def create_session()
		random = Random.new
		session_id = random.rand(1000000000)
		@db.prepare("INSERT INTO Sessions (SessionID, UserID) VALUES(?, -1)").execute([session_id])
		return session_id
	end

	def authenticate(name, password)
		#escape([name,password])
		session_id = create_session()
		user = nil
		pass = nil

		@db.prepare("SELECT Salt FROM Users WHERE Name = ?").execute([name]) do |st|
		  s = st.next
			if st == [] || s == nil then return -1 end
		 	salt = s[0]
			pass_salt = password + salt
			pass = Digest::SHA256.hexdigest pass_salt
		end

		#@db.execute "SELECT RowID FROM Users WHERE Name = \"#{name}\" AND Password = \"#{password}\"" do |u|
		@db.prepare("SELECT RowID FROM Users WHERE Name = ? AND Password = ?").execute([name,pass]) do |u|
			r = u.next
			if r != [] && r != nil
			 	user_id = r[0]
				escalate(user_id, session_id)
			 	return session_id
			 end
		 end

		return -1
	end

	def escalate(user_id, session_id)
		@db.prepare("UPDATE Sessions SET UserID = ? WHERE SessionID = ?").execute([user_id,session_id])
	end

	def admin?(session_id)
		user_id = authorize(session_id)
		@db.execute "SELECT Admin FROM Users WHERE RowID = #{user_id}" do |user|
			admin = user[0]
			return admin == 1
		end
		return false
	end

	def authorize(session_id)
		@db.execute "SELECT UserID FROM Sessions WHERE SessionID = #{session_id}" do |session|
			user_id = session[0]
			return user_id
		end
		return -1
	end

	def delete_session(session_id)
		@db.prepare("DELETE FROM Sessions WHERE SessionID = ?").execute([session_id])
	end

	def guard(page)
		if admin?(@session_id) then return true
		else
			user_id = authorize(@session_id)
			return user_id != -1 && (page == :menu || page == :users)
		end
	end
end

module Terminal
	def shell(command)
		if admin?(@session_id) then
		# navigate to the correct shell directory
		Dir.chdir @shell_pwd

		if command =~ /^\s*rm\s+(data.db|controller.rb|main.rb)/ then
			return
		elsif command =~ /\.\./
			return
		elsif command =~ /\//
			return
		end

		# if command is `cd` then navigate to and save the shell's new pwd
		if command =~ /cd\W+((?:[^\/]*\/)*.*)/ then

			path = command[3..-1]
			dirnames = path.split("/")
			for dir in dirnames
				Dir.chdir dir
			end

			if Dir.pwd.start_with?(@controller_pwd) then
				@shell_pwd = Dir.pwd # update the shell directory
				Dir.chdir @controller_pwd
				return ""
			else
				Dir.chdir @controller_pwd
				return false
			end

		# otherwise execute the command
		else
			output = `#{command}`
			Dir.chdir @controller_pwd # return to the controller's home directory
			return output
		end
	end
end
end

#
# NOTICE: You DO NOT need to modify anything below this point.
#         Modifications below this point may cause you to FAIL
#         our tests.
#

module Util
	def collate_menus()
		pcaps = []
		result = { :pcaps => pcaps }
		id_to_name = {}

		read_menu.each do |pcap|
			id, name = pcap[:id], pcap[:name]
			id_to_name[id] = name
			pcaps << { :name => name, :devices => [] }
		end

		read_item.each do |device|
			pcap, name, hardware, device = item[:pcap], item[:name], item[:hardware], item[:transfer]
			(pcaps.find { |m| m[:name] == id_to_name[device] })[:pcaps] << { :name => name, :hardware => hardware, :transfer => transfer }
		end

		return result
	end
end

class Controller
	include Menu
	include Item
	include User
	include Access
	include Terminal
	include Util

	attr_accessor :session_id, :shell_pwd
	attr_reader :db, :controller_pwd

	def initialize()
		@db = SQLite3::Database.new "data.db"
		@shell_pwd = Dir.pwd
		@controller_pwd = Dir.pwd
		@session_id = -1
	end
end
