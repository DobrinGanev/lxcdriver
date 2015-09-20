util = require 'util'
exec = require('child_process').exec
fs = require('fs')

execute = (command, callback) ->
    callback new Error "command not given" unless command?
    util.log "executing #{command}..."        
    exec command, (error, stdout, stderr) =>
        util.log "lxcdriver: execute - Error : " + error if error?
        util.log "lxcdriver: execute - stdout : " + stdout if stdout?        
        util.log "lxcdriver: execute - stderr : " + stderr if stderr?
        if error
            callback error
        else
            callback true

class LXC
	#state  - initialized,created,cloned,started,stopped,destroyed
	constructor : (name)->	
		throw new Error "Container Name not given" unless name?	
		@name = name		
		@state =  "initialized"

	exists : (callback)->
		command = "lxc-info -n #{@name} "
		util.log "executing #{command}..."        
		execute command, (result) =>
			callback result

	create : (template,callback)->
		#check the container existence.. if exists return error
		#create a container from the template name given
		throw new Error unless template?
		return callback new Error "Called in Wrond time"  unless @state is "initialized" or @state is "destroyed"
		@exists (result)=>
			if result instanceof Error
				command = "lxc-create -n #{@name} -t #{template} "
				execute command, (result) =>
					@state = "failed" if result instanceof Error
					@state = "created" if result is true						
					return callback result
			else
				@state = "exists"
				return callback new Error "Exists"			
			
	clone : (refimage,callback)->
		#check the container existence.. if exists return error
		#clone the image from the refimage name
		return callback new Error "Refimage name not given" unless refimage?
		return callback new Error "Called in Wrond time"  unless @state is "initialized" or @state is "destroyed"
		@exists (result)=>
			if result instanceof Error
				command = "lxc-clone  -o #{refimage} -n #{@name} "
				execute command, (result) =>
					@state = "failed" if result instanceof Error
					@state = "cloned" if result is true						
					return callback result			
			else
				@state = "exists"
				return callback new Error "Exists"	

	start : (callback)->
		#start the container
		return callback new Error "Called in Wrond time" unless @state is "created" or @state is "cloned"
		command = "lxc-start -n #{@name} -d "
		execute command, (result) =>
			@state = "failed" if result instanceof Error
			@state = "started" if result is true						
			return callback result			
			
	stop : (callback)->
		#stop the container
		return callback new Error "Called in Wrond time" unless @state is "started"
		command = "lxc-stop -n #{@name} "
		execute command, (result) =>
			@state = "failed" if result instanceof Error
			@state = "stopped" if result is true						
			return callback result		
	destroy : (callback)->	
		#destroy the container
		return callback new Error "Called in Wrond time" unless @state is "stopped"
		command = "lxc-destroy -n #{@name} "
		execute command, (result) =>
			@state = "failed" if result instanceof Error
			@state = "destroyed" if result is true						
			return callback result		
	runningstatus :(callback)->
		#return the status of the container
		command = "lxc-ls --running #{@name} "
		exec command, (error, stdout, stderr) =>
			util.log "lxcdriver: execute - Error : " + error if error?
			util.log "lxcdriver: execute - stdout : " + stdout
			util.log "lxcdriver: execute - stderr : " + stderr if stderr?
			if error or not stdout?
				callback "notrunning"
			else
				callback "running"	

	appendFile :(filename,text)->
		return new Error "Called in Wrond time"  unless @state is "created" or @state is "cloned"
		path = "/var/lib/lxc/#{@name}/rootfs"
		filename = path + filename
		util.log "appendFile ..filename is ", filename
		fs.appendFileSync(filename,text)
		return true

	writeFile :(filename,text)->
		#write the contents in to the contents
		return new Error "Called in Wrond time"  unless @state is "created" or @state is "cloned"
		path = "/var/lib/lxc/#{@name}/rootfs"
		filename = path + filename
		util.log "writeFile ..filename is ", filename
		fs.writeFileSync(filename,text)
		return true

	deleteFile :(filename)->	
		return  new Error "Called in Wrond time"  unless @state is "created" or @state is "cloned"
		path = "/var/lib/lxc/#{@name}/rootfs"
		filename = path + filename
		util.log "deleteFile ..filename is ", filename				
		fs.unlinkSync filename
		return true	
	
	addEthernetInterface: (vethname, hwAddress) ->
		return  new Error "Called in Wrond time"  unless @state is "created" or @state is "cloned"
		#update the lxc container config file
		util.log " addEthernetInterface #{@name}  vethname #{vethname}  hwAddress #{hwAddress} "
		filename = "/var/lib/lxc/#{@name}/config"
		util.log " filname " + filename
		text = "\nlxc.network.type = veth \nlxc.network.hwaddr= #{hwAddress} \nlxc.network.veth.pair = #{vethname} \nlxc.network.flags = up"
		fs.appendFileSync(filename,text)
		return true

	destructor : ()->
		@stop (result)=>
			@destroy (result)=>
				console.log "result",result

module.exports = LXC