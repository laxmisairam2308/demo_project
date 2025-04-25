resource "aws_instance" "server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/ec2-user/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/templates"
    ]
  }

  provisioner "file" {
    source      = "/home/ec2-user/Flask Application/app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "file" {
    source      = "/home/ec2-user/Flask Application/templates/index.html"
    destination = "/home/ubuntu/templates/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",
      "sudo apt-get install -y python3-pip",
      "cd /home/ubuntu",
      "sudo pip3 install flask",

      # Create systemd service file for Flask
      "echo '[Unit]' | sudo tee /etc/systemd/system/flask.service",
      "echo 'Description=Flask Application' | sudo tee -a /etc/systemd/system/flask.service",
      "echo 'After=network.target' | sudo tee -a /etc/systemd/system/flask.service",
      "echo '[Service]' | sudo tee -a /etc/systemd/system/flask.service",
      "echo 'ExecStart=/usr/bin/python3 /home/ubuntu/app.py' | sudo tee -a /etc/systemd/system/flask.service",
      "echo 'Restart=always' | sudo tee -a /etc/systemd/system/flask.service",
      "echo 'User=ubuntu' | sudo tee -a /etc/systemd/system/flask.service",
      "echo 'WorkingDirectory=/home/ubuntu' | sudo tee -a /etc/systemd/system/flask.service",
      "echo 'Environment=FLASK_APP=app.py' | sudo tee -a /etc/systemd/system/flask.service",
      "echo '[Install]' | sudo tee -a /etc/systemd/system/flask.service",
      "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/flask.service",

      # Enable and start Flask service
      "sudo systemctl daemon-reload",
      "sudo systemctl enable flask",
      "sudo systemctl start flask",
      "sleep 100",
      "nohup sudo python3 app.py > flask.log 2>&1 &",
      "sleep 20",
      "echo 'started service sucuessfully'",
    ]
  }
}
