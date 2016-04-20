<?php
/*
Simple and hacky script meant for sending commands to vlc through telnet.
No support for reading messages implemented since that didn't seem very useful for a mediaplayer without any screen. I intend to use the vlc web ui for playlist management anyway.
*/

/*
Connection settings
*/
$vlc_address = "127.0.0.1";
$vlc_port= 4212;
$vlc_socket;

function vlc_connect()
{
	global $vlc_address, $vlc_port, $vlc_socket;

	//echo "connecting to $vlc_address on $vlc_port\n";
	if (($vlc_socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
		echo "socket_create() failed: reason: " . socket_strerror(socket_last_error()) . "\n";
	}

	if (socket_connect($vlc_socket, $vlc_address, $vlc_port) === false) {
    		echo "socket_connect() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
	}

	$vlc_init_message = socket_read($vlc_socket, 1024, PHP_NORMAL_READ);

	//echo $vlc_init_message;

	$vlc_password_message = socket_read($vlc_socket, 9, PHP_NORMAL_READ);
	//echo $vlc_password_message;

	socket_write($vlc_socket, "b-knop\r\n", 8);

}

function vlc_command($command)
{
	global $vlc_socket;
	socket_write($vlc_socket, $command . "\r\n", strlen($command)+2);
//	echo socket_read($vlc_socket, 1024, PHP_NORMAL_READ);
}

function vlc_close()
{
	global $vlc_socket;
	socket_close($vlc_socket);
}

?>
