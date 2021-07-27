resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.My_VPC_Subnet.id,aws_subnet.My_VPC_Subnet2.id]

  tags = {
    Name = "Load Balancer"
  }
}

resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.My_VPC.id
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.My_VPC.id
}

resource "aws_lb_target_group_attachment" "jenkins_tga" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}


resource "aws_lb_target_group_attachment" "app_tga" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app.id
  port             = 8080
}

resource "aws_lb_listener" "jenkins_lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
}


# resource "aws_lb_listener" "app_lb_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }

resource "aws_alb_listener_rule" "jenkins_listener_rule" {
  # depends_on   = [aws_alb_target_group.alb_target_group]  
  listener_arn = aws_lb_listener.jenkins_lb_listener.arn  
  priority     = 100
  action {    
    type             = "forward"    
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }   
  condition {    
    path_pattern    {
      values = [
        "/jenkins", "/jenkins/*"
      ]  
    }
  }
}

resource "aws_alb_listener_rule" "app_listener_rule" {
  # depends_on   = ["aws_alb_target_group.alb_target_group"]  
  listener_arn = aws_lb_listener.jenkins_lb_listener.arn
  priority     = 90  
  action {    
    type             = "forward"    
    target_group_arn = aws_lb_target_group.app_tg.arn
  }   
  condition {    
    path_pattern    {
      values = [
        "/app", "/app/*"
      ]  
    }
  }
}