unless Vagrant.has_plugin?('vagrant-hostsupdater')
  system('vagrant plugin install vagrant-hostsupdater')
end

unless Vagrant.has_plugin?('vagrant-host-shell')
  system('vagrant plugin install vagrant-host-shell')
end

Vagrant.configure('2') do |config|
  config.ssh.forward_agent = true

  config.vm.define 'devbox' do |node|
    node.vm.box = 'bento/ubuntu-16.04'

    node.vm.network 'private_network', ip: '10.1.0.10'

    node.vm.hostname = 'heliumedu.dev'

    node.hostsupdater.aliases = %w(graphite.heliumedu.dev grafana.heliumedu.dev)

    node.vm.synced_folder './projects', '/srv/helium'

    node.vm.provider 'virtualbox' do |vb|
      vb.name = 'helium'
      vb.gui = false
      vb.memory = '4096'
      vb.cpus = 2
    end
  end
end
