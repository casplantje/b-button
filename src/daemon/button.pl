#!/usr/bin/perl
use strict;
use Switch;
use FindBin;
use Device::BCM2835;
use VideoLan::Client;
use File::Compare;
use Time::HiRes qw[gettimeofday tv_interval];

# Define and initialize butons
my @buttons = (Device::BCM2835::RPI_V2_GPIO_P1_11,
		Device::BCM2835::RPI_V2_GPIO_P1_13,
		Device::BCM2835::RPI_V2_GPIO_P1_15, 
		Device::BCM2835::RPI_V2_GPIO_P1_16);

# Time to wait until the system shuts down after power connection loss
my $poweroffDelay = 60;

# And here I got fed up with the irrational pin numbering
my $powerSense = 13;
my $poweroffTime = 0;

# arrays for keeping track of the buttons
my @buttonTime;


# Globally used vlc object
my $vlc_obj = new VideoLan::Client(PASSWD => 'b-knop');

sub switchNetwork
{
	if (compare("/etc/network/interfaces", "/etc/network/interfaces.client") == 0)
	{
		system("$FindBin::Bin/wifi-host.sh");
	}
	else
	{
		system("$FindBin::Bin/wifi-client.sh");
	}
}

sub initButton
{
	my ($button) = @_;
	print "Initialize button $button \n";
	Device::BCM2835::gpio_fsel($button, &Device::BCM2835::BCM2835_GPIO_FSEL_INPT);
	Device::BCM2835::gpio_fsel($button, &Device::BCM2835::BCM2835_GPIO_PUD_OFF);
}

sub buttonAction
{
	my ($button, $milliseconds) = @_;

        print "Button pressed: $button\nmilliseconds: $milliseconds\n";
	switch ($button)
	{
		case 0 # b-button
		{
			# do the song skip thing
			$vlc_obj->cmd("next");
		}
		case 1
		{
			# The menu button
			# Extended press will shut down the device
			if ($milliseconds > 7000)
			{
				exec "poweroff";
			} else
			{
				switchNetwork();
			}
		}
		case 2
		{
			system "amixer", "sset", "Digital,0", "5+";
		}
		case 3
		{
			system "amixer", "sset", "Digital,0", "5-";
		}

	}
}

# call set_debug(1) to do a non-destructive test on non-RPi hardware
#Device::BCM2835::set_debug(1);
Device::BCM2835::init() || die "Could not init library";

# Log into vlc
$vlc_obj->login();
# Set vlc to random and playlist loop
$vlc_obj->cmd("random on");
$vlc_obj->cmd("loop on");
# Populate the playlist
$vlc_obj->cmd("clear");
$vlc_obj->cmd("add /var/www/html/music");

# Initialize all buttons
foreach (@buttons)
{
	initButton($_);
}

my $running = 1;

while ($running)
{
    Device::BCM2835::delay(50);

	# Check power sense
	if (Device::BCM2835::gpio_lev($powerSense) == HIGH)
	{
		# Reset poweroff timer
		$poweroffTime = 0;
	} else
	{
		# Start poweroff timer
		if ($poweroffTime == 0)
		{
			print "Power lost, shutting down in $poweroffDelay\n";
			$poweroffTime = [gettimeofday()];
		}
		if (tv_interval($poweroffTime) > $poweroffDelay)
		{
			exec "poweroff";
		}
	}

	# Check the state of all buttons
	for my $i (0 .. $#buttons)
	{
		if (Device::BCM2835::gpio_lev($buttons[$i]) == HIGH)
		{
			# Set the time of the start of the press
			if ($buttonTime[$i] == 0)
			{
				$buttonTime[$i] = [gettimeofday()];
			}
			# TODO: add long press events
		} else
		{
			if ($buttonTime[$i] != 0)
			{
				# A full button press has been done
				# 
				my $milliseconds = tv_interval($buttonTime[$i])*1000;
				buttonAction($i, $milliseconds);
				$buttonTime[$i] = 0;
			}
		}
	}
}
