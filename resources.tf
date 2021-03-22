# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name = "CFkey"
  public_key = "${file("${var.key_path}")}"
}
## attach volume to public instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.net.id
}
# Define ec2 accessible to the internet
resource "aws_instance" "net" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   availability_zone = "us-east-1a"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("userdata.sh")}"
}
resource "aws_ebs_volume" "internal" {
  availability_zone = "us-east-1a"
  size              = 20
}
## attach volume to private instance
resource "aws_volume_attachment" "internal" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.internal.id
  instance_id = aws_instance.internal.id
}
# Define database inside the private subnet
resource "aws_instance" "internal" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   availability_zone = "us-east-1b"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgpri.id}"]
   source_dest_check = false
}
resource "aws_ebs_volume" "example" {
  availability_zone = "us-west-1b"
  size              = 20
}
