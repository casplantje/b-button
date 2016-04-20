<html>
<head>
	<title>B-button</title>
</head>
<body>
<b>The b-button</b><p />
<?php
include "vlc.php";

$target_dir="music/";

if (isset($_POST["submit"]))
{
	$target_file=$target_dir . basename($_FILES["mmFile"]["name"]);

	$allowed_extensions = array('mp3', 'flac', 'ogg', 'oga', 'm4a');
	$ext = pathinfo($target_file, PATHINFO_EXTENSION);
	if (!in_array($ext, $allowed_extensions))
	{
		echo "<font color=\"#FF0000\">Invalid file format!</font><br />";
	} else
	{
		if ($_FILES["mmFile"]["size"] > 10000000)
		{
			echo "<font color=\"red\">File too large!</font><br />";
		} else
		{
			//todo: check whether the file already exists
			if (!move_uploaded_file($_FILES["mmFile"]["tmp_name"], $target_file))
			{
				throw new RuntimeException("Failed to move uploaded file!");
			} else
			{
				echo "<font color=\"#00FF00\">File uploaded!</font><br \>";
				// Add the new song to the queue
				//echo "Adding $target_file to queue";
				vlc_connect();
				vlc_command("enqueue /var/www/html/$target_file");
				vlc_close();

			}
		}
	}
}

?>
<form action="index.php" method="post" enctype="multipart/form-data">
	<b>File upload</b>
	<input type="file" name="mmFile" id="mmFile" />
	<input type="submit" value="Upload track" name="submit" />
</form>
<a href="http://<?php echo $_SERVER['SERVER_ADDR']; ?>:8080" target="_blank">[vlc interface]</a> (password: TODO: add password)<br />
<a href="downloads.php">[Software downloads]</a><br />
[Administration]

</body>
</html>
