required_plugins = %w(vagrant-hostsupdater vagrant-parallels vagrant-share)

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

Vagrant.configure("2") do |config|

    config.vm.box = "bento/ubuntu-16.04"
    config.vm.synced_folder "/Users/zeke/Sites", "/var/www", create: true
    config.hostsupdater.remove_on_suspend = true

    config.vm.provider "parallels" do |prl|
      prl.memory = 512
      prl.cpus = 1
    end

    config.vm.define "phpdev7" do |phpdev7|
        phpdev7.vm.provision "shell", path: "provision/phpdev7.sh", privileged: false
        phpdev7.vm.network :private_network, ip: "192.168.35.2"
        phpdev7.vm.hostname = "m7.dev"

    end
end
