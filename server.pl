use IO::Socket::INET;
use Digest::MD5 qw(md5 md5_hex md5_base64);
print "Starting...\n";
# auto-flush on socket
$| = 1;
 
# creating a listening socket
my $socket = new IO::Socket::INET (
    LocalHost => '0.0.0.0',
    LocalPort => '7777',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);
die "cannot create socket $!\n" unless $socket;
print "Server Started\nPort: 7777\n----------\n";
  
while(1)
{
    # waiting for a new client connection
    my $client_socket = $socket->accept();
 
    # get information about a newly connected client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "Device Checkin\n----------\n";
    print "IP: $client_address\nPort: $client_port\n";
 
    # read up to 1024 characters from the connected client
    my $data = "";
    $client_socket->recv($data, 1024);
    #print "received data: $data\n";
 
    # write response data to the connected client
    $data = "$data";
    $digest = md5_base64($data);
    @array = ( $data =~ m/..../g );
    ($Filler, $NetworkID, $DeviceID, $StatusCode, $input, $Filler2) = @array;
    $client_socket->send($digest);
    print "Net-ID: $NetworkID\n";
    print "Device-ID: $DeviceID\n";
    print "Status: $StatusCode\n";
    print "Inputs: $input\n";
    print "----------\n";
    # notify client that response has been sent
    shutdown($client_socket, 1);
}
 
$socket->close();