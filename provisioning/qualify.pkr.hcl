source "null" "qualify" {
  communicator = "ssh"
  ssh_host = "{{env `PACKER_SSH_HOST`}}"
  ssh_username = "ubuntu"
  ssh_agent_auth = true
}

build {
  sources = ["source.null.qualify"]

  provisioner "file" {
    destination = "/dev/shm/mitamae.tar.gz"
    source      = "./mitamae.tar.gz"
  }

  provisioner "file" {
    destination = "/dev/shm/initial_data.tar.gz"
    source      = "./initial_data.tar.gz"
  }

  provisioner "file" {
    destination = "/dev/shm/webapp"
    source      = "../webapp"
  }

  provisioner "file" {
    destination = "/dev/shm/public"
    source      = "../public"
  }

  provisioner "file" {
    destination = "/dev/shm/bench"
    source      = "../bench"
  }

  provisioner "file" {
    destination = "/dev/shm/data"
    source      = "../data"
  }

  provisioner "shell" {
    env = {
      DEBIAN_FRONTEND = "noninteractive"
    }
    inline = [
      "cd /dev/shm",
      "tar xf mitamae.tar.gz",
      "cd mitamae",
      "sudo ./setup.sh",
      "sudo ./mitamae local roles/default.rb",

      # install initial data and codes
      "sudo rsync -a /dev/shm/webapp/ /home/isucon/webapp/",
      "sudo rsync -a /dev/shm/public/ /home/isucon/public/",
      "sudo rsync -a /dev/shm/bench/ /home/isucon/bench/",
      "sudo rsync -a /dev/shm/data/ /home/isucon/data/",
      "sudo tar xvf /dev/shm/initial_data.tar.gz -C /home/isucon",
      "sudo chown -R isucon:isucon /home/isucon",

      # reset mysql password
      "sudo mysql -u root -p -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';\"",
      "sudo cat /home/isucon/webapp/sql/admin/*.sql | mysql -uroot -proot",

      # prepare webapp
      "sudo ./mitamae local roles/webapp.rb",
      "sudo -u isucon /home/isucon/webapp/sql/init.sh",

      # Remove authorized_keys for packer
      "sudo truncate -s 0 /home/ubuntu/.ssh/authorized_keys",
      "sudo truncate -s 0 /etc/machine-id",
    ]
  }
}
