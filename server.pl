#!/usr/bin/perl
use IO::Socket::INET;
use Digest::MD5 qw(md5_base64);
use Log::Log4perl qw(get_logger :levels);

my $logger = get_logger("NetCC::Server");
$logger->level($DEBUG);

# Appenders
my $appender = Log::Log4perl::Appender->new(
    "Log::Dispatch::File",
    filename => "NetCC.log",
    mode     => "append",
);
$logger->add_appender($appender);

my $appender2 = Log::Log4perl::Appender->new(
    "Log::Log4perl::Appender::Screen",
    stderr => 0
);

#$logger->add_appender($appender2);

# Layouts
my $layout =
  Log::Log4perl::Layout::PatternLayout->new(
                 "%d %p> %F{1}:%L %M - %m%n");
$appender->layout($layout);

my $layout2 =
  Log::Log4perl::Layout::PatternLayout->new(
                 "%d> %m%n");

$appender2->layout($layout2);

#$logger->debug("Starting");
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
$logger->debug("Server Started Port: 7777");
  
while(1)
{
    # waiting for a new client connection
    my $client_socket = $socket->accept();
 
    # get information about a newly connected client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "Device Checkin\n----------\n";
    $logger->warn("Connection: $client_address:$client_port");
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
    $logger->warn("Data: $Filler-$NetworkID-$DeviceID-$StatusCode-$input-$Filler2-$digest");
    print "Net-ID: $NetworkID\n";
    print "Device-ID: $DeviceID\n";
    print "Status: $StatusCode\n";
    print "Inputs: $input\n";
    print "MD5: $digest\n";
    print "----------\n";
    # notify client that response has been sent
    shutdown($client_socket, 1);
    $client_socket->recv($data, 1024);
    print "$data\n";
}
 
$socket->close();