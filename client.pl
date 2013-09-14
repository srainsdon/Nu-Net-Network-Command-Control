#!/usr/bin/perl
use IO::Socket::INET;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->init("client.conf");


######### Run it ##########################
my $ID = NetCC::Client->new("4020", "7395");
$ID->send(shift);

######### Application section #############


package NetCC::Client;


use Digest::MD5 qw(md5_base64);
use Log::Log4perl qw(get_logger);

sub new {
    my($class, $NetID, $DeviceID) = @_;

    my $logger = get_logger("NetCC::Client");

    if(defined $NetID) {
        $logger->debug("New Net-ID: $NetID DeviceID: $DeviceID");
        return bless { NetID => $NetID, DeviceID => $DeviceID }, $class;
    }
    $logger->error("No defined");
    return undef;
}

sub send {
my $logger = get_logger("NetCC::Client");

# auto-flush on socket
$| = 1;
  
# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => '192.168.0.104',
    #PeerHost => '127.0.0.1',
    PeerPort => '7777',
    Proto => 'tcp',
);
die "cannot connect to the server $!\n" unless $socket;
print "connected to the server\n";
$logger->debug("connected to server");
# data to send to a server


my ($self, $req) = @_;
#my $req = message();
$req = "0000" . $self->{NetID} . $self->{DeviceID} . $req;
my $digest = md5_base64($req);
my $size = $socket->send($req);
print "Size: $size\nMesg: $req\nMD5: $digest\n$self->{DeviceID}\n";

# notify server that request has been sent
shutdown($socket, 1);
 
# receive a response of up to 1024 characters from server
my $response = "";
$socket->recv($response, 1024);
print "Resp: $response\n";
$logger->debug("$req-$digest");
$socket->close();
}