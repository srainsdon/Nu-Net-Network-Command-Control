use IO::Socket::INET;
 
# auto-flush on socket
$| = 1;
 
 sub message
{
   my $NetworkID = "4020"; # 4 digit unique for keeping devices seperated
   my $DeviceID = "7395"; # 4 digit unique for keeping devices seperated
   my $StatusCode = "0007"; 
    # StatusCode is 4 digit 
    # 0000 - Emergency (emerg)
    # 0001 - Alerts (alert)
    # 0002 - Critical (crit)
    # 0003 - Errors (err)
    # 0004 - Warnings (warn)
    # 0005 - Notification (notice)
    # 0006 - Information (info)
    # 0007 - Debug (debug)
    $input1 = 1;
    $input2 = 0;
    $input3 = 0;
    $input4 = 0;
    
    return "0000" . $NetworkID . $DeviceID . $StatusCode . $input1 . $input2 . $input3 . $input4 . "5555";
    
}

 
# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => '192.168.0.104',
    PeerPort => '7777',
    Proto => 'tcp',
);
die "cannot connect to the server $!\n" unless $socket;
print "connected to the server\n";
 
# data to send to a server



my $req = message();
my $size = $socket->send($req);
print "Size: $size\nMesg: $req\n";
 
# notify server that request has been sent
shutdown($socket, 1);
 
# receive a response of up to 1024 characters from server
my $response = "";
$socket->recv($response, 1024);
print "Resp: $response\n";
 
$socket->close();