#LXC Driver 
   Nodejs Linux LXC  wrapper utility functions in Object Interface model . This library is utilizing the lxc commands (such as lxc-start,lxc-clone,lxc-create etc.)

#Supported functions:

Object:
1. Create a VM Object
 Vm = require('lxcdriver')
 vmobject = new VM

Object Functions:
2. Create a VM
3. Clone the VM
4. Start the VM
5. Stop the VM
6. Destroy the VM
7. Get the Running Status of the VM
8. Write a File inside the VM
9. Append a File inside the VM
10. Delete a File inside the VM
11. Add a Ethernet Interface to the VM



#Example  Program
Below example is written in coffeescript. It just indicate example to demonstrate the functionality. It cannot execute as it is.


    Vm = require('lxcdriver')

    vm_name = "vm1"
    
    #create a vm object
    vmobj = new Vm vm_name
    #create a VM
    vmobj.create "ubuntu",(result)->
        console.log "result", result
    #start the VM
    vmobj.start (result)->
        console.log "start result",result
    #stop the VM
    vmobj.stop (result)->
        console.log "stop result",result
    #destroy the VM
    vmobj.destroy (result)->
        console.log "destroy result ",result


This driver is used in Kaanalnet application to manage linux bridge, https://github.com/sureshkvl/kaanalnet/blob/master/src/builder/vmCtrl.coffee
