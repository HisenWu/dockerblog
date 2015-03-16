```xml
<domain type='kvm'>
	<name>Hisen_centos_7_host2</name>
	
	<memory unit='KiB'>4058222</memory>
	<currentMemory unit='KiB'>4058222</currentMemory>

	<os>
		<type>hvm</type>
		<boot dev='hd'>
		<boot dev='cdrom'/>
	</os>

	<devices>
		<emulator>/usr/libexec/qemu-kvm</emulator>
		<disk type='file' device='disk'>
			<driver name='qemu' type='qcow2'/>
			<source file='/home/sdd/hisen_docker_centos/host_centos2/centos2.qcow2'/>
			<target dev='hda'/>
		</disk>
		<disk type='file' device='cdrom'>
			<source file='/home/sdd/hisen_docker_centos/CentOS-7.0-1406-x86_64-DVD.iso'/>
			<target dev='hdb' bus='ide'/>
		</disk>
		<interface type='bridge'>
			 <source bridge='virbr0'/>
		     <mac address='00:3a:B1:38:98:01'/>  
			 <alias name='net0'/>
		 </interface>
		  <graphics type='vnc' port='-1' autoport='yes' listen='0.0.0.0'/>
	</devices>
</domain>

```
